#!/bin/bash
set -e

# Dependency check
if ! hash curl 2>&-; then echo "Error: curl is required" && exit 1; fi
if ! hash jq 2>&-; then echo "Error: jq is required" && exit 1; fi
if ! hash sha1sum 2>&-; then { if ! hash openssl 2>&-; then echo "Error: openssl/sha1sum is required" && exit 1; fi } fi

# Pull in current build values
source version

%%PHP_VERSION%%
%%VARIANT%%
%%VARIANT_EXTRAS%% (RUN a2enmod rewrite)
%%OCTOBERCMS_TAG%%
%%OCTOBERCMS_CHECKSUM%%
%%CMD%% (apache2-foreground | php-fpm)

echo " - Update complete." && exit 0;
