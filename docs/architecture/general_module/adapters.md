# adapters

Директория, хранящая в себе реализацию взаимодействия с инфраструктурой проекта.
В типичном случае, с базой данных.

## orm.py

Здесь с помощью ORM-фреймворка реализуются объекты хранения в базе данных
и сущности ЯП, на которые будут «завязаны» данные из таблиц БД.
В принципе,
структура и назначение этого файла должны быть знакомы многим разработчикам.
Но чаще всего
в проектах с плоской структурой или проектах на базе MVC-фреймворках этот
файл называют «models.py». Мы осознано пошли на изменение его названия,
чтобы не пересекаться с понятиями «Моделей» из предметно-ориентированной
архитектуры.

> В проекте мы придерживаемся императивного стиля работы с объектами БД.
Это значит, что в ходе работы необходимо явно указывать объект, на который
будет произведен «маппинг» соответствующей сущности из БД и также явно
этот «маппинг» запустить.

### metadata

Инициализируем объект метаданных, информация из которого будет в дальнейшем
использована в миграциях.

```python
metadata = MetaData()
mapper_registry = registry(metadata=metadata)
```

### tables

Тут происходит описание структуры хранения данных в таблицах БД, включая
ключи связи таблиц друг с другом.

```python
storages = Table(
    'storages', mapper_registry.metadata,
    Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
    Column('name', String(60)),
    Column('description', String(255)),
    Column('storage_type', String(30), nullable=False),
    Column('initialized', Boolean, default=False),
    Column('status', String(30), nullable=False),
   )

storage_extra_specs = Table(
    'storage_extra_specs', mapper_registry.metadata,
    Column('id', Integer, primary_key=True),
    Column('key', String(60)),
    Column('value', String(155)),
    Column('storage_id', postgresql.UUID(as_uuid=True), ForeignKey('storages.id')),
)
```

### objects

Здесь создаются сущности ЯП, на которые в дальнейшем будет производиться
маппинг данных из БД, и которые, в свою очередь, и будут использоваться в работе проекта.

```python
class Storage:
    pass


class StorageExtraSpecs:
    """
    Table where data stores like a key value.
    If storage came with specs like ip: 0.0.0.0 and path: /nfs/data this specs
    will insert into table in current format:

    id    |    key    |    value    |    storage_id
    -----------------------------------------------
    1     |    ip     |   0.0.0.0   |    UUID(1)
    -----------------------------------------------
    2     |   path    |  /nfs/data  |    UUID(1)
    -----------------------------------------------
    """
    pass
```

### mapping

В конце файла должна присутствовать функция «start_mappers». Именно, с ее помощью,
осуществляется маппинг данных. Эта функция в дальнейшем запускается
сервисом-планировщиком.

```python
def start_mappers():

    mapper_registry.map_imperatively(
        Storage,
        storages,
        properties={
            'extra_specs': relationship(
                StorageExtraSpecs,
                backref='storage',
                uselist=True
            ),
        }
    )
    mapper_registry.map_imperatively(StorageExtraSpecs, storage_extra_specs)
```

## repository.py

В данном файле хранятся абстракции и реализации паттерна «Репозиторий».
Репозиторий необходим для выполнения базовых операций над данными таблицы.

### abstractions

Здесь описана абстракция репозитория, которая выполняет роль интерфейса для
конкретного репозитория, а также служит дальнейшей зависимостью на уровне сервисного слоя.
В данном абстрактном репозитории описаны базовые методы взаимодействия с
таблицами БД, очень схожие с принципом CRUD.

```python
class AbstractRepository(metaclass=abc.ABCMeta):
    def __init__(self):
        ...

# Storage

    def add(self, storage: Storage):
        self._add(storage)

    def get(self, storage_id: UUID) -> Storage:
        storage = self._get(storage_id)
        return storage

    def get_all(self) -> List:
        storages = self._get_all()
        return storages

    def delete(self, storage_id: UUID):
        self._delete(storage_id)

    @abc.abstractmethod
    def _add(self, storage: Storage):
        raise NotImplementedError

    @abc.abstractmethod
    def _get(self, storage_id: UUID) -> Storage:
        raise NotImplementedError

    @abc.abstractmethod
    def _get_all(self) -> List:
        raise NotImplementedError

    @abc.abstractmethod
    def _delete(self, specs):
        raise NotImplementedError

# StorageExtraSpecs

    def get_extra_specs(self, storage_id: UUID) -> StorageExtraSpecs:
        extra_specs = self._get_extra_specs(storage_id)
        return extra_specs

    def delete_extra_specs(self, storage_id: UUID):
        self._delete_extra_specs(storage_id)

    def filter_extra_specs(self, all: bool = True, **kwargs):
        extra_specs = self._filter_extra_specs(all, **kwargs)
        return extra_specs

    @abc.abstractmethod
    def _get_extra_specs(self, storage_id: UUID) -> StorageExtraSpecs:
        raise NotImplementedError

    @abc.abstractmethod
    def _delete_extra_specs(self, storage_id: UUID):
        raise NotImplementedError

    @abc.abstractmethod
    def _filter_extra_specs(self, all: bool, **kwargs):
        raise NotImplementedError
```

