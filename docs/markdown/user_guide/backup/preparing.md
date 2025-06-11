# Подготовка к работе

### Шаг 1: Настройка конфигурации

1. Обновите файл `project_config.toml` для добавления параметров резервного копирования:
   ```toml
   [backup]
       backuper = 'restic'
       [backup.restic]
       repository = '/srv/restic_repo'
       password = 'your_password'
   ```

   Параметры, которые нужно настроить:
   - `repository` — URL вашего репозитория для хранения данных.
   - `password_file` — пароль, который будет использоваться для доступа к репозиторию
2. Перезапустите системные сервисы, чтобы применить настройки:
   ```bash
   sudo systemctl restart backup-service-layer.service backup-domain.service
   ```
