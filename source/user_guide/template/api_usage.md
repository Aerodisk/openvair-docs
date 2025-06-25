# API-документация модуля Template

**Базовый путь API:** Все ручки имеют префикс `/templates`.

---

### GET `/templates` — Получить список шаблонов

**Описание:**  
Возвращает пагинированный список всех шаблонов, доступных в системе.

**Параметры запроса:**  
- Поддерживается пагинация через стандартные параметры (`page`, `size` и др. через fastapi-pagination)
- Допустимы опциональные фильтры (например, по имени), если реализованы

**Ответ:**
- `status` — строка, статус ответа (`"success"` или `"error"`)
- `data` — объект пагинированного списка (см. пример)
    - Каждый элемент списка — шаблон с полями:
        - `id` (UUID) — уникальный идентификатор шаблона
        - `name` (str) — имя шаблона
        - `description` (str/optional) — описание шаблона
        - `tmp_format` (str) — формат диска (`qcow2`)
        - `storage_id` (UUID) — идентификатор хранилища
        - `is_backing` (bool) — является ли backing-образом
        - `created_at` (datetime, RFC3339) — дата/время создания
        - `status` (str) — статус (`available`, `creating`, `deleting`, `error`)

**Пример ответа:**
```json
{
  "status": "success",
  "data": {
    "items": [
      {
        "id": "a73f920b-d282-41e4-8ec1-6e6b89d3a9e7",
        "name": "ubuntu-template",
        "description": "Template for Ubuntu server deployments",
        "tmp_format": "qcow2",
        "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
        "is_backing": true,
        "created_at": "2024-05-28T10:45:21.000Z",
        "status": "available"
      }
    ],
    "total": 1,
    "page": 1,
    "size": 50,
    "pages": 1
  }
}
```

---

### GET `/templates/{template_id}` — Получить шаблон по ID

**Описание:**  
Возвращает подробную информацию о шаблоне по его идентификатору.

**Параметры пути:**
- `template_id` (UUID) — идентификатор шаблона

**Пример успешного ответа:**
```json
{
  "status": "success",
  "data": {
    "id": "a73f920b-d282-41e4-8ec1-6e6b89d3a9e7",
    "name": "ubuntu-template",
    "description": "Template for Ubuntu server deployments",
    "tmp_format": "qcow2",
    "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
    "is_backing": true,
    "created_at": "2024-05-28T10:45:21.000Z",
    "status": "available"
  }
}
```

---

### POST `/templates` — Создать новый шаблон

**Описание:**  
Создаёт новый шаблон на основе существующего тома.

**Тело запроса:**
- `name` (str, обяз.) — имя шаблона (пример: `"ubuntu-template"`)
- `description` (str, не обяз.) — описание (пример: `"Template for Ubuntu server deployments"`)
- `storage_id` (UUID, обяз.) — идентификатор хранилища (пример: `"c2f7b67e-92a3-41ea-b760-ef7785ebfcb9"`)
- `base_volume_id` (UUID, обяз.) — идентификатор исходного тома (пример: `"6d8e34e7-0ef3-4477-8b7e-7b7d4c3e5b91"`)
- `is_backing` (bool, обяз.) — использовать как backing-файл (пример: `true`)

**Пример тела запроса:**
```json
{
  "name": "ubuntu-template",
  "description": "Template for Ubuntu server deployments",
  "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
  "base_volume_id": "6d8e34e7-0ef3-4477-8b7e-7b7d4c3e5b91",
  "is_backing": true
}
```

**Пример успешного ответа (201 CREATED):**
```json
{
  "status": "success",
  "data": {
    "id": "a73f920b-d282-41e4-8ec1-6e6b89d3a9e7",
    "name": "ubuntu-template",
    "description": "Template for Ubuntu server deployments",
    "tmp_format": "qcow2",
    "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
    "is_backing": true,
    "created_at": "2024-05-28T10:45:21.000Z",
    "status": "creating"
  }
}
```

---

### PATCH `/templates/{template_id}` — Обновить шаблон

**Описание:**  
Позволяет изменить имя и/или описание шаблона.

**Параметры пути:**
- `template_id` (UUID) — идентификатор шаблона

**Тело запроса:**
- `name` (str, не обяз.) — новое имя шаблона (пример: `"ubuntu-template-renamed"`)
- `description` (str, не обяз.) — новое описание (пример: `"Updated description for Ubuntu template"`)

**Пример тела запроса:**
```json
{
  "name": "ubuntu-template-renamed",
  "description": "Updated description for Ubuntu template"
}
```

**Пример успешного ответа:**
```json
{
  "status": "success",
  "data": {
    "id": "a73f920b-d282-41e4-8ec1-6e6b89d3a9e7",
    "name": "ubuntu-template-renamed",
    "description": "Updated description for Ubuntu template",
    "tmp_format": "qcow2",
    "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
    "is_backing": true,
    "created_at": "2024-05-28T10:45:21.000Z",
    "status": "available"
  }
}
```

---

### DELETE `/templates/{template_id}` — Удалить шаблон

**Описание:**  
Удаляет шаблон по его идентификатору.

**Параметры пути:**
- `template_id` (UUID) — идентификатор шаблона

**Пример успешного ответа:**
```json
{
  "status": "success",
  "data": {
    "id": "a73f920b-d282-41e4-8ec1-6e6b89d3a9e7",
    "name": "ubuntu-template",
    "description": "Template for Ubuntu server deployments",
    "tmp_format": "qcow2",
    "storage_id": "c2f7b67e-92a3-41ea-b760-ef7785ebfcb9",
    "is_backing": true,
    "created_at": "2024-05-28T10:45:21.000Z",
    "status": "deleting"
  }
}
```

---

### Пример стандартного ответа об ошибке

```json
{
  "status": "error",
  "error": "Template not found"
}
```

---
