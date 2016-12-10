FROM php:7.0-fpm
MAINTAINER Aspen Digital <info@aspendigital.com>

RUN apt-get update && apt-get install -y git-core \
  libsqlite3-dev libpq-dev libmcrypt-dev libpng12-dev libjpeg-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli mcrypt zip pdo pdo_mysql pdo_sqlite opcache

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=2'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

RUN curl -sS https://getcomposer.org/installer | php \
        && mv composer.phar /usr/local/bin/composer

ENV OCTOBERCMS_BUILD 382
ENV OCTOBERCMS_COMMIT_HASH 97b0bc481f948045f96a420bb54ab48628bfdddc
ENV OCTOBERCMS_CHECKSUM a2542641aade3a5d1cec8c11d34d03e927a75fa2

RUN curl -o octobercms.tar.gz -fSL https://github.com/octobercms/october/archive/{$OCTOBERCMS_COMMIT_HASH}.tar.gz \
  && echo "$OCTOBERCMS_CHECKSUM *octobercms.tar.gz" | sha1sum -c - \
	&& tar -xzf octobercms.tar.gz \
  && find "october-$OCTOBERCMS_COMMIT_HASH" -mindepth 1 -maxdepth 1 -exec mv -t . {} \; \
  && rmdir "october-$OCTOBERCMS_COMMIT_HASH" \
	&& rm octobercms.tar.gz

RUN composer install --no-interaction --prefer-dist --no-plugins --no-scripts

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["php-fpm"]
