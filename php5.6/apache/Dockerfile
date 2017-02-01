FROM php:5.6-apache
MAINTAINER Aspen Digital <info@aspendigital.com>

RUN apt-get update && apt-get install -y git-core \
  libsqlite3-dev libpq-dev libmcrypt-dev libpng12-dev libjpeg-dev \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr \
  && docker-php-ext-install gd mysqli mcrypt zip pdo pdo_mysql pdo_sqlite opcache

# recommended opcache PHP.ini settings
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

RUN a2enmod rewrite

ENV OCTOBERCMS_TAG v1.0.396
ENV OCTOBERCMS_CHECKSUM 2fe1ae8ebecc959c5c1204962fe4a10ea609b756

RUN curl -o octobercms.tar.gz -fSL https://codeload.github.com/octobercms/october/legacy.tar.gz/{$OCTOBERCMS_TAG} \
  && echo "$OCTOBERCMS_CHECKSUM *octobercms.tar.gz" | sha1sum -c - \
  && tar -xzf octobercms.tar.gz \
  && OCTOBER_TMP_FOLDER=$(ls -d octobercms*/) \
  && find $OCTOBER_TMP_FOLDER -mindepth 1 -maxdepth 1 -exec mv -t . {} \; \
  && rmdir $OCTOBER_TMP_FOLDER \
  && rm octobercms.tar.gz

RUN composer install --no-interaction --prefer-dist --no-plugins --no-scripts

COPY docker-entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["apache2-foreground"]
