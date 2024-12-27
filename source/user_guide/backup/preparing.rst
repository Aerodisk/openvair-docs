###################
Подготовка к работе
###################

### Шаг 1: Настройка конфигурации

1. Обновите файл ``project_config.toml`` для добавления параметров резервного копирования:

   .. code-block:: toml

      [backup]
      type = "restic"
      repository = "s3:http://example.com/backups"
      password_file = "/path/to/password/file"

   Параметры, которые нужно настроить:
   - ``repository`` — URL вашего репозитория для хранения данных.
   - ``password_file`` — путь к файлу с паролем для шифрования данных.

2. Перезапустите системные сервисы, чтобы применить настройки:
   .. code-block:: bash

      sudo systemctl restart backup-domain.service
      sudo systemctl restart backup-service-layer.service
