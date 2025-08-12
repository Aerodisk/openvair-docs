# Содержимое Модуля

Пример содержимого модуля «storage».

Обратите внимание на название корневой директории модуля, оно должно быть
коротким и емким.

Стоит также обратить внимание, что вспомогательные файлы вроде сервисов или
файла конфигурации не находятся в отдельных поддиректориях.

>В каждой директории и поддиректории присутствует файл \_\_init_\_.py.
Он не влияет на работу проекта, просто помогает интерпретатору понять, что
конкретная папка является пакетом. Останавливаться далее на этом не будем.



```
openvair/modules/storage/
├── adapters
│     ├── exceptions.py
│     ├── __init__.py
│     ├── orm.py
│     ├── parted.py
│     ├── repository.py
│     └── serializer.py
├── config.py
├── domain
│     ├── base.py
│     ├── exception.py
│     ├── __init__.py
│     ├── manager.py
│     ├── model.py
│     ├── physical_fs
│     │     ├── exceptions.py
│     │     ├── __init__.py
│     │     └── localfs.py
│     ├── remotefs
│     │     ├── exceptions.py
│     │     ├── __init__.py
│     │     └── nfs.py
│     └── utils.py
├── entrypoints
│     ├── api.py
│     ├── crud.py
│     ├── __init__.py
│     └── schemas.py
├── __init__.py
├── libs
│     └── utils.py
├── service_layer
│     ├── exceptions.py
│     ├── __init__.py
│     ├── manager.py
│     ├── services.py
│     └── unit_of_work.py
├── storage-domain.service
└── storage-service-layer.service
```