### realization

Тут создана конкретная реализация описанного выше абстрактного репозитория,
находящаяся в зависимости от фреймворка SQLAlchemy. Эту зависимость
необходимо отразить в названии.

```python
class SqlAlchemyRepository(AbstractRepository):

    def __init__(self, session):
        super(SqlAlchemyRepository, self).__init__()
        self.session = session

    def _add(self, storage: Storage):
        self.session.add(storage)

    def _get(self, storage_id: str) -> Storage:
        storage = (
            self.session.query(Storage)
            .options(joinedload(Storage.extra_specs))
            .filter_by(id=storage_id)
            .one()
        )
        return storage

    def _get_all(self):
        return (
            self.session.query(Storage)
            .options(joinedload(Storage.extra_specs))
            .all()
        )

    def _delete(self, storage_id: UUID):
        return (
            self.session.query(Storage)
            .filter_by(id=storage_id)
            .delete()
        )

    def _get_extra_specs(self, storage_id):
        specs = (
            self.session.query(StorageExtraSpecs)
            .filter_by(storage_id=storage_id)
            .all()
        )
        return specs

    def _delete_extra_specs(self, storage_id):
        return (
            self.session.query(StorageExtraSpecs)
            .filter_by(storage_id=storage_id)
            .delete()
        )

    def _filter_extra_specs(self, all: bool, **kwargs):
        if all:
            return (
                self.session.query(StorageExtraSpecs)
                .filter_by(**kwargs)
                .all()
            )
        else:
            return (
                self.session.query(StorageExtraSpecs)
                .filter_by(**kwargs)
                .first()
            )
```

## serializer.py

Код, отвечающий за сериализацию и десериализацию объектов, необходимую при передаче
информации между слоями приложения.

### abstraction

Интерфейс для дальнейшей реализации в конкретном сериализаторе.

```python
class AbstractDataSerializer(metaclass=abc.ABCMeta):

    @classmethod
    @abc.abstractmethod
    def to_domain(cls, storage: Storage) -> dict:
        ...

    @classmethod
    @abc.abstractmethod
    def to_db(cls, data: dict, orm_class=Storage):
        ...

    @classmethod
    @abc.abstractmethod
    def to_web(cls, storage) -> dict:
        ...
```

### realization

Конкретный сериализатор данных.

* to_domain - необходим для дальнейшей передачи в ядро модуля. Превращает структуру, полученных из БД данных, в плоский словарь.
* to_db - наоборот, создает структуру для дальнейшего сохранения в БД.
* to_web - создает удобную для валидации и передачи на фронтенд многоуровневую структуру.

```python
class DataSerializer(AbstractDataSerializer):

    @classmethod
    def to_domain(cls, storage: Storage) -> dict:
        """
        It takes a storage object,
        and a list of extra specs, and returns a dictionary of the storage
        object with the extra specs added to it

        Args:
          cls: The class that is being converted to a domain object.
          storage (Storage): Storage
          extra_specs: This is a list of dictionaries that contain the extra
            specs

        Returns:
          A dictionary of the storage object and the extra specs.
        """
        storage_dict = storage.__dict__.copy()
        storage_dict['id'] = str(storage_dict['id'])
        storage_dict.pop('_sa_instance_state')
        domain_extra_specs = []
        for spec in storage_dict.pop('extra_specs'):
            spec = spec.__dict__.copy()
            spec.pop('_sa_instance_state')
            domain_extra_specs.append(spec)
        # It's taking the dictionary of extra specs and adding them to the
        # storage_dict.
        storage_dict.update(**{
                    spec['key']: spec['value'] for spec in domain_extra_specs
                })
        return storage_dict

    @classmethod
    def to_db(cls, data: dict, orm_class=Storage):
        """
        It takes a dictionary and returns an object of the class Storage

        Args:
          cls: The class that we're converting to.
          data (dict): dict
          orm_class: db table
        Returns:
          The Storage class is being returned.
        """
        orm_dict = {}
        inspected_orm_class = inspect(orm_class)
        for column in list(inspected_orm_class.columns):
            column_name = column.__dict__['key']
            orm_dict[column_name] = data.get(column_name)
        return orm_class(**orm_dict)

    @classmethod
    def to_web(cls, storage) -> dict:
        """
        It takes a storage object,
        and a list of extra specs, and returns a dictionary of the storage
        object with the extra specs added to it

        Args:
          cls: The class of the object that is being converted.
          storage: The storage object that we're converting to a dictionary.

        Returns:
          A dictionary of the storage and extra specs.
        """
        storage_dict = storage.__dict__.copy()
        storage_dict['id'] = str(storage_dict['id'])
        storage_dict.pop('_sa_instance_state')
        web_extra_specs = []
        for spec in storage_dict.pop('extra_specs'):
            spec = spec.__dict__.copy()
            spec.pop('_sa_instance_state')
            web_extra_specs.append(spec)
        # It's taking the dictionary of extra specs and adding them to the
        # storage_dict.
        storage_dict.update(
            {
                'storage_extra_specs': {
                    spec['key']: spec['value'] for spec in web_extra_specs
                }
            }
        )
        return storage_dict
```

