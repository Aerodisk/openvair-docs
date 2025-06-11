# Сценарии использования

## Создание виртуальной машины

> 1. Перейдите во вкладку «Виртуализация», «ВМ (Виртуальные машины)» и
>    нажмите на кнопку «Создать»:

> ![image](_static/img/virtual_machines/create/0_create.png)
> 1. Во кладке «Настройки» укажите имя для создаваемой ВМ, а так же
>    установите нужные Вам компоненты загрузки.

>    #### IMPORTANT
>    Для создания ВМ из образа необходимо выставить параметр «Загрузочное устройство»
>    как «CDROM». После установки установить данный параметр как «HD»:

> ![image](_static/img/virtual_machines/create/1_create_tab1.png)
> 1. Перейдите во вкладку «Настройки ЦПУ/ОЗУ» и выставите нужные Вам значения
>    параметров:

> ![image](_static/img/virtual_machines/create/1_create_tab2.png)
> 1. Перейдите во вкладку «Диски» и нажмите на кнопку «Добавить диск»:

> ![image](_static/img/virtual_machines/create/1_create_tab3_1.png)

> В открывшемся модальном окне можно выбрать уже созданый ранее диск, либо
> создать новый диск, выбрав соответствующий параметр. В данном примере
> выберем уже созданный ранее диск:

> ![image](_static/img/virtual_machines/create/1_create_tab3_2.png)

> Выбираем нужный нам диск из таблицы (можно выбрать несколько). Поля «Тип хранилища»
> и «Подтип хранилища» служат в качестве фильтров, для отображения нужных
> нам дисков, на тот случай, если дисков много:

> ![image](_static/img/virtual_machines/create/1_create_tab3_3.png)

> Видим что в таблице отобразился выбранный диск:

> ![image](_static/img/virtual_machines/create/1_create_tab3_4.png)
> 1. Перейдите во вкладку «Виртуальные образы» и нажмите на кнопку
>    «Добавить ВО»:

> ![image](_static/img/virtual_machines/create/1_create_tab4_1.png)

> В открывшемся модальном окне выберите нужный образ:

> ![image](_static/img/virtual_machines/create/1_create_tab4_2.png)

> Видим что выбранный образ отобразился в таблице:

> ![image](_static/img/virtual_machines/create/1_create_tab4_3.png)
> 1. Перейдите во вкладку «Сеть» и нажмите на кнопку «Выбрать сеть»:

> ![image](_static/img/virtual_machines/create/1_create_tab5_1.png)

> Выберите нужную сеть из списка (можно выбрать несколько) и нажмите
> кнопку «Добавить»:

> ![image](_static/img/virtual_machines/create/1_create_tab5_2.png)

> Видим что выбранная сеть отобразилась в таблице. Жмем на кнопку «Создать»
> для завершения процесса создания ВМ:

> ![image](_static/img/virtual_machines/create/1_create_tab5_3.png)
> 1. Видим что новая виртуальная машина успешно создалась:

> ![image](_static/img/virtual_machines/create/2_create_complite.png)

## Удаление виртуальной машины

> 1. В таблице виртуальных машин, в строке ВМ, которую хотите удалить, нажмите на «три точки»
>    и нажмите на появившуюся иконку «Удалить»:

> ![image](_static/img/virtual_machines/delete/0_delete.png)
> 1. В появившемся модальном окне подтверждения удаления нажмите на кнопку «Удалить»:

> ![image](_static/img/virtual_machines/delete/1_delete_confirm.png)
> 1. Видим что удаленная ВМ больше не отображается в таблице виртуальных машин:

> ![image](_static/img/virtual_machines/delete/3_delete_done.png)

## Запуск виртуальной машины

> 1. В строке таблицы виртуальных машин нажмите на «три точки» той ВМ, которую
>    хотите запустить, и нажмите на появившуюся иконку «Запустить»:

> ![image](_static/img/virtual_machines/start/0_start.png)
> 1. В появившемся модальном окне нажмите на кнопку «Запустить»:

> ![image](_static/img/virtual_machines/start/1_start_modal.png)
> 1. Видим что в столбце «Питание» статус поменялся с «shut_off» на «running».
>    Так же если нажать на «три точки» в строке с запущенной ВМ можно увидеть
>    что появились две новые иконки: «VNC клиент» и «Выключить»:

> ![image](_static/img/virtual_machines/start/2_running.png)
> 1. При нажатии на иконку «VNC клиент» в браузере откроется новая вкладка
>    с VNC доступом к ВМ:

> ![image](_static/img/virtual_machines/start/3_vnc.png)

> при нажатии на кнопку «Подключение» попадаем в виртуальную машину:

> ![image](_static/img/virtual_machines/start/4_install_window.png)

## Выключение виртуальной машины

> 1. Для выключения ВМ жмем на иконку «Выключить»:

> ![image](_static/img/virtual_machines/start/2_running.png)
> 1. В появившемся модальном окне жмем на кнопку «Выключить»:

> ![image](_static/img/virtual_machines/shut_off/0_shut_off.png)

> Видим что статус ВМ сменился с «running» на «shut_off»:

> ![image](_static/img/virtual_machines/shut_off/1_shut_off.png)

> Виртуальная машина выключена.

## Редактирование ВМ

> Допустим мы хотим сменить имя виртуальной машины с «VM1» на «NEW_VM_NAME»,
> выставить загрузочное устройство вместо «CDROM» на «HD», а так же увеличить
> объем оперативной памяти до 4ГБ.

> 1. В строке ВМ, которую хотим изменить, нажимаем на «три точки» и нажимаем
>    на появившуюся иконку «Изменить»:

>    #### IMPORTANT
>    Для того, чтобы редактировать ВМ, она должна быть выключена.

> ![image](_static/img/virtual_machines/edit/0_edit.png)
> 1. Во вкладке «Настройки» меняем имя и загрузочное устройство:

> ![image](_static/img/virtual_machines/edit/1_edit_name.png)
> 1. Во вкладке «Настройки ЦПУ/ОЗУ» увеличиваем размер оперативной памяти до 4ГБ
>    и нажимаем на кнопку «Сохранить»:

> ![image](_static/img/virtual_machines/edit/2_edit_ram.png)
> 1. Видим что имя и количество оперативной памяти изменилось:

> ![image](_static/img/virtual_machines/edit/3_done.png)
