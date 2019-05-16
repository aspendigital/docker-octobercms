# Docker + October CMS

[![Build Status](https://travis-ci.org/aspendigital/docker-octobercms.svg?branch=master)](https://travis-ci.org/aspendigital/docker-octobercms) [![Docker Hub Pulls](https://img.shields.io/docker/pulls/aspendigital/octobercms.svg)](https://hub.docker.com/r/aspendigital/octobercms/) [![October CMS Build 455](https://img.shields.io/badge/October%20CMS%20Build-455-red.svg)](https://github.com/octobercms/october) [![Edge Build 455](https://img.shields.io/badge/Edge%20Build-455-lightgrey.svg)](https://github.com/octobercms/october)

The docker images defined in this repository serve as a starting point for [October CMS](https://octobercms.com) projects.

Based on [official docker PHP images](https://hub.docker.com/_/php), images include dependencies required by October, Composer and install the [latest release](https://octobercms.com/changelog).

- [Supported Tags](https://github.com/aspendigital/docker-octobercms#supported-tags)
- [Quick Start](https://github.com/aspendigital/docker-octobercms#quick-start)
- [Working with Local Files](https://github.com/aspendigital/docker-octobercms#working-with-local-files)
- [Database Support](https://github.com/aspendigital/docker-octobercms#database-support)
- [Cron](https://github.com/aspendigital/docker-octobercms#cron)
- [Command Line Tasks](https://github.com/aspendigital/docker-octobercms#command-line-tasks)
- [App Environment](https://github.com/aspendigital/docker-octobercms#app-environment)

---

## Supported Tags

- `build.455-php7.3-apache`, `php7.3-apache`: [php7.3/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/apache/Dockerfile)
- `build.455-php7.3-fpm`, `php7.3-fpm`: [php7.3/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/fpm/Dockerfile)
- `build.455-php7.2-apache`, `php7.2-apache`, `build.455`, `latest`: [php7.2/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/apache/Dockerfile)
- `build.455-php7.2-fpm`, `php7.2-fpm`: [php7.2/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/fpm/Dockerfile)
- `build.455-php7.1-apache`, `php7.1-apache`: [php7.1/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile)
- `build.455-php7.1-fpm`, `php7.1-fpm`: [php7.1/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile)


### Edge Tags

- `edge-build.455-php7.3-apache`, `edge-php7.3-apache`: [php7.3/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/apache/Dockerfile.edge)
- `edge-build.455-php7.3-fpm`, `edge-php7.3-fpm`: [php7.3/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/fpm/Dockerfile.edge)
- `edge-build.455-php7.2-apache`, `edge-php7.2-apache`, `edge-build.455`, `edge`: [php7.2/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/apache/Dockerfile.edge)
- `edge-build.455-php7.2-fpm`, `edge-php7.2-fpm`: [php7.2/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/fpm/Dockerfile.edge)
- `edge-build.455-php7.1-apache`, `edge-php7.1-apache`: [php7.1/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile.edge)
- `edge-build.455-php7.1-fpm`, `edge-php7.1-fpm`: [php7.1/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile.edge)


### Develop Tags

- `develop-php7.3-apache`: [php7.3/apache/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/apache/Dockerfile.develop)
- `develop-php7.3-fpm`: [php7.3/fpm/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.3/fpm/Dockerfile.develop)
- `develop-php7.2-apache`, `develop`: [php7.2/apache/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/apache/Dockerfile.develop)
- `develop-php7.2-fpm`: [php7.2/fpm/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.2/fpm/Dockerfile.develop)
- `develop-php7.1-apache`: [php7.1/apache/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile.develop)
- `develop-php7.1-fpm`: [php7.1/fpm/Dockerfile.develop](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile.develop)

### Legacy Tags

> October CMS build 420+ requires PHP version 7.0 or higher

- `build.419-php5.6-apache`, `php5.6-apache`: [php5.6/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/apache/Dockerfile)
- `build.419-php5.6-fpm`, `php5.6-fpm`: [php5.6/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/fpm/Dockerfile)


## Quick Start

To run October CMS using Docker, start a container using the latest image, mapping your local port 80 to the container's port 80:

```shell
$ docker run -p 80:80 --name october aspendigital/octobercms:latest
# `CTRL-C` to stop
$ docker rm october  # Destroys the container
```

> If there is a port conflict, you will receive an error message from the Docker daemon. Try mapping to an open local port (-p 8080:80) or shut down the container or server that is on the desired port.

 - Visit [http://localhost](http://localhost) using your browser.
 - Login to the [backend](http://localhost/backend) with the username `admin` and password `admin`.
 - Hit `CTRL-C` to stop the container. Running a container in the foreground will send log outputs to your terminal.

Run the container in the background by passing the `-d` option:

```shell
$ docker run -p 80:80 --name october -d aspendigital/octobercms:latest
$ docker stop october  # Stops the container. To restart `docker start october`
$ docker rm october  # Destroys the container
```

## Working with Local Files

Using Docker volumes, you can mount local files inside a container.

The container uses the working directory `/var/www/html` for the web server document root. This is where the October CMS codebase resides in the container. You can replace files and folders, or introduce new ones with bind-mounted volumes:

```shell
# Developing a plugin
$ git clone git@github.com:aspendigital/oc-resizer-plugin.git
$ cd oc-resizer-plugin
$ docker run -p 80:80 --rm \
  -v $(pwd):/var/www/html/plugins/aspendigital/resizer \
  aspendigital/octobercms:latest
```

Save yourself some keyboards strokes, utilize [docker-compose](https://docs.docker.com/compose/overview/) by introducing a `docker-compose.yml` file to your project folder:

```yml
# docker-compose.yml
version: '2.2'
services:
  web:
    image: aspendigital/octobercms
    ports:
      - 80:80
    volumes:
      - $PWD:/var/www/html/plugins/aspendigital/resizer
```
With the above example saved in working directory, run:

```shell
$ docker-compose up -d # start services defined in `docker-compose.yml` in the background
$ docker-compose down # stop and destroy
```


## Database Support

#### SQLite

On build, an SQLite database is [created and initialized](https://github.com/aspendigital/docker-octobercms/blob/d3b288b9fe0606e32ac3d6466affd2996394bdca/Dockerfile.template#L54-L57) for the Docker image. With that database, users have immediate access to the backend for testing and developing themes and plugins. However, changes made to the built-in database will be lost once the container is stopped and removed.

When projects require a persistent SQLite database, copy or create a new database to the host which can be used as a bind mount:

```shell
# Create and provision a new SQLite database:
$ touch storage/database.sqlite
$ docker run --rm \
  -v $(pwd)/storage/database.sqlite:/var/www/html/storage/database.sqlite \
  aspendigital/octobercms php artisan october:up

# Now run with the volume mounted to your host
$ docker run -p 80:80 --name october \
 -v $(pwd)/storage/database.sqlite:/var/www/html/storage/database.sqlite \
 aspendigital/octobercms
```

#### MySQL / Postgres

Alternatively, you can host the database using another container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: aspendigital/octobercms:latest
    ports:
      - 80:80
    environment:
      - DB_TYPE=mysql
      - DB_HOST=mysql #DB_HOST should match the service name of the database container
      - DB_DATABASE=octobercms
      - DB_USERNAME=root
      - DB_PASSWORD=root

  mysql:
    image: mysql:5.7
    ports:
      - 3306:3306
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=octobercms
```
Provision a new database with `october:up`:

```ssh
$ docker-compose up -d
$ docker-compose exec web php artisan october:up
```

## Cron

You can start a cron process by setting the environment variable `ENABLE_CRON` to `true`:

```shell
$ docker run -p 80:80 -e ENABLE_CRON=true aspendigital/octobercms:latest
```

Separate the cron process into it's own container:

```yml
#docker-compose.yml
version: '2.2'
services:
  web:
    image: aspendigital/octobercms:latest
    init: true
    restart: always
    ports:
      - 80:80
    environment:
      - TZ=America/Denver
    volumes:
      - ./.env:/var/www/html/.env
      - ./plugins:/var/www/html/plugins
      - ./storage/app:/var/www/html/storage/app
      - ./storage/logs:/var/www/html/storage/logs
      - ./storage/database.sqlite:/var/www/html/storage/database.sqlite
      - ./themes:/var/www/html/themes

  cron:
    image: aspendigital/octobercms:latest
    init: true
    restart: always
    command: [cron, -f]
    environment:
      - TZ=America/Denver
    volumes_from:
      - web
```

## Command Line Tasks

Run the container in the background and launch an interactive shell (bash) for the container:


```shell
$ docker run -p 80:80 --name containername -d aspendigital/octobercms:latest
$ docker exec -it containername bash
```

Commands can also be run directly, without opening a shell:

```shell
# artisan
$ docker exec containername php artisan env

# composer
$ docker exec containername composer info
```

A few helper scripts have been added to the image:

```shell
# `october` invokes `php artisan october:"$@"`
$ docker exec containername october up

# `artisan` invokes `php artisan "$@"`
$ docker exec containername artisan plugin:install aspendigital.resizer

# `tinker` invokes `php artisan tinker`. Requires `-it` for an interactive shell
$ docker exec -it containername tinker
```


## App Environment

By default, `APP_ENV` is set to `docker`.

On image build, a default `.env` is [created](https://github.com/aspendigital/docker-octobercms/blob/d3b288b9fe0606e32ac3d6466affd2996394bdca/Dockerfile.template#L52) and [config files](https://github.com/aspendigital/docker-octobercms/tree/master/config/docker) for the `docker` app environment are copied to `/var/www/html/config/docker`. Environment variables can be used to override the included default settings via [`docker run`](https://docs.docker.com/engine/reference/run/#env-environment-variables) or [`docker-compose`](https://docs.docker.com/compose/environment-variables/).

> __Note__: October CMS settings stored in a site's database override the config. Active theme, mail configuration, and other settings which are saved in the database will ultimately override configuration values.

#### PHP configuration

Recommended [settings for opcache and PHP are applied on image build](https://github.com/aspendigital/docker-octobercms/blob/f3c545fd84e293a67e63f86bf94f2bf2ab22ca15/Dockerfile.template#L9-L25).

Values set in `docker-oc-php.ini` can be overridden by passing one of the supported PHP environment variables defined below.

To customize the PHP configuration further, add or replace `.ini` files found in `/usr/local/etc/php/conf.d/`.

### Environment Variables


Environment variables can be passed to both docker-compose and October CMS.

 > Database credentials and other sensitive information should not be committed to the repository. Those required settings should be outlined in __.env.example__

 > Passing environment variables via Docker can be problematic in production. A `phpinfo()` call may leak secrets by outputting environment variables.  Consider mounting a `.env` volume or copying it to the container directly.


#### Docker Entrypoint

The following variables trigger actions run by the [entrypoint script](https://github.com/aspendigital/docker-octobercms/blob/master/docker-oc-entrypoint) at runtime.

| Variable | Default | Action |
| -------- | ------- | ------ |
| ENABLE_CRON | false | `true` starts a cron process within the container |
| FWD_REMOTE_IP | false | `true` enables remote IP forwarding from proxy (Apache) |
| GIT_CHECKOUT |  | Checkout branch, tag, commit within the container. Runs `git checkout $GIT_CHECKOUT` |
| GIT_MERGE_PR |  | Pass GitHub pull request number to merge PR within the container for testing |
| INIT_OCTOBER | false | `true` runs october up on container start |
| INIT_PLUGINS | false | `true` runs composer install in plugins folders where no 'vendor' folder exists. `force` runs composer install regardless. Helpful when using git submodules for plugins. |
| PHP_DISPLAY_ERRORS | off | Override value for `display_errors` in docker-oc-php.ini |
| PHP_POST_MAX_SIZE | 32M | Override value for `post_max_size` in docker-oc-php.ini |
| PHP_MEMORY_LIMIT | 128M | Override value for `memory_limit` in docker-oc-php.ini |
| PHP_UPLOAD_MAX_FILESIZE | 32M | Override value for `upload_max_filesize` in docker-oc-php.ini |
| UNIT_TEST |  | `true` runs all October CMS unit tests. Pass test filename to run a specific test. |
| VERSION_INFO | false | `true` outputs container current commit, php version, and dependency info on start |
| XDEBUG_ENABLE | false | `true` enables the Xdebug PHP extension |
| XDEBUG_REMOTE_HOST | host.docker.internal | Override value for `xdebug.remote_host` in docker-xdebug-php.ini |

#### October CMS app environment config

List of variables used in `config/docker`

| Variable | Default |
| -------- | ------- |
| APP_DEBUG | false |
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

---

![October](https://raw.githubusercontent.com/aspendigital/docker-octobercms/master/aspendigital-octobercms-docker-logo.png)