## DTO

DTO (Data Transfer Object) — классы, определяющие формат и тип передаваемых данных между слоями и модулями.
DTO обеспечивают валидацию, автодополнение и защиту от передачи лишних или невалидных данных, повышая безопасность и
удобство разработки.

Разделяются на внутренние(internal) и внешние(external).
Internal - используются для взаимодействий внутри модуля между слоями (API <-> Service <-> Domain)

Пример:
```
# класс содержит в себе поля, которые необходимо передать от API сервисному методу по RPC для созданию шаблона
class CreateTemplateServiceCommandDTO(BaseDTOModel):
    """DTO for creating a template at the service layer.

    Contains metadata required to register a new template in the system.

    Attributes:
        name (str): Name of the new template.
        description (Optional[str]): Optional description.
        storage_id (UUID): Storage where the template will be located.
        base_volume_id (UUID): ID of the volume used to create the template.
        is_backing (bool): Whether the template acts as a backing image.
    """

    name: str
    description: Optional[str]
    storage_id: UUID
    base_volume_id: UUID
    is_backing: bool
```

```
    def create_template(
        self, creation_data: RequestCreateTemplate
    ) -> TemplateResponse:
        """Create a new template using provided data via RPC.

        Args:
            creation_data (BaseModel): The template creation data.

        Returns:
            Template: The created template object.
        """
        LOG.info('Call service layer on creating new template.')

        creation_command = CreateTemplateServiceCommandDTO.model_validate(
            creation_data
        )
        result: Dict[str, Any] = self.service_layer_rpc.call(
            TemplateServiceLayerManager.create_template.__name__,
            data_for_method=creation_command.model_dump(mode='json'),
        )

        return TemplateResponse.model_validate(result)
```

В выше приведенном примере, структура CreateTemplateServiceCommandDTO соответствует схеме получаемой из api, поэтому
никаких иных специфичных действий, кроме валидации для последующей сериализации в json, не требуется.


Так же каждый тип DTO разделяется по назначению: Command и Model
Command - Классы отражающие набор полей, который нужен для методов(команд в контексте взаимодействия)
Model - Классы отражающие набор аргументов, для конструкторов конкретных объектов. Например те данные которые передаются
в data_for_manager для создания экземпляра доменного класс

```
class EditTemplateServiceCommandDTO(BaseDTOModel):
    """DTO for updating template fields at the service layer.

    Attributes:
        id (UUID): ID of the template to edit.
        name (Optional[str]): New name of the template (if provided).
        description (Optional[str]): New description (if provided).
    """

    id: UUID
    name: Optional[str] = Field(min_length=1, max_length=40)
    description: Optional[str]
```

Пример, когда схема апи отличается от dto
```
    def edit_template(
        self,
        template_id: UUID,
        edit_data: RequestEditTemplate,
    ) -> TemplateResponse:
        """Update an existing template using partial data via RPC.

        Args:
            template_id (UUID): The ID of the template to update.
            edit_data (BaseModel): The updated fields for the template.

        Returns:
            Template: The updated template object.
        """
        LOG.info(f'Call service layer on editing template {template_id}.')

        editing_command = EditTemplateServiceCommandDTO(
            id=template_id,
            name=edit_data.name,
            description=edit_data.description,
        )
        result: Dict[str, Any] = self.service_layer_rpc.call(
            TemplateServiceLayerManager.edit_template.__name__,
            data_for_method=editing_command.model_dump(mode='json'),
        )
        return TemplateResponse.model_validate(result)

```
Сервисному слою, необходим параметр id, который в api поступает как часть пути энтрипоинта, а не в схеме, поэтому нужно
произвести маппинг данных из схемы и id к целевому объекту dto для последующей сериализации


