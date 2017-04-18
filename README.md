# Docker + October CMS

[![Build Status](https://travis-ci.org/aspendigital/docker-octobercms.svg?branch=master)](https://travis-ci.org/aspendigital/docker-octobercms) [![Docker Hub Pulls](https://img.shields.io/docker/pulls/aspendigital/octobercms.svg)](https://hub.docker.com/r/aspendigital/octobercms/) [![October CMS Build 415](https://img.shields.io/badge/October%20CMS%20Build-415-red.svg)](https://github.com/octobercms/october) [![Edge Build 415](https://img.shields.io/badge/Edge%20Build-415-lightgrey.svg)](https://github.com/octobercms/october)

The docker images defined in this repository serve as a starting point for [October CMS](https://octobercms.com) projects.

Based on [official docker PHP images](https://hub.docker.com/_/php), images include dependencies required by October, Composer and install the [latest release](https://octobercms.com/changelog).

## Supported Tags

- `build.415-php7.1-apache`, `php7.1-apache`, `build.415`, `latest`: [php7.1/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile)
- `build.415-php7.1-fpm`, `php7.1-fpm`: [php7.1/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile)
- `build.415-php7.0-apache`, `php7.0-apache`: [php7.0/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/apache/Dockerfile)
- `build.415-php7.0-fpm`, `php7.0-fpm`: [php7.0/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/fpm/Dockerfile)
- `build.415-php5.6-apache`, `php5.6-apache`: [php5.6/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/apache/Dockerfile)
- `build.415-php5.6-fpm`, `php5.6-fpm`: [php5.6/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/fpm/Dockerfile)


### Edge Build Tags

- `build.415-php7.1-apache`, `edge-php7.1-apache`, `build.415`, `edge`: [php7.1/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile.edge)
- `build.415-php7.1-fpm`, `edge-php7.1-fpm`: [php7.1/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile.edge)
- `build.415-php7.0-apache`, `edge-php7.0-apache`: [php7.0/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/apache/Dockerfile.edge)
- `build.415-php7.0-fpm`, `edge-php7.0-fpm`: [php7.0/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/fpm/Dockerfile.edge)
- `build.415-php5.6-apache`, `edge-php5.6-apache`: [php5.6/apache/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/apache/Dockerfile.edge)
- `build.415-php5.6-fpm`, `edge-php5.6-fpm`: [php5.6/fpm/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/fpm/Dockerfile.edge)

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

![October](https://raw.githubusercontent.com/aspendigital/docker-octobercms/master/aspendigital-octobercms-docker-logo.png)
