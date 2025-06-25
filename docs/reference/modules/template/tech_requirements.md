# Технические требования к модулю шаблонов(template)

## Общая концепция

Модуль шаблонов предназначен для управления базовыми образами (`qcow2`), из
которых создаются виртуальные диски (
`volumes`).

- **Шаблоны (`templates`)** – являются основой для создания `volumes`, и
  создаются на их основе.
- **Хранение (`storage`)** – отвечает за физическое хранение файлов шаблонов (
  `qcow2`).
- **Диски (`volume`)** – управляют виртуальными дисками, создаваемыми из
  шаблонов.

Связь между `templates`, `volume` и `storage` осуществляется через RPC, без
жёстких `ForeignKey`.

Создание `volume` из шаблона выполняется в модуле `volume`.

## Основной функционал

### Управление шаблонами

- **Создание шаблонов**

    - Пользователь указывает существующий `volume` в системе.
    - `templates` создаёт новый шаблон, регистрируя его метаданные.
    - Физический `qcow2`-файл шаблона создаётся как копия существующего `volume` в
      `storage` и регистрируется в `templates`,
      чтобы оригинальный `volume` оставался неизменным.

    - Поддержка двух типов шаблонов:
      - Полная копия (`qemu-img convert`)
      - Связь через `backing`-файл (`qemu-img create -b`)

    После создания шаблон доступен для использования в `volume`.


- **Удаление шаблонов**

    - Перед удалением проверяется, есть ли зависимые `volumes` (через RPC).
    - Если на шаблон ссылаются `backing`-файлы — удаление запрещено.
    - Если зависимостей нет — `templates` отправляет команду `storage` на удаление
      файла.


- **Редактирование шаблонов**

    - Редактирование запрещено, если на шаблон есть ссылки (`backing`-файл).
    - Редактировать можно только, если шаблон не используется.
    - Шаблон знает, какие `volumes` его используют, и `volumes` знают, из какого
      шаблона они созданы.

### Создание volumes из шаблонов

- **Создание volumes на основе шаблонов (выполняется в `templates`)**
    - `templates` создаёт `volume`, который записывается в `storage`,
      регистрируется
      в `volume` и становится доступным для
      использования виртуальными машинами.
    - Создаётся `qcow2` с или без `backing`-файла, в зависимости от параметров.
    - Диск регистрируется в `volume` и хранится в `storage`.


- **Создание ВМ с диском из шаблона**
    - Созданные `volumes` подключаются к ВМ как обычные диски.
    - `virtual_machines` работает с `volumes`, но не взаимодействует напрямую с
      шаблонами.

### Наследование шаблонов

- Создание новых шаблонов на основе существующих
- Возможность создания "наследников" шаблонов, даже если создаются новые
  `volumes`.
- `templates` управляет логикой, но файлы шаблонов хранятся в `storage`.

## Учет зависимостей

- `template` связывается с `volume`, а не с `virtual_machine`
- Шаблон не может быть изменён или удалён, если на него ссылаются `volumes`
  через `backing`-файл
- Все проверки перед удалением и редактированием выполняются через RPC

## Модульность и взаимодействие

- Модули независимы — `templates`, `storage` и `volume` работают отдельно
- Связь между модулями через RPC — например, `volume` запрашивает данные о
  шаблонах у `templates`
- Шаблоны управляются `templates`, но хранятся в `storage`
- Диски создаются в `volume`, но могут использовать `templates`
- Создание `volumes` из шаблонов реализуется в `volume`

## API/RPC Методы

### Управление шаблонами (`templates API`)
- `GET /templates` → Получить список шаблонов
- `POST /templates` → Добавить новый шаблон
- `DELETE /templates/{template_name}` → Удалить шаблон (с проверкой через RPC)

### Управление дисками (`volumes API`)
- `POST /volumes` → Создать новый диск из шаблона
- `GET /volumes?template_name={name}` → Получить все диски, созданные из
  шаблона

## Структура базы данных

### Таблица `templates` (основная информация о шаблоне)

Описание полей:

- `id` — Уникальный идентификатор шаблона
- `name` — Имя шаблона, должно быть уникальным
- `description` — Описание шаблона (опционально)
- `disk_path` — Путь к `qcow2` файлу в `storage`
- `created_at` — Время создания шаблона (`timestamp`)
- `is_backing` — Флаг, указывающий, является ли шаблон корневым (`True` — да,
  `False` — нет)

```python
class Template(Base):
  """ORM class representing a template.

  Attributes:
      id: Unique identifier of the template.
      name: Unique name of the template.
      description: Optional description.
      path: Filesystem path to the qcow2 file stored in storage.
      storage_id: Identifier of the storage where the template is located.
      is_backing: Flag indicating whether the template is a backing file.
      created_at: Timestamp when the template was created.

  """

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

### Новое поле для таблицы volume

```python
class Volume(Base):
  ...
  template_id: Mapped[uuid.UUID] = mapped_column(
    UUID(),
    nullable=True,
  )
  ...
```

## Итог

- Нет жёстких `ForeignKey` — вся связь через RPC
- Гибкость — можно управлять `шаблонами` и `volumes` отдельно
- Шаблоны нельзя редактировать или удалять, если на них ссылаются `backing`-файлы
- Масштабируемость — можно легко добавлять новые шаблоны и хранить их в разных
storage
- Создание `volumes` из шаблонов выполняется в модуле templates
