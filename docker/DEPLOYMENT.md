# Деплой с нуля через Docker Compose

Ниже — минимальный сценарий развертывания сервера и зависимостей (MongoDB + инициализация реплика-сета + MailDev) с нуля, используя уже подготовленные Docker-образы в этом репозитории.

## Предпосылки

* Установлены Docker и Docker Compose.
* Репозиторий клонирован локально.

## Быстрый старт (одной командой)

Из корня репозитория:

```bash
docker compose -f docker/docker-compose-deploy.yml up -d --build
```

Если порт MongoDB уже занят, задайте другой порт:

```bash
MONGO_PORT=27018 docker compose -f docker/docker-compose-deploy.yml up -d --build
```

После старта:

* REST API сервера доступен на `http://localhost:81`.
* OCPP SOAP порт: `8000`
* OCPP JSON (WebSocket) порт: `8010`
* OCPI порт: `9090`
* OData порт: `9292`
* MailDev UI: `http://localhost:1080`

## Что происходит при запуске

Compose файл `docker/docker-compose-deploy.yml` поднимает:

1. **MongoDB** с реплика-сетом `rs0` и инициализацией базы из `docker/initdb`.
2. **enablereplset** — контейнер, который инициирует реплика-сет.
3. **MailDev** — тестовый SMTP сервер (порт 587) и UI на 1080.
4. **server** — Node.js сервер, собранный через `docker/ev_server.Dockerfile`.

## Важные учетные данные

Инициализационные скрипты создают пользователей MongoDB:

* Администратор: `evse-admin` / `evse-admin-pwd`
* Пользователь приложения: `evse-user` / `evse-user-pwd`

Корневой пользователь MongoDB (для инициализации) задается в `docker/ev_mongo.env`:

```
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=admin
```

## Проверка состояния

Посмотреть логи:

```bash
docker compose -f docker/docker-compose-deploy.yml logs -f server
```

Проверить, что реплика-сет активен:

```bash
docker compose -f docker/docker-compose-deploy.yml exec mongodb mongo --eval 'rs.status()'
```

## Остановка

```bash
docker compose -f docker/docker-compose-deploy.yml down
```

## Кастомизация

* Конфиг приложения для Docker задается в `docker/config.json` (он копируется в образ как `src/assets/config.json`).
* При необходимости можно изменить порты или параметры сервисов в `docker/docker-compose-deploy.yml`.
