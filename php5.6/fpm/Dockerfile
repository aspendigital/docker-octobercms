FROM php:5.6-fpm

RUN apt-get update && apt-get install -y cron git-core nano \
  libjpeg-dev libmcrypt-dev libpng12-dev libpq-dev libsqlite3-dev && \
  rm -rf /var/lib/apt/lists/* && \
  docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr && \
  docker-php-ext-install gd mcrypt mysqli opcache pdo pdo_pgsql pdo_mysql pdo_sqlite zip

RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
  } > /usr/local/etc/php/conf.d/docker-oc-opcache.ini

RUN { \
    echo 'log_errors=on'; \
    echo 'display_errors=off'; \
    echo 'upload_max_filesize=32M'; \
    echo 'post_max_size=32M'; \
    echo 'memory_limit=128M'; \
  } > /usr/local/etc/php/conf.d/docker-oc-php.ini

RUN curl -sS https://getcomposer.org/installer | php -- --1 --install-dir=/usr/local/bin --filename=composer && \
  /usr/local/bin/composer global require hirak/prestissimo



ENV OCTOBERCMS_TAG v1.0.419
ENV OCTOBERCMS_CHECKSUM 024647247bbfe6041f25dd64b3be345aff8d0922
ENV OCTOBERCMS_CORE_BUILD 419
ENV OCTOBERCMS_CORE_HASH 386846ebe3802c4f192625743abb3f06

RUN curl -o octobercms.tar.gz -fSL https://codeload.github.com/octobercms/october/tar.gz/{$OCTOBERCMS_TAG} && \
  echo "$OCTOBERCMS_CHECKSUM *octobercms.tar.gz" | sha1sum -c - && \
  tar --strip=1 -xzf octobercms.tar.gz && \
  rm octobercms.tar.gz && \
  echo "Update composer.json: Drop october module dependencies and set 'october/rain' reference" && \
  sed -i.orig '/october\/[system|backend|cms]/,+0 d' composer.json && \
  sed -i "s/\(\"october\/\(rain*\)\": \"\(~1.0\)\"\)/\"october\/\2\": \"<=${OCTOBERCMS_TAG#v}\"/g" composer.json && \
  egrep -o "['\"]october\/[rain]*['\"]\s*:\s*['\"](.+?)['\"]" composer.json && \
  composer install --no-interaction --prefer-dist --no-scripts && \
  echo 'APP_ENV=docker' > .env && \
  mkdir config/docker && \
  echo "<?php return ['edgeUpdates' => false, 'disableCoreUpdates' => true];" > config/docker/cms.php && \
  echo "<?php return ['default' => 'sqlite'];" > config/docker/database.php && \
  echo "<?php return ['driver' => 'log'];" > config/docker/mail.php && \
  echo "<?php return ['default' => 'docker', 'hosts' => ['localhost' => 'docker']];" > config/docker/environment.php && \
  touch storage/database.sqlite && \
  chmod 666 storage/database.sqlite && \
  php artisan october:up && \
  php -r "use System\\Models\\Parameter; \
    require __DIR__.'/bootstrap/autoload.php'; \
    \$app = require_once __DIR__.'/bootstrap/app.php'; \
    \$app->make('Illuminate\\Contracts\\Console\\Kernel')->bootstrap(); \
    Parameter::set(['system::core.build'=>getenv('OCTOBERCMS_CORE_BUILD'), 'system::core.hash'=>getenv('OCTOBERCMS_CORE_HASH')]); \
    echo \"October CMS \\n Build: \",Parameter::get('system::core.build'), \"\\n Hash: \", Parameter::get('system::core.hash'), \"\\n\";" && \
  chown -R www-data:www-data /var/www/html

RUN echo "* * * * * /usr/local/bin/php /var/www/html/artisan schedule:run > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/cron.d/october-cron && \
  crontab /etc/cron.d/october-cron

CMD ["php-fpm"]
