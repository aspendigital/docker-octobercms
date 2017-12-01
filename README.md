# Docker + October CMS

[![Build Status](https://travis-ci.org/aspendigital/docker-octobercms.svg?branch=master)](https://travis-ci.org/aspendigital/docker-octobercms) [![Docker Hub Pulls](https://img.shields.io/docker/pulls/aspendigital/octobercms.svg)](https://hub.docker.com/r/aspendigital/octobercms/) [![October CMS Build 428](https://img.shields.io/badge/October%20CMS%20Build-428-red.svg)](https://github.com/octobercms/october) [![Edge Build 428](https://img.shields.io/badge/Edge%20Build-428-lightgrey.svg)](https://github.com/octobercms/october)

The docker images defined in this repository serve as a starting point for [October CMS](https://octobercms.com) projects.

Based on [official docker PHP images](https://hub.docker.com/_/php), images include dependencies required by October, Composer and install the [latest release](https://octobercms.com/changelog).

## Supported Tags

- `build.428-php7.1-apache`, `php7.1-apache`, `build.428`, `latest`: [php7.1/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile)
- `build.428-php7.1-fpm`, `php7.1-fpm`: [php7.1/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile)
- `build.428-php7.0-apache`, `php7.0-apache`: [php7.0/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/apache/Dockerfile)
- `build.428-php7.0-fpm`, `php7.0-fpm`: [php7.0/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/fpm/Dockerfile)


### Edge Tags

- `edge-build.428-php7.1-apache`, `edge-php7.1-apache`, `edge-build.428`, `edge`: [php7.1/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile.edge)
- `edge-build.428-php7.1-fpm`, `edge-php7.1-fpm`: [php7.1/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile.edge)
- `edge-build.428-php7.0-apache`, `edge-php7.0-apache`: [php7.0/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/apache/Dockerfile.edge)
- `edge-build.428-php7.0-fpm`, `edge-php7.0-fpm`: [php7.0/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/fpm/Dockerfile.edge)

### Legacy Tags

> October CMS build 420+ requires PHP version 7.0 or higher

- `build.419-php5.6-apache`, `php5.6-apache`: [php5.6/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/apache/Dockerfile)
- `build.419-php5.6-fpm`, `php5.6-fpm`: [php5.6/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/fpm/Dockerfile)


## Quick Start

To run October CMS using Docker, start a container using the latest image, mapping your local port 80 to the container's port 80:

```shell
$ docker run -p80:80 aspendigital/octobercms:latest
```


Run the container in detached mode using the container name `october` and launch an interactive shell (bash) for the container.


```shell
$ docker run -p80:80 -d --name october aspendigital/octobercms:latest

$ docker exec -it october bash
```
---

## App Environment

By default, `APP_ENV` is set to `docker`.

On image build, a default `.env` is [created](https://github.com/aspendigital/docker-octobercms/blob/d3b288b9fe0606e32ac3d6466affd2996394bdca/Dockerfile.template#L52) and [config files](https://github.com/aspendigital/docker-octobercms/tree/master/config/docker) for the `docker` app environment are copied to `/var/www/html/config/docker`. Environment variables can be used to override the included default settings via [`docker run`](https://docs.docker.com/engine/reference/run/#env-environment-variables) or [`docker-compose`](https://docs.docker.com/compose/environment-variables/).

> __Note__: October CMS settings stored in a site's database override the config. Active theme, mail configuration, and other settings which are saved in the database will ultimately override configuration values.


### Environment Variables


Environment variables can be passed to both docker-compose and October CMS.

 > Database credentials and other sensitive information should not be committed to the repository. Those required settings should be outlined in __.env.example__

 > Passing environment variables via Docker can be problematic in production. A `phpinfo()` call may leak secrets by outputting environment variables.  Consider mounting a `.env` volume or copying it to the container directly.


#### Docker Entrypoint

| Variable | Default | Action |
| -------- | ------- | ------ |
| ENABLE_CRON | false | Enables a cron process |
| FWD_REMOTE_IP | false | Forwards remote IP from proxy (Apache) |

#### October CMS app environment config

List of variables used in `config/docker`

| Variable | Default |
| -------- | ------- |
| APP_DEBUG | true |
| APP_URL | http://localhost |
| APP_KEY | 0123456789ABCDEFGHIJKLMNOPQRSTUV |
| CACHE_STORE | file |
| CMS_ACTIVE_THEME | demo |
| CMS_EDGE_UPDATES | false  (true in `edge` images) |
| CMS_DISABLE_CORE_UPDATES | true |
| CMS_BACKEND_SKIN | Backend\Skins\Standard |
| CMS_LINK_POLICY | detect |
| CMS_BACKEND_FORCE_SECURE | false |
| DB_TYPE | sqlite |
| DB_SQLITE_PATH | storage/database.sqlite |
| DB_HOST | mysql* |
| DB_PORT | - |
| DB_DATABASE | - |
| DB_USERNAME | - |
| DB_PASSWORD | - |
| DB_REDIS_HOST | redis* |
| DB_REDIS_PASSWORD | null |
| DB_REDIS_PORT | 6379 |
| MAIL_DRIVER | log |
| MAIL_SMTP_HOST | - |
| MAIL_SMTP_PORT | 587 |
| MAIL_FROM_ADDRESS | no-reply@domain.tld |
| MAIL_FROM_NAME | October CMS |
| MAIL_SMTP_ENCRYPTION | tls |
| MAIL_SMTP_USERNAME | - |
| MAIL_SMTP_PASSWORD | - |
| QUEUE_DRIVER | sync |
| SESSION_DRIVER | file |
| TZ\** | UTC |

<small>\* When using a container to serve a database, set the host value to the service name defined in your docker-compose.yml</small>

<small>\** Timezone applies to both container and October CMS  config</small>

![October](https://raw.githubusercontent.com/aspendigital/docker-octobercms/master/aspendigital-octobercms-docker-logo.png)
