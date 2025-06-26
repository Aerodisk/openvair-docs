# 📚 FAQ по структуре документации OpenVair

> Этот документ определяет, **где и какие типы документации хранить**  
> в проекте OpenVair (или любом подобном), чтобы поддерживать порядок,
> масштабируемость и предсказуемость для пользователей, разработчиков и
> контрибьюторов.

---

## Содержание

- [Руководство пользователя (User Guide)](#руководство-пользователя-user-guide)
- [Технические требования к модулю](#технические-требования-к-модулю)
- [Спецификация модуля](#спецификация-модуля)
- [Подход к тестированию модуля](#подход-к-тестированию-модуля)
- [Общие гайды по архитектуре и паттернам](#общие-гайды-по-архитектуре-и-паттернам)
- [Общие подходы к тестированию и процессам](#общие-подходы-к-тестированию-и-процессам)
- [Справочник / Reference](#справочник--reference)
- [Введение, быстрый старт, установка](#введение-быстрый-старт-установка)
- [Частые ошибки](#частые-ошибки)
- [Примеры структуры](#примеры-структуры)

---

## Руководство пользователя (User Guide)

- **Что:** Пошаговые инструкции, сценарии, FAQ, UI, описание пользовательских
  ошибок, как выполнять основные задачи.
- **Где:** `docs/user_guide/`
- **Примеры:**
    - `user_guide/index.md`
    - `user_guide/virtual_machines/index.md`
    - `user_guide/volumes/index.md`
    - `user_guide/backup.md`
    - `user_guide/faq.md`

---

## Технические требования к модулю

- **Что:** Ограничения, интерфейсы, сценарии, связи с другими модулями,
  требования к данным, API, ограничения, интеграционные детали.
- **Где:** `docs/reference/modules/<module>/tech_requirements.md`
- **Пример:**
    - `reference/modules/volume/tech_requirements.md`
    - `reference/modules/template/tech_requirements.md`

---

## Спецификация модуля

- **Что:** Описание внутренней архитектуры модуля, слоёв, бизнес-логики, API,
  схемы данных, структуры файлов, паттернов, ошибок.
- **Где:** `docs/reference/modules/<module>/specification.md`

---

## Подход к тестированию модуля

- **Что:** Как тестировать этот модуль: подход, сценарии, структура тестов,
  фикстуры, интеграция в CI.
- **Где:** `docs/reference/modules/<module>/tests_specification.md`

---

## Общие гайды по архитектуре и паттернам

- **Что:** Принципы DDD, описание архитектурных слоёв, общие шаблоны
  проектирования, устройство платформы.
- **Где:** `docs/architecture/`
- **Примеры:**
    - `architecture/index.md`
    - `architecture/general_terms.md`
    - `architecture/general_module/adapters.md`
    - и т.д.

---

## Общие подходы к тестированию и процессам

- **Что:** Как делать вклад в проект, best practices по тестам для всех,
  требования к процессу Pull/Merge Request, соглашения по стилю.
- **Где:** `docs/contributors/`
- **Примеры:**
    - `contributors/tests.md`
    - `contributors/general.md`
    - `contributors/docs_structure_faq.md` _(этот файл)_

---

## Справочник / Reference

- **Что:** Спецификации модулей, подробности API, схемы, все технические детали
  для разработчиков и архитекторов.
- **Где:** `docs/reference/`
- **Примеры:**
    - `reference/index.md`
    - `reference/api.md`
    - `reference/modules/volume/specification.md`

---

## Введение, быстрый старт, установка

- **Что:** Системные требования, назначение, как развернуть, как обновить,
  первый запуск.
- **Где:** `docs/getting_started/`
- **Примеры:**
    - `getting_started/index.md`
    - `getting_started/install.md`
    - `getting_started/update.md`

---

## Частые ошибки

- **Не помещайте технические требования к модулю в раздел архитектуры.**
- **Не смешивайте user_guide с reference — пользовательские сценарии отдельно от
  инженерных спецификаций.**
- **Не кладите тестовую документацию по модулю в contributors/tests.md — там
  только общий подход.**

---

## Примеры структуры

```text
docs/
  getting_started/
    index.md
    install.md
    update.md

  user_guide/
    index.md
    virtual_machines/
      index.md
      create.md
      ...
    volumes/
      index.md
      create.md
      ...
    backup.md
    faq.md

  reference/
    index.md
    api.md
    modules/
      volume/
        index.md
        tech_requirements.md
        specification.md
        tests_specification.md
      template/
        ...

  contributors/
    index.md
    general.md
    tests.md
    docs_structure_faq.md

  architecture/
    index.md
    general_terms.md
    general_module/
      adapters.md
      domain.md
      ...
```
