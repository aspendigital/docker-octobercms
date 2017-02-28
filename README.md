# Docker + October CMS

[![Build Status](https://travis-ci.org/aspendigital/docker-octobercms.svg?branch=master)](https://travis-ci.org/aspendigital/docker-octobercms)

The docker images defined in this repository serve as a starting point for [October CMS](https://octobercms.com) projects.

Based on [official docker PHP images](https://github.com/docker-library/php), images include dependencies required by October, Composer and install the [latest release](https://github.com/octobercms/october).

## Supported Tags

- `build.396-php7.1-apache`, `php7.1-apache`, `build.396`, `latest`: [php7.1/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/apache/Dockerfile)
- `build.396-php7.1-fpm`, `php7.1-fpm`: [php7.1/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.1/fpm/Dockerfile)
- `build.396-php7.0-apache`, `php7.0-apache`: [php7.0/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/apache/Dockerfile)
- `build.396-php7.0-fpm`, `php7.0-fpm`: [php7.0/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php7.0/fpm/Dockerfile)
- `build.396-php5.6-apache`, `php5.6-apache`: [php5.6/apache/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/apache/Dockerfile)
- `build.396-php5.6-fpm`, `php5.6-fpm`: [php5.6/fpm/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/php5.6/fpm/Dockerfile)

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
