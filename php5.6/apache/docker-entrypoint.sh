#!/bin/bash
set -e

if [[ "$1" == apache2* ]] || [ "$1" == php-fpm ]; then
  chown -R www-data:www-data /var/www/html
fi

exec "$@"
