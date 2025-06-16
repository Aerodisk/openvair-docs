# Подключение Sentry

Sentry - это платформа для управления ошибками и мониторинга
производительности приложений. Ее основной целью является предоставление
разработчикам инструментов для выявления, отслеживания и реагирования на
ошибки и проблемы, возникающие в их приложениях в реальном времени.

## Регистрация аккаунта в Sentry

> 1. Перейдите по ссылке для регистрации на главной странице
>    проекта Sentry [https://sentry.io/welcome/](https://sentry.io/welcome/)

> ![image](_static/img/sentry/get_started1.png)
> 1. Заполните форму регистрации заполнив все поля

> ![image](_static/img/sentry/get_started2.png)
> 1. После успешной регистрации аккаунта переходите на страницу авторизации

> ![image](_static/img/sentry/sign_in.png)
> 1. Введите свой логин и пароль

> ![image](_static/img/sentry/password.png)

## Создание проекта Sentry

Создание проекта в Sentry - это первый шаг к тому, чтобы начать мониторинг
ошибок и проблем в вашем приложении. Вот пошаговая инструкция о том, как
создать проект в Sentry

> 1. Перейдите на вкладку Projects в боковом меню

> ![image](_static/img/sentry/create_project.png)
> 1. Выберите в качестве платформы FASTAPI и нажмите «Create Project»

> ![image](_static/img/sentry/create_project2.png)
> 1. Скопируйте значение в строке dsn (то, что внутри ковычек)

> ![image](_static/img/sentry/dsn_copy.png)
> 1. Откройте файл prject_config.toml в корне проекта и вставьте
>    скопированную строку в качестве значения переменной dsn

> ![image](_static/img/sentry/project_config_sentry.png)
> 1. Перезапустите приложение
>    : sudo systemctl restart web-app.service
> 2. Перейдите на влкадку Issues в боковом меню для просмотра событий

> ![image](_static/img/sentry/issues_page.png)

> Пример отловленой ошибки

> ![image](_static/img/sentry/issues_error.png)

> Детальный просмотр ошибки

> ![image](_static/img/sentry/issues_error_detail.png)
