FROM php:7.0-fpm
MAINTAINER Aspen Digital <info@aspendigital.com>

RUN apt-get update && apt-get install -y git-core unzip \
  libsqlite3-dev libpq-dev libmcrypt-dev libpng12-dev libjpeg-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli mcrypt zip pdo pdo_mysql pdo_sqlite

RUN { \
  echo 'opcache.memory_consumption=128'; \
  echo 'opcache.interned_strings_buffer=8'; \
  echo 'opcache.max_accelerated_files=4000'; \
  echo 'opcache.revalidate_freq=60'; \
  echo 'opcache.fast_shutdown=1'; \
  echo 'opcache.enable_cli=1'; \
} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer

RUN curl -o october.zip -SL https://github.com/octobercms/october/archive/master.zip \
  && unzip october.zip > /dev/null \
  && find october-master -mindepth 1 -maxdepth 1 -exec mv -t . {} \; \
  && rmdir october-master \
	&& rm october.zip

RUN composer install --no-interaction --prefer-dist --no-plugins --no-scripts
