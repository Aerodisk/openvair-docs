# Документация модуля volume

## Основное назначение

Модуль `volume` реализует жизненный цикл виртуальных томов:  
создание, удаление, расширение, мониторинг, а также обеспечение связки с
виртуальными машинами.

---

## Архитектура и слои

```
API (FastAPI, entrypoints/api.py)
↓
Service Layer (service_layer/services.py, unit_of_work.py)
↓
Domain Layer (domain/model.py, domain/physical_fs.py, domain/remotefs/)
↓
Infrastructure (adapters/orm.py, repository.py, serializer.py)
```

- **API:** REST endpoint’ы, валидация входных данных через Pydantic (
  `schemas.py`).
- **Service Layer:** бизнес-логика, orchestration, проверка статусов, интеграция
  с event_store, транзакции.
- **Domain Layer:** работа с физическими томами и ФС (создание, удаление,
  расширение), проверки на уровне ФС.
- **Infrastructure:** работа с БД через ORM, репозитории,
  сериализация/десериализация.

---

## Эндпоинты API

| Метод  | URL                          | Описание                                                                           |
|--------|------------------------------|------------------------------------------------------------------------------------|
| GET    | /volumes/                    | Получить список томов (фильтры: storage_id, свободные, пагинация)                  |
| GET    | /volumes/{volume_id}/        | Получить информацию о томе                                                         |
| POST   | /volumes/create/             | Создать новый том (name, storage_id, format, size, description)                    |
| PUT    | /volumes/{volume_id}/edit/   | Изменить метаданные (имя, описание, флаг read_only)                                |
| POST   | /volumes/{volume_id}/extend/ | Увеличить размер тома (новый размер > текущего, свободное место в storage)         |
| DELETE | /volumes/{volume_id}/        | Удалить том (если не подключён к ВМ и не используется)                             |
| POST   | /volumes/{volume_id}/attach/ | Привязать к виртуальной машине *(требует интеграции с VM, через отдельный сервис)* |
| DELETE | /volumes/{volume_id}/detach/ | Отвязать от виртуальной машины *(требует интеграции с VM, через отдельный сервис)* |

**Примечание:** Для attach/detach требуется установленный и работающий модуль
виртуальных машин (VM).

---

## Валидации и исключения

- Все входные данные валидируются на уровне DTO (Pydantic).
- Имя тома уникально в пределах storage.
- Форматы: только qcow2/raw.
- Размер: целое, положительное число.
- Возможность удаления: том не подключён к ВМ, статус `available` или `error`.
- Изменение метаданных: только если статус тома — `available`.
- Расширение тома: только если VM выключена и достаточно места.
- Любые ошибки возвращаются с объяснением и кодом (400, 409, 404).
- При ошибках доступа к ФС, RPC, БД статус тома становится `error` с деталями.
- Используются кастомные исключения сервисного слоя.

---

## Статусы тома (`VolumeStatus`)

- `new`
- `creating`
- `available`
- `extending`
- `deleting`
- `error`

---

## ORM

```python
import uuid
from typing import List

from sqlalchemy import (
    UUID,
    Text,
    String,
    Boolean,
    Integer,
    BigInteger,
    ForeignKey,
)
from sqlalchemy.orm import (
    Mapped,
    DeclarativeBase,
    relationship,
    mapped_column,
)


class Base(DeclarativeBase):
    """Base class for inheritance volumes and attachments volumes."""

    pass


class Volume(Base):
    __tablename__ = 'volumes'

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        primary_key=True,
        default=uuid.uuid4,
    )
    name: Mapped[str] = mapped_column(
        String(40),
        nullable=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        nullable=True,
    )
    format: Mapped[str] = mapped_column(
        String(10),
        nullable=True,
    )
    size: Mapped[int] = mapped_column(
        BigInteger,
        nullable=True,
    )
    used: Mapped[int] = mapped_column(
        BigInteger,
        nullable=True,
    )
    status: Mapped[str] = mapped_column(
        String(20),
        nullable=True,
    )
    information: Mapped[str] = mapped_column(
        Text,
        nullable=True,
    )
    path: Mapped[str] = mapped_column(
        String(255),
        default='',
        nullable=True,
    )
    template_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        nullable=True,
    )
    description: Mapped[str] = mapped_column(
        String(255),
        nullable=True,
    )
    storage_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        nullable=True,
    )
    storage_type: Mapped[str] = mapped_column(
        String(30),
        default='',
        nullable=True,
    )
    read_only: Mapped[bool] = mapped_column(
        Boolean(),
        default=False,
        nullable=True,
    )

    attachments: Mapped[List['VolumeAttachVM']] = relationship(
        'VolumeAttachVM',
        back_populates='volume',
        uselist=True,
    )


class VolumeAttachVM(Base):

    __tablename__ = 'volume_attach_vm'
    id: Mapped[int] = mapped_column(Integer, primary_key=True)
    volume_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        ForeignKey('volumes.id'),
        nullable=True,
    )
    vm_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        nullable=True,
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(),
        nullable=True,
    )
    target: Mapped[str] = mapped_column(
        String(50),
        nullable=True,
    )

    volume: Mapped[Volume] = relationship(
        'Volume',
        back_populates='attachments',
    )

```

---

## Работа с файловой системой

- Локальные операции реализованы в `domain/physical_fs.py`.
- Для NFS — через `domain/remotefs/nfs.py`.
- Проверяется наличие файла, свободное место, успешность операций.
- При ошибках (недостаточно места, ошибка доступа) — подробное описание в поле
  `information`.

---

## Мониторинг

- Фоновая задача автоматически обновляет статус, размер и использование через
  `qemu-img info` (раз в 10 секунд).
- Все изменения статуса или размера фиксируются в event_store для мониторинга и
  истории.

---

## События и интеграция

- Все значимые события (создание, удаление, расширение, ошибки) публикуются
  через event_store (RabbitMQ).
- Использует RPC для связи с модулями storage, VM, event_store.
- Интеграция с системой мониторинга платформы (экспорт метрик возможен).

---

## Ошибки и типовые ситуации

- 409 Conflict — при попытке удалить attach-том.
- 409 Conflict — при попытке расширить или создать том без места.
- 400 Bad Request — некорректные параметры, неверный формат.
- 404 Not Found — не найден storage, том, VM.
- Критические ошибки — переводят том в статус `error`, подробности доступны
  через API.

---

## Ограничения

- Формат изменить нельзя после создания.
- Удаление возможно только если нет привязки к ВМ.
- Attach/detach не реализованы, если не установлен модуль VM.
- Нет поддержки snapshot’ов, clone и резервного копирования на уровне томов.
- Только qcow2/raw, другие форматы не поддерживаются.

---

## Связанные файлы

- `adapters/orm.py, repository.py` — работа с БД.
- `adapters/serializer.py` — сериализация данных.
- `domain/physical_fs.py, remotefs/nfs.py` — операции с ФС.
- `domain/model.py` — доменная модель.
- `service_layer/services.py, unit_of_work.py` — бизнес-логика, транзакции.
- `entrypoints/api.py, schemas.py` — API, валидация.

---

## Требования к безопасности

- Все ошибки переводят том в статус `error` с логированием причины.
- Все действия логируются для последующего аудита.

