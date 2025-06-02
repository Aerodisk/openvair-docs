# DTO

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