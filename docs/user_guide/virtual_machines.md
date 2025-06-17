# Модуль Virtual Machines

Модуль Virtual Machines (виртуальные машины) предоставляет возможность
управления виртуальными машинами через REST API. Он предоставляет набор
эндпоинтов для создания, удаления, запуска и остановки виртуальных машин,
а также для получения информации о них.

Этот модуль позволяет пользователям эффективно управлять виртуальными
машинами в среде виртуализации, обеспечивая гибкость и удобство в работе с ними.

Важно отметить, что в качестве инструмента виртуализации используется [KVM
(Kernel-based Virtual Machine)](https://linux-kvm.org/), а в качестве
гипервизора - [QEMU](https://www.qemu.org/).

Этот модуль предоставляет API для управления виртуальными машинами.

## API

## **Получение списка виртуальных машин**

```bash
GET /virtual-machines/
```

Этот эндпоинт возвращает список всех виртуальных машин.

## **Получение информации о виртуальной машине**

```bash
GET /virtual-machines/{vm_id}/
```

Этот эндпоинт возвращает информацию о конкретной виртуальной машине по её
идентификатору.

## **Создание виртуальной машины**

```bash
POST /virtual-machines/create/
```

Этот эндпоинт создает новую виртуальную машину.

> **Пример запроса**:

> ```bash
> curl -X POST \
> http://your-api-endpoint/virtual-machines/create/ \
> -H 'Content-Type: application/json' \
> -d '{
>     "name": "string",
>     "description": "string",
>     "os": {
>         "os_type": "Linux",
>         "os_variant": "Ubuntu 20.04",
>         "boot_device": "cdrom",
>         "bios": "LEGACY",
>         "graphic_driver": "virtio"
>     },
>     "cpu": {
>         "cores": 1,
>         "threads": 1,
>         "sockets": 1,
>         "model": "host",
>         "type": "static",
>         "vcpu": "string"
>     },
>     "ram": {
>         "size": 0
>     },
>     "graphic_interface": {
>         "login": "string",
>         "password": "string",
>         "connect_type": "vnc"
>     },
>     "disks": {
>         "attach_disks": [
>             {
>                 "name": "string",
>                 "emulation": "virtio",
>                 "format": "qcow2",
>                 "qos": {
>                     "iops_read": "500",
>                     "iops_write": "500",
>                     "mb_read": "150",
>                     "mb_write": "150"
>                 },
>                 "boot_order": 0,
>                 "order": 0,
>                 "volume_id": "string"
>             },
>             {
>                 "name": "string",
>                 "emulation": "virtio",
>                 "format": "qcow2",
>                 "qos": {
>                     "iops_read": "500",
>                     "iops_write": "500",
>                     "mb_read": "150",
>                     "mb_write": "150"
>                 },
>                 "boot_order": 0,
>                 "order": 0,
>                 "image_id": "string"
>             },
>             {
>                 "name": "string",
>                 "emulation": "virtio",
>                 "format": "qcow2",
>                 "qos": {
>                     "iops_read": "500",
>                     "iops_write": "500",
>                     "mb_read": "150",
>                     "mb_write": "150"
>                 },
>                 "boot_order": 0,
>                 "order": 0,
>                 "storage_id": "string",
>                 "size": 0
>             }
>         ]
>     },
>     "virtual_interfaces": [
>         {
>             "mode": "bridge",
>             "interface": "br0",
>             "mac": "6C:4A:74:B4:FD:59",
>             "model": "virtio",
>             "order": 0
>         }
>     ]
> }'
> ```

## **Удаление виртуальной машины**

```bash
DELETE /virtual-machines/{vm_id}/
```

Этот эндпоинт удаляет виртуальную машину по её идентификатору.

## **Запуск виртуальной машины**

```bash
POST /virtual-machines/{vm_id}/start/
```

Этот эндпоинт запускает виртуальную машину по её идентификатору.

## **Остановка виртуальной машины**

```bash
POST /virtual-machines/{vm_id}/shut-off/
```

Этот эндпоинт останавливает виртуальную машину по её идентификатору.

## **Редактирование виртуальной машины**

**Пример запроса**:

```bash
curl -X POST \
http://your-api-endpoint/virtual-machines/{vm_id}/edit/ \
-H 'Content-Type: application/json' \
-d '{
    "name": "edited_vm_name",
    "description": "edited_vm_description",
    "cpu": {
        "cores": 2,
        "threads": 2,
        "sockets": 2,
        "model": "host",
        "type": "static",
        "vcpu": "edited_vcpu"
    },
    "ram": {
        "size": 2048
    },
    "os": {
        "os_type": "Linux",
        "os_variant": "Ubuntu 20.04",
        "boot_device": "cdrom",
        "bios": "LEGACY",
        "graphic_driver": "virtio"
    },
    "graphic_interface": {
        "login": "edited_login",
        "password": "edited_password",
        "connect_type": "vnc"
    },
    "disks": {
        "attach_disks": [
            {
                "name": "edited_disk_name",
                "emulation": "virtio",
                "format": "qcow2",
                "qos": {
                    "iops_read": "500",
                    "iops_write": "500",
                    "mb_read": "150",
                    "mb_write": "150"
                },
                "boot_order": 0,
                "order": 0,
                "volume_id": "edited_volume_id"
            }
        ],
        "detach_disks": [
            {
                "id": 0
            }
        ],
        "edit_disks": [
            {
                "name": "edited_disk_name",
                "emulation": "virtio",
                "format": "qcow2",
                "qos": {
                    "iops_read": "500",
                    "iops_write": "500",
                    "mb_read": "150",
                    "mb_write": "150"
                },
                "boot_order": 0,
                "order": 0,
                "id": 0
            }
        ]
    },
    "virtual_interfaces": {
        "new_virtual_interfaces": [
            {
                "mode": "bridge",
                "interface": "edited_br0",
                "mac": "6C:4A:74:B4:FD:59",
                "model": "virtio",
                "order": 0
            }
        ],
        "detach_virtual_interfaces": [
            {
                "id": 0
            }
        ],
        "edit_virtual_interfaces": [
            {
                "mode": "bridge",
                "interface": "edited_br0",
                "mac": "6C:4A:74:B4:FD:59",
                "model": "virtio",
                "order": 0,
                "id": 0
            }
        ]
    }
}'
```

## Сценарии использования

### Создание виртуальной машины

1. Перейдите во вкладку «Виртуализация», «ВМ (Виртуальные машины)» и
   нажмите на кнопку «Создать»:
   ![image](../_assets/images/virtual_machines/create/0_create.png)

2. Во кладке «Настройки» укажите имя для создаваемой ВМ, а так же
   установите нужные Вам компоненты загрузки.
   Для создания ВМ из образа необходимо выставить параметр «Загрузочное
   устройство»
   как «CDROM». После установки установить данный параметр как «HD»:
   ![image](../_assets/images/virtual_machines/create/1_create_tab1.png)

3. Перейдите во вкладку «Настройки ЦПУ/ОЗУ» и выставите нужные Вам значения
   параметров:
   ![image](../_assets/images/virtual_machines/create/1_create_tab2.png)

4. Перейдите во вкладку «Диски» и нажмите на кнопку «Добавить диск»:
   ![image](../_assets/images/virtual_machines/create/1_create_tab3_1.png)
   В открывшемся модальном окне можно выбрать уже созданый ранее диск, либо
   создать новый диск, выбрав соответствующий параметр. В данном примере
   выберем уже созданный ранее диск:
   ![image](../_assets/images/virtual_machines/create/1_create_tab3_2.png)
   Выбираем нужный нам диск из таблицы (можно выбрать несколько). Поля «Тип
   хранилища»
   и «Подтип хранилища» служат в качестве фильтров, для отображения нужных
   нам дисков, на тот случай, если дисков много:
   ![image](../_assets/images/virtual_machines/create/1_create_tab3_3.png)
   Видим что в таблице отобразился выбранный диск:
   ![image](../_assets/images/virtual_machines/create/1_create_tab3_4.png)

5. Перейдите во вкладку «Виртуальные образы» и нажмите на кнопку
   «Добавить ВО»:
   ![image](../_assets/images/virtual_machines/create/1_create_tab4_1.png)
   В открывшемся модальном окне выберите нужный образ:
   ![image](../_assets/images/virtual_machines/create/1_create_tab4_2.png)
   Видим что выбранный образ отобразился в таблице:
   ![image](../_assets/images/virtual_machines/create/1_create_tab4_3.png)

6. Перейдите во вкладку «Сеть» и нажмите на кнопку «Выбрать сеть»:
   ![image](../_assets/images/virtual_machines/create/1_create_tab5_1.png)
   Выберите нужную сеть из списка (можно выбрать несколько) и нажмите
   кнопку «Добавить»:
   ![image](../_assets/images/virtual_machines/create/1_create_tab5_2.png)
   Видим что выбранная сеть отобразилась в таблице. Жмем на кнопку «Создать»
   для завершения процесса создания ВМ:
   ![image](../_assets/images/virtual_machines/create/1_create_tab5_3.png)

7. Видим что новая виртуальная машина успешно создалась:
   ![image](../_assets/images/virtual_machines/create/2_create_complite.png)

### Удаление виртуальной машины

1. В таблице виртуальных машин, в строке ВМ, которую хотите удалить, нажмите на
   «три точки»
   и нажмите на появившуюся иконку «Удалить»:
   ![image](../_assets/images/virtual_machines/delete/0_delete.png)

2. В появившемся модальном окне подтверждения удаления нажмите на кнопку
   «Удалить»:
   ![image](../_assets/images/virtual_machines/delete/1_delete_confirm.png)

3. Видим что удаленная ВМ больше не отображается в таблице виртуальных машин:
   ![image](../_assets/images/virtual_machines/delete/3_delete_done.png)

### Запуск виртуальной машины

1. В строке таблицы виртуальных машин нажмите на «три точки» той ВМ, которую
   хотите запустить, и нажмите на появившуюся иконку «Запустить»:
   ![image](../_assets/images/virtual_machines/start/0_start.png)

2. В появившемся модальном окне нажмите на кнопку «Запустить»:
   ![image](../_assets/images/virtual_machines/start/1_start_modal.png)

3. Видим что в столбце «Питание» статус поменялся с «shut_off» на «running».
   Так же если нажать на «три точки» в строке с запущенной ВМ можно увидеть
   что появились две новые иконки: «VNC клиент» и «Выключить»:
   ![image](../_assets/images/virtual_machines/start/2_running.png)

4. При нажатии на иконку «VNC клиент» в браузере откроется новая вкладка
   с VNC доступом к ВМ:
   ![image](../_assets/images/virtual_machines/start/3_vnc.png)
   при нажатии на кнопку «Подключение» попадаем в виртуальную машину:
   ![image](../_assets/images/virtual_machines/start/4_install_window.png)

### Выключение виртуальной машины

1. Для выключения ВМ жмем на иконку «Выключить»:
   ![image](../_assets/images/virtual_machines/start/2_running.png)

2. В появившемся модальном окне жмем на кнопку «Выключить»:

![image](../_assets/images/virtual_machines/shut_off/0_shut_off.png)
Видим что статус ВМ сменился с «running» на «shut_off»:
![image](../_assets/images/virtual_machines/shut_off/1_shut_off.png)
Виртуальная машина выключена.

### Редактирование ВМ

Допустим мы хотим сменить имя виртуальной машины с «VM1» на «NEW_VM_NAME»,
выставить загрузочное устройство вместо «CDROM» на «HD», а так же увеличить
объем оперативной памяти до 4ГБ.

1. В строке ВМ, которую хотим изменить, нажимаем на «три точки» и нажимаем
   на появившуюся иконку «Изменить»:

> Для того, чтобы редактировать ВМ, она должна быть выключена.

![image](../_assets/images/virtual_machines/edit/0_edit.png)

1. Во вкладке «Настройки» меняем имя и загрузочное устройство:
   ![image](../_assets/images/virtual_machines/edit/1_edit_name.png)

2. Во вкладке «Настройки ЦПУ/ОЗУ» увеличиваем размер оперативной памяти до 4ГБ
   и нажимаем на кнопку «Сохранить»:
   ![image](../_assets/images/virtual_machines/edit/2_edit_ram.png)

3. Видим что имя и количество оперативной памяти изменилось:
   ![image](../_assets/images/virtual_machines/edit/3_done.png)
