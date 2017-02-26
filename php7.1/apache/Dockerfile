FROM php:7.1-apache
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

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && /usr/local/bin/composer global require hirak/prestissimo

RUN a2enmod rewrite

ENV OCTOBERCMS_TAG v1.0.396
ENV OCTOBERCMS_CHECKSUM 2fe1ae8ebecc959c5c1204962fe4a10ea609b756
ENV OCTOBERCMS_CORE_BUILD 396
ENV OCTOBERCMS_CORE_HASH ff812962c9de7932015f2f6620d2ca3b

ENV DOCKER_PLUGIN v1.0.5
ENV DOCKER_PLUGIN_CHECKSUM dafaaab4f07a0a4a6e9978fdd11bb04e2d742ce7

# Consolidated October CMS setup
RUN curl -o octobercms.tar.gz -fSL https://codeload.github.com/octobercms/october/legacy.tar.gz/{$OCTOBERCMS_TAG} \
  && echo "$OCTOBERCMS_CHECKSUM *octobercms.tar.gz" | sha1sum -c - \
  && tar -xzf octobercms.tar.gz \
  && OCTOBER_TMP_FOLDER=$(ls -d octobercms*/) \
  && find $OCTOBER_TMP_FOLDER -mindepth 1 -maxdepth 1 -exec mv -t . {} \; \
  && rmdir $OCTOBER_TMP_FOLDER \
  && rm octobercms.tar.gz \
  # match build dependencies
  && echo "Update composer.json: Require dependencies of the same build" \
  && sed -i.orig "s/\(\"october\/\([rain|system|backend|cms]*\)\": \"\(~1.0\)\"\)/\"october\/\2\": \"${OCTOBERCMS_TAG#v}\"/g" composer.json \
  && egrep -o "['\"]october\/[rain|system|backend|cms]*['\"]\s*:\s*['\"](.+?)['\"]" composer.json \
  && composer install --no-interaction --prefer-dist --no-scripts \
  # setup docker env
  && echo 'APP_ENV=docker' > .env \
  && mkdir config/docker \
  && echo "<?php return ['edgeUpdates' => false, 'disableCoreUpdates' => true];" > config/docker/cms.php \
  && echo "<?php return ['default' => 'sqlite'];" > config/docker/database.php \
  && echo "<?php return ['driver' => 'log'];" > config/docker/mail.php \
  # setup database
  && touch storage/database.sqlite \
  && chmod 666 storage/database.sqlite \
  && php artisan october:up \
  # docker plugin - set build params
  && curl -o plugins/october-docker.tar.gz -fSL https://codeload.github.com/aspendigital/october-docker/legacy.tar.gz/{$DOCKER_PLUGIN} \
  && echo "$DOCKER_PLUGIN_CHECKSUM *plugins/october-docker.tar.gz" | sha1sum -c - \
  && tar -xzf plugins/october-docker.tar.gz -C plugins \
  && mkdir plugins/aspendigital \
  && DOCKER_PLUGIN_TMP_FOLDER=$(ls -d plugins/aspendigital-october-docker*/) \
  && mv $DOCKER_PLUGIN_TMP_FOLDER plugins/aspendigital/docker \
  && rm plugins/october-docker.tar.gz \
  && php artisan docker:up \
  # permissions
  && chown -R www-data:www-data /var/www/html

CMD ["apache2-foreground"]
