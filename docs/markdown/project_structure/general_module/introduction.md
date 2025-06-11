# Содержимое Модуля

Пример содержимого модуля «storage».

Обратите внимание на название корневой директории модуля, оно должно быть
коротким и емким.

Стоит также обратить внимание, что вспомогательные файлы вроде сервисов или
файла конфигурации не находятся в отдельных поддиректориях.

#### NOTE
В каждой директории и поддиректории присутствует файл \_\_init_\_.py.
Он не влияет на работу проекта, просто помогает интерпретатору понять, что
конкретная папка является пакетом. Останавливаться далее на этом не будем.

* storage
  : * adapters
      : * \_\_init_\_.py
        * orm.py
        * repository.py
        * serializer.py
    * domain
      : * remotefs
          : * \_\_init_\_.py
            * nfs.py
        * \_\_init_\_.py
        * base.py
        * manager.py
        * model.py
    * entrypoints
      : * \_\_init_\_.py
        * api.py
        * crud.py
        * schemas.py
    * service_layer
      : * \_\_init_\_.py
        * exceptions.py
        * manager.py
        * services.py
        * unit_of_work.py
    * \_\_init_\_.py
    * config.py
    * storage-core.service
    * storage-scheduler.service
