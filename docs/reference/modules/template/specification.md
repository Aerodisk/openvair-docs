# Документация модуля template

## Основное назначение

Модуль `template` реализует жизненный цикл шаблонов виртуальных томов:  
создание шаблонов из существующих томов, хранение, удаление, контроль связей,
использование как backing-файлы, интеграция с volume/storage через RPC.  
Позволяет ускорять и стандартизировать создание виртуальных дисков (volumes) на
основе qcow2/raw-образов.

---

## Архитектура и слои

```
API (FastAPI, entrypoints/api.py)
↓
Service Layer (service_layer/services.py, unit_of_work.py)
↓
Domain Layer (domain/model.py)
↓
Infrastructure (adapters/orm.py, repository.py, serializer.py)
```

- **API:** REST endpoint’ы, валидация входных данных через Pydantic.
- **Service Layer:** бизнес-логика, orchestration, проверка связей (volumes),
  интеграция с event_store, транзакции.
- **Domain Layer:** работа с шаблонами, контроль ограничений (запрет удаления
  используемого шаблона), формирование backing-файлов.
- **Infrastructure:** работа с БД через ORM, репозитории,
  сериализация/десериализация.

---

## Эндпоинты API

| Метод  | URL                       | Описание                                            |
|--------|---------------------------|-----------------------------------------------------|
| GET    | /templates/               | Получить список шаблонов (фильтры, пагинация)       |
| GET    | /templates/{template_id}/ | Получить информацию о шаблоне                       |
| POST   | /templates/               | Создать новый шаблон (на основе существующего тома) |
| PATCH  | /templates/{template_id}/ | Изменить имя/описание шаблона                       |
| DELETE | /templates/{template_id}/ | Удалить шаблон (если не используется volumes)       |


### Подробности по эндпоинтам

#### `GET /templates/`

- Возвращает: список шаблонов и метаданные пагинации (`items`, `total`, `page`,
  `size`, `pages`).
- Каждый элемент содержит: `id`, `name`, `description`, `tmp_format`,
  `storage_id`, `is_backing`, `created_at`, `status`.

#### `GET /templates/{template_id}/`

- Возвращает: подробную информацию о шаблоне по UUID.
- При ошибке: возвращает статус 404, если шаблон не найден.

#### `POST /templates/`

- Создаёт шаблон на основе существующего тома.
- Требует обязательные поля: `name`, `storage_id`, `base_volume_id`,
  `is_backing`.

#### `PATCH /templates/{template_id}/`

- Позволяет изменить имя и/или описание шаблона.

#### `DELETE /templates/{template_id}/`

- Удаляет шаблон. Проверяет, не используется ли шаблон другими томами (через
  RPC).

---

## Валидации и исключения

- Все входные данные валидируются на уровне DTO (Pydantic).
- Имя шаблона уникально в пределах хранилища.
- Форматы: только qcow2/raw.
- Нельзя удалить или изменить шаблон, если на него ссылаются volumes (через
  backing-файл).
- Любые ошибки возвращаются с объяснением и кодом (400, 409, 404).
- При ошибках доступа к storage, RPC или БД статус шаблона становится `error` с
  деталями.
- Используются кастомные исключения сервисного слоя.

---

## Статусы шаблона (`TemplateStatus`)

- `available` — шаблон готов к использованию.
- `creating` — шаблон в процессе создания/импорта.
- `deleting` — шаблон помечен на удаление, происходит освобождение ресурсов.
- `error` — произошла ошибка при создании/удалении шаблона.

---

## ORM

```python
import uuid
import datetime
from typing import Literal, Optional

from sqlalchemy import (
    UUID,
    Enum as SAEnum,
    Text,
    String,
    Boolean,
    DateTime,
    BigInteger,
)
from sqlalchemy.orm import Mapped, DeclarativeBase, mapped_column

from openvair.common.orm_types import PathType
from openvair.modules.template.shared.enums import TemplateStatus


class Base(DeclarativeBase):
    """Base class for ORM mappings in the template module."""

    pass


class Template(Base):

    __tablename__ = 'templates'

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        primary_key=True,
        default=uuid.uuid4,
    )
    name: Mapped[str] = mapped_column(
        String(40),
        unique=True,
        nullable=False,
    )
    description: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    path: Mapped[str] = mapped_column(
        PathType,
        nullable=False,
    )
    tmp_format: Mapped[Literal['qcow2', 'raw']] = mapped_column(
        String(10),
        nullable=False,
    )
    size: Mapped[int] = mapped_column(BigInteger, nullable=False, default=0)
    storage_id: Mapped[uuid.UUID] = mapped_column(
        String(36),
        nullable=False,
    )
    status: Mapped[TemplateStatus] = mapped_column(
        SAEnum(TemplateStatus, name='template_status'),
        nullable=False,
        default=TemplateStatus.NEW,
    )
    information: Mapped[Optional[str]] = mapped_column(
        Text,
        nullable=True,
    )
    is_backing: Mapped[bool] = mapped_column(
        Boolean,
        default=True,
        nullable=False,
    )
    created_at: Mapped[datetime.datetime] = mapped_column(
        DateTime,
        default=datetime.datetime.now(),
    )

```

---

## Работа с файлами шаблонов

- Для хранения используется хранилище (`storage`), к которому шаблон привязан
  через `storage_id`.
- Поддержка локальных и сетевых storage (NFS и др., если поддерживается
  платформой).
- Физические файлы шаблонов — qcow2/raw — управляются через доменный слой.
- Операции копирования, создания, удаления реализованы с помощью `qemu-img`,
  файловой системы.

---

## Мониторинг

- Логгирование всех операций (создание, удаление, ошибки) через общий логгер
  системы.
- Фиксация событий (создание, изменение статуса, удаление) в event_store (
  RabbitMQ).
- Возможность интеграции с системой мониторинга через экспорт событий/метрик.

---

## События и интеграция

- Все значимые события (создание, удаление, изменение статуса) публикуются через
  event_store (RabbitMQ).
- Использует RPC для связи с volume, storage, event_store.
- Интеграция с системой мониторинга платформы (экспорт метрик возможен).
- Реагирует на события создания/удаления volumes для поддержания целостности
  связей.

---

## Ошибки и типовые ситуации

- 409 Conflict — при попытке удалить шаблон, который используется.
- 409 Conflict — при попытке создать дубликат.
- 400 Bad Request — некорректные параметры, неверный формат.
- 404 Not Found — не найден storage, шаблон.
- Критические ошибки — переводят шаблон в статус `error`, подробности доступны
  через API.

---

## Ограничения

- Формат шаблона нельзя изменить после создания.
- Удаление возможно только если нет связанных volumes (backing-файлов).
- Только qcow2/raw, другие форматы не поддерживаются.
- Прямая интеграция с ВМ не осуществляется — только через volumes.

---

## Связанные файлы

- `adapters/orm.py, repository.py` — работа с БД.
- `adapters/serializer.py` — сериализация данных.
- `domain/model.py` — доменная модель шаблонов.
- `service_layer/services.py, unit_of_work.py` — бизнес-логика, транзакции.
- `entrypoints/api.py, schemas.py` — API, валидация.

---

## Требования к безопасности

- Все ошибки переводят шаблон в статус `error` с логированием причины.
- Все действия логируются для последующего аудита.

