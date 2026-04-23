# Дипломная работа по профессии «Системный администратор» - Селиванов Сергей Сергеевич

<details>

<summary>Задание</summary>

Содержание
==========
* [Задача](#Задача)
* [Инфраструктура](#Инфраструктура)
    * [Сайт](#Сайт)
    * [Мониторинг](#Мониторинг)
    * [Логи](#Логи)
    * [Сеть](#Сеть)
    * [Резервное копирование](#Резервное-копирование)
    * [Дополнительно](#Дополнительно)
* [Выполнение работы](#Выполнение-работы)
* [Критерии сдачи](#Критерии-сдачи)
* [Как правильно задавать вопросы дипломному руководителю](#Как-правильно-задавать-вопросы-дипломному-руководителю) 

---------

## Задача
Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных. Инфраструктура должна размещаться в [Yandex Cloud](https://cloud.yandex.com/) и отвечать минимальным стандартам безопасности: запрещается выкладывать токен от облака в git. Используйте [инструкцию](https://cloud.yandex.ru/docs/tutorials/infrastructure-management/terraform-quickstart#get-credentials).

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

## Инфраструктура
Для развёртки инфраструктуры используйте Terraform и Ansible.  

Не используйте для ansible inventory ip-адреса! Вместо этого используйте fqdn имена виртуальных машин в зоне ".ru-central1.internal". Пример: example.ru-central1.internal  - для этого достаточно при создании ВМ указать name=example, hostname=examle !! 

Важно: используйте по-возможности **минимальные конфигурации ВМ**:2 ядра 20% Intel ice lake, 2-4Гб памяти, 10hdd, прерываемая. 

**Так как прерываемая ВМ проработает не больше 24ч, перед сдачей работы на проверку дипломному руководителю сделайте ваши ВМ постоянно работающими.**

Ознакомьтесь со всеми пунктами из этой секции, не беритесь сразу выполнять задание, не дочитав до конца. Пункты взаимосвязаны и могут влиять друг на друга.

### Сайт
Создайте две ВМ в разных зонах, установите на них сервер nginx, если его там нет. ОС и содержимое ВМ должно быть идентичным, это будут наши веб-сервера.

Используйте набор статичных файлов для сайта. Можно переиспользовать сайт из домашнего задания.

Виртуальные машины не должны обладать внешним Ip-адресом, те находится во внутренней сети. Доступ к ВМ по ssh через бастион-сервер. Доступ к web-порту ВМ через балансировщик yandex cloud.

Настройка балансировщика:

1. Создайте [Target Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/target-group), включите в неё две созданных ВМ.

2. Создайте [Backend Group](https://cloud.yandex.com/docs/application-load-balancer/concepts/backend-group), настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

3. Создайте [HTTP router](https://cloud.yandex.com/docs/application-load-balancer/concepts/http-router). Путь укажите — /, backend group — созданную ранее.

4. Создайте [Application load balancer](https://cloud.yandex.com/en/docs/application-load-balancer/) для распределения трафика на веб-сервера, созданные ранее. Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

Протестируйте сайт
`curl -v <публичный IP балансера>:80` 

### Мониторинг
Создайте ВМ, разверните на ней Zabbix. На каждую ВМ установите Zabbix Agent, настройте агенты на отправление метрик в Zabbix. 

Настройте дешборды с отображением метрик, минимальный набор — по принципу USE (Utilization, Saturation, Errors) для CPU, RAM, диски, сеть, http запросов к веб-серверам. Добавьте необходимые tresholds на соответствующие графики.

### Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch.

### Сеть
Разверните один VPC. Сервера web, Elasticsearch поместите в приватные подсети. Сервера Zabbix, Kibana, application load balancer определите в публичную подсеть.

Настройте [Security Groups](https://cloud.yandex.com/docs/vpc/concepts/security-groups) соответствующих сервисов на входящий трафик только к нужным портам.

Настройте ВМ с публичным адресом, в которой будет открыт только один порт — ssh.  Эта вм будет реализовывать концепцию  [bastion host]( https://cloud.yandex.ru/docs/tutorials/routing/bastion) . Синоним "bastion host" - "Jump host". Подключение  ansible к серверам web и Elasticsearch через данный bastion host можно сделать с помощью  [ProxyCommand](https://docs.ansible.com/ansible/latest/network/user_guide/network_debug_troubleshooting.html#network-delegate-to-vs-proxycommand) . Допускается установка и запуск ansible непосредственно на bastion host.(Этот вариант легче в настройке)

Исходящий доступ в интернет для ВМ внутреннего контура через [NAT-шлюз](https://yandex.cloud/ru/docs/vpc/operations/create-nat-gateway).

### Резервное копирование
Создайте snapshot дисков всех ВМ. Ограничьте время жизни snaphot в неделю. Сами snaphot настройте на ежедневное копирование.

### Дополнительно
Не входит в минимальные требования. 

1. Для Zabbix можно реализовать разделение компонент - frontend, server, database. Frontend отдельной ВМ поместите в публичную подсеть, назначте публичный IP. Server поместите в приватную подсеть, настройте security group на разрешение трафика между frontend и server. Для Database используйте [Yandex Managed Service for PostgreSQL](https://cloud.yandex.com/en-ru/services/managed-postgresql). Разверните кластер из двух нод с автоматическим failover.
2. Вместо конкретных ВМ, которые входят в target group, можно создать [Instance Group](https://cloud.yandex.com/en/docs/compute/concepts/instance-groups/), для которой настройте следующие правила автоматического горизонтального масштабирования: минимальное количество ВМ на зону — 1, максимальный размер группы — 3.
3. В Elasticsearch добавьте мониторинг логов самого себя, Kibana, Zabbix, через filebeat. Можно использовать logstash тоже.
4. Воспользуйтесь Yandex Certificate Manager, выпустите сертификат для сайта, если есть доменное имя. Перенастройте работу балансера на HTTPS, при этом нацелен он будет на HTTP веб-серверов.

## Выполнение работы
На этом этапе вы непосредственно выполняете работу. При этом вы можете консультироваться с руководителем по поводу вопросов, требующих уточнения.

⚠️ В случае недоступности ресурсов Elastic для скачивания рекомендуется разворачивать сервисы с помощью docker контейнеров, основанных на официальных образах.

**Важно**: Ещё можно задавать вопросы по поводу того, как реализовать ту или иную функциональность. И руководитель определяет, правильно вы её реализовали или нет. Любые вопросы, которые не освещены в этом документе, стоит уточнять у руководителя. Если его требования и указания расходятся с указанными в этом документе, то приоритетны требования и указания руководителя.

## Критерии сдачи
1. Инфраструктура отвечает минимальным требованиям, описанным в [Задаче](#Задача).
2. Предоставлен доступ ко всем ресурсам, у которых предполагается веб-страница (сайт, Kibana, Zabbix).
3. Для ресурсов, к которым предоставить доступ проблематично, предоставлены скриншоты, команды, stdout, stderr, подтверждающие работу ресурса.
4. Работа оформлена в отдельном репозитории в GitHub или в [Google Docs](https://docs.google.com/), разрешён доступ по ссылке. 
5. Код размещён в репозитории в GitHub.
6. Работа оформлена так, чтобы были понятны ваши решения и компромиссы. 
7. Если использованы дополнительные репозитории, доступ к ним открыт. 

## Как правильно задавать вопросы дипломному руководителю
Что поможет решить большинство частых проблем:
1. Попробовать найти ответ сначала самостоятельно в интернете или в материалах курса и только после этого спрашивать у дипломного руководителя. Навык поиска ответов пригодится вам в профессиональной деятельности.
2. Если вопросов больше одного, присылайте их в виде нумерованного списка. Так дипломному руководителю будет проще отвечать на каждый из них.
3. При необходимости прикрепите к вопросу скриншоты и стрелочкой покажите, где не получается. Программу для этого можно скачать [здесь](https://app.prntscr.com/ru/).

Что может стать источником проблем:
1. Вопросы вида «Ничего не работает. Не запускается. Всё сломалось». Дипломный руководитель не сможет ответить на такой вопрос без дополнительных уточнений. Цените своё время и время других.
2. Откладывание выполнения дипломной работы на последний момент.
3. Ожидание моментального ответа на свой вопрос. Дипломные руководители — работающие инженеры, которые занимаются, кроме преподавания, своими проектами. Их время ограничено, поэтому постарайтесь задавать правильные вопросы, чтобы получать быстрые ответы :)

</details>

## Подготовка и установка TERRAFORM, ANSIBLE.

### 1) Terraform

![1](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/VersionTerraform.png)

### 2) Ansible

![2](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/VersionAnsible.png)

---------

## Настройка terraform для развёртывания инфраструктуры.

### 1) Настройка

Создаются:

- [providers.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/providers.tf)

- [variables.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/variables.tf)

Cloud-init конфиг для создания пользователя

![cloud.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/cloud.png)

### 2) Сайт

Создаются:

- [nginx.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/nginx.tf), в котором описывается создание 2-ух приватных ВМ с nginx.

- [balancer.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/balancer.tf), в котором описывается:

Создание L7-балансировщика (ALB) для распределения трафика.

Target-group, который объединяет Nginx-серверы в одну группу.

Backend-group, который следит за healthcheck серверов на 80 порту.

HTTP router, который определяет правила маршрутизации запросов.

L7-balancer: точка входа с публичным IP, принимающая внешний трафик.

### 3) Мониторинг

Создается:

- [zabbix.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/zabbix.tf), в котором описывается создание ВМ с Zabbix-хостом и с внешним доступом.

### 4) Логи

Создаются:

- [elasticsearch.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/elasticsearch.tf), в котором описывается создание приватного ВМ с сервером Elasticsearch.

- [kibana.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/kibana.tf), в котором описывается создание ВМ с веб-интерфейсом Kibana и с внешним доступом. 

### 5) Сеть

Создаются:

- [bastion.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/bastion.tf), в котором описывается создание ВМ с публичным адресом, в которой будет открыт только один порт — ssh (Bastion-хост).

- [network.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/network.tf), в котором описывается развертывание:

VPC с NAT-шлюзом для приватных подсетей.

Сервера Nginx, Elasticsearch помещаются в приватные подсети.

Сервера Zabbix, Kibana, ALB определяются в публичную подсеть.

- [security.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/security.tf), в котором описывается настройка Security Groups соответствующих сервисов на входящий трафик только к нужным портам.

### 6) Резервное копирование

Создаются:

- [snapshot.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/snapshot.tf), в котором описывается настройка графика создания снимков (снапшотов) для всех дисков.

### 7) Вывод данных

- [outputs.tf](https://github.com/sergey-selivanov-png/Diplom/blob/main/terraform/outputs.tf), в котором описывается вывод данных в консоль, после развертывания.

---------

## Поднятие инфраструктуры с помощью terraform.

```python
terraform init
terraform plan
terraform apply
```

![3](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/terraforminit.png)

![4](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/terraformapply.png), с выводом outputs.tf.

---------

## Результаты.

### 1) Созданные ресурсы.

![5](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/resource.png)

### 2) Создано шесть ВМ. Сервера Ngnix-1 и Nginx-2 созданы в разных зонах.

![6](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/6ВМ.png)

### 3) Диски и хранилища.

![7](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/disk.png)

### 4) Визуализация связей между серверами, подсетями и маршрутами. 

![8](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/cloudnetworkmap.png)

### 5) Общий список групп безопасности.

![9](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/securitygroup.png)

### 6) ALB. 

Target Group

![10](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/target.png)

Backend Group

![11](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/backend.png)

HTTP router

![12](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/router.png)

Application load balancer

![13](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/balancer.png)

### 7) Резервное копирование.

![14](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/snapshots.png)

---------

## Настройка ansible для развёртывания инфраструктуры.

### 1) Конфигурация.

- [ansible.cfg](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/ansible.cfg), файл настроек самого Ansible.

- [hosts.ini](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/hosts.ini), создан автоматически из bastion.tf. Указывает Ansible, на какие серверы заходить и какие роли на них применять.

### 2) Проверка доступности хостов.

![15](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/ansibleall.png)

### 3) Плейбук с установкой nginx и загрузкой сайтов.

- [nginxPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/nginxPlaybook.yaml), обновляет систему и ставит актуальный Nginx на оба сервера.

- [nginx1.html](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/nginx1.html), HTML-шаблон для 1 веб-сервера

- [nginx2.html](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/nginx2.html), HTML-шаблон для 2 веб-сервера

### 4) Плейбуки с установкой zabbix и zabbix agent.

- [zabbixPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/zabbixPlaybook.yaml), установка Zabbix-сервера с базой данных PostgreSQL и веб-интерфейсом Apache.

- [zabbixAgentPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/zabbixAgentPlaybook.yaml), настройка агентов для подключения веб-серверов к мониторингу.

### 5) Плейбук с установкой elasticsearch.

- [elasticsearchPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/elasticsearchPlaybook.yaml), установка базы логов  из зеркала яндекса.

- [elasticsearch0conf.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/elasticsearch-conf.yaml), конфигурация для работы в режиме одной ноды.

### 6) Плейбук с установкой filebeat.

- [filebeatPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/filebeatPlaybook.yaml), установка Filebeat на веб-серверы для отправки данных в стек ELK.

- [filebeat.j2](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/filebeat.j2), настройка на отправку access.log, error.log Nginx в Elasticsearch.

### 7) Плейбук с установкой kibana.

- [kibanaPlaybook.yaml](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/kibanaPlaybook.yaml), установка Kibana для визуализации логов из Elasticsearch.

- [kibana.j2](https://github.com/sergey-selivanov-png/Diplom/blob/main/ansible/kibana.j2), настройка интерфейса.

---------

## Установка плейбуков ansible.

### 1) nginx

### 2) zabbix

![17](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbix.png)

### 3) zabbix agent

![18](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixagent.png)

Статус zabbix agent на двух nginx серверах

![19](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixagentstatus.png)

### 4) elasticsearch

![20](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/elastisearch.png)

Статус elassticsearch

![21](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/elastisearchstatus.png)

### 5) filebeat

![22](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/filebeat.png)

### 6) kibana

![23](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/kibana.png)

Статус kibana

![24](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/kibanastatus.png)

---------

## Результаты.

### 1) Проверка работы Nginx в браузере.

Nginx1

![25](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/nginx1.png)

Nginx2

![26](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/nginx2.png)

После нескольких запросов в консоли YC, в логах балансировщика видим, что меняется IP адрес backend.

![27](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/balancerlogs1.png)

![28](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/balancerlogs2.png)

Протестируем сайт: `curl -v <публичный IP балансера>:80`

![29](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/curl-v.png)

### 2) Проверка работы Zabbix в Web интерфейсе.

![30](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixweb.png)

Добавляем хосты используя FQDN имена в zabbix сервер.

![31](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixweb2.png)

Разработан дашборд, охватывающий 5 ключевых ресурсов системы: CPU, RAM, Disk, Network и HTTP (Nginx). Для каждого ресурса были определены три типа показателей:
Utilization: Насколько ресурс занят.
Виджеты Gauge для мгновенного контроля CPU (порог 80%), RAM (90%) и Disk (85%). Цвет меняется при достижении лимитов.
Saturation: Наличие очередей и нехватки ресурса.
Линейные графики для Load Average и очередей диска. Позволяют выявлять скрытые задержки при низкой общей загрузке.
Errors: Прямые и косвенные признаки сбоев.
Мониторинг сетевых интерфейсов (eth0) и HTTP-ответов (>399). Для веб-узлов применен виджет Honeycomb.

Пороги Thresholds: Настроены визуальные линии и цветовая индикация для превентивного реагирования до отказа сервисов.

![32](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixDashboards1.png)
![33](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/zabbixDashboards2.png)

### 3) Проверка логов с двух Nginx.

Подтвержден успешный поток данных от агентов к Elasticsearch.
Логи структурированы (поля agent.hostname, message, log.file.path).
Видны успешные HTTP-ответы (200 OK) от балансировщика (Envoy/HC).

![33](https://github.com/sergey-selivanov-png/Diplom/blob/main/image/elsticlogs.png)

---------

