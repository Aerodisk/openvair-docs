# Использование API

Функционал предоставляет следующие эндпоинты:

1. **Создание резервной копии**

   Отправьте запрос для создания резервной копии данных:
   - **Метод:** `POST`
   - **URL:** `/backup/`
   - **Пример ответа:**
   > ```json
   > {
   > "status": "success",
   > "data": {
   >     "snapshot_id": "018928e8598b5a266b871b4538d6ed509d5349b74da0cc87f1deab4f2560b2dd",
   >     "total_files_processed": 1,
   >     "files_new": 1,
   >     "files_changed": 0,
   >     "files_unmodified": 0,
   >     "data_added_packed": 6486
   > },
   > "error": null
   > }
   > ```
2. **Восстановление данных**

   Восстановите данные из снимка:
   - **Метод:** `POST`
   - **URL:** `/backup/restore`
   - **Параметры запроса:**
   > - `snapshot_id` — идентификатор снимка. По умолчанию - latest(последняя вресия бекапа), если не указать id снэпшота
   - **Пример запроса:**
     ```bash
     curl -X POST "http://yourserver/backup/restore?snapshot_id=abcd1234"
     ```
   - **Пример ответа:**
     ```json
     {
         "status": "success",
         "data": {
             "total_files": 3,
             "files_restored": 3,
             "files_skipped": 1,
             "total_bytes": null,
             "bytes_restored": null,
             "bytes_skipped": 32106
         },
         "error": null
     }
     ```
3. **Получение списка снимков**

   Получите список доступных снимков:
   - **Метод:** `GET`
   - **URL:** `/backup/`
   - **Пример ответа:**
   > ```json
   > {
   >     "status": "success",
   >     "data": [
   >         {
   >         "id": "018928e8598b5a266b871b4538d6ed509d5349b74da0cc87f1deab4f2560b2dd",
   >         "short_id": "018928e8",
   >         "time": "2024-12-28T12:55:29.041543655+03:00",
   >         "paths": [
   >             "/opt/aero/openvair/data/backup.sql",
   >             "/opt/aero/openvair/data/mnt"
   >         ],
   >         "hostname": "your_host_name",
   >         "username": "root"
   >         }
   >     ],
   >     "error": null
   > }
   > ```
4. **Инициализация репозитория**

   Инициализируйте новый репозиторий:
   - **Метод:** `POST`
   - **URL:** `/backup/repository`
   - **Пример тела запроса и ответа:** Не требуются. Инициализация происходит один раз, если прошла не успешно, то будет возвращена ошибка