External - используются для взаимодействия между сервисными слоями разных модулей, описывая структуры данных модуля к
которому идёт обращение (Template <-> Storage) (Template <-> Volume)
Для получения конкретного экземпляра volume нужно передать его id(В данном примере всго одно поле и может показаться что
такая модель лишняя однако, при взаимодействии с другими методами разных сервисов, колличество полей может быть
существенно больше и чтобы придерживаться единого подхода, единого стиля написания и соблюдать инкапсуляцию, следует
реализовывать подобные модели)
```
class GetVolumeCommandDTO(BaseDTOModel):
    """DTO for querying a volume by its ID.

    This model is used to create a JSON-serializable payload for RPC calls
    that require a volume identifier. It leverages the JSON encoders defined
    in DTOConfig to automatically convert UUID values to strings.

    Attributes:
        volume_id (UUID): Unique identifier of the volume.

    Example:
        >>> from uuid import UUID
        >>> query = VolumeQuery(volume_id=UUID('123e4567-e89b-12d3-a456-426614174000'))
        >>> payload = query.model_dump(mode='json')
        >>> print(payload)  # {'volume_id': '123e4567-e89b-12d3-a456-426614174000'}
    """  # noqa: E501

    volume_id: UUID
```

И в model мы описываем структуру данных, которая будет получена в ответ от модуля volume
```python
class VolumeModelDTO(BaseDTOModel):
    """Schema representing a volume.

    Attributes:
        id (UUID): The ID of the volume.
        name (str): The name of the volume.
        description (Optional[str]): A description of the volume.
        storage_id (Optional[UUID]): The ID of the storage the volume belongs
            to.
        user_id (Optional[UUID]): The ID of the user who owns the volume.
        format (str): The format of the volume (e.g., qcow2, raw).
        size (int): The size of the volume in bytes.
        used (Optional[int]): The amount of space used in the volume.
        status (Optional[str]): The status of the volume.
        information (Optional[str]): Additional information about the volume.
        attachments (List[Optional[Attachment]]): A list of attachments for the
            volume.
        read_only (Optional[bool]): Whether the volume is read-only.
    """

    id: UUID
    name: str
    description: Optional[str] = None
    storage_id: Optional[UUID] = None
    user_id: Optional[UUID] = None
    format: Literal['qcow2', 'raw']
    size: int
    used: Optional[int] = None
    status: Optional[str] = None
    information: Optional[str] = None
    read_only: Optional[bool] = False
    path: Path
    template_id: Optional[UUID]

```

во внутренних моделях описывает составл аргументов для доменной модели, то что мы возвращаем в api, сервисный слой обычно отражает orm модель однако, специфичная для него модель так же присутствует - это модель c префиксом Create, т.к. на стадии создания в орм еще не существует целевой объект
```python
class ApiTemplateModelDTO(BaseDTOModel):
    """DTO used to represent a template in the API layer.

    Attributes:
        id (UUID): Unique ID of the template.
        name (str): Name of the template.
        description (Optional[str]): Optional description.
        path (Path): Filesystem path to the template image.
        tmp_format (str): Disk format (e.g., qcow2, raw).
        size (int): Size of the template in bytes.
        status (TemplateStatus): Lifecycle status of the template.
        is_backing (bool): Whether this template is used as a backing image.
        created_at (datetime): Time of creation.
        storage_id (UUID): Associated storage ID.
    """

    id: UUID
    name: str
    description: Optional[str]
    path: Path
    tmp_format: str
    size: int
    status: TemplateStatus
    is_backing: bool
    created_at: datetime
    storage_id: UUID


class DomainTemplateModelDTO(BaseDTOModel):
    """DTO for domain logic operations on templates.

    Attributes:
        tmp_format (str): Disk format of the template.
        name (str): Template name.
        path (Path): Full filesystem path to the image.
        related_volumes (Optional[List]): Volumes using this template.
        is_backing (bool): Whether this template is a backing image.
        description (str): Description of the template.
    """

    tmp_format: str
    name: str
    path: Path
    related_volumes: Optional[List] = None
    is_backing: bool
    description: str


class CreateTemplateModelDTO(BaseDTOModel):
    """DTO for creating a new template from service logic.

    Attributes:
        name (str): Name of the new template.
        description (Optional[str]): Description of the template.
        path (Path): Filesystem path for the template image.
        tmp_format (Literal['qcow2', 'raw']): Disk format.
        storage_id (UUID): Associated storage.
        is_backing (bool): Whether this is a backing image.
    """

    name: str
    description: Optional[str]
    path: Path
    tmp_format: Literal['qcow2', 'raw']
    storage_id: UUID
    is_backing: bool

```