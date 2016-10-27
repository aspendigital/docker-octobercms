#!/bin/bash

# workdir=$(pwd)
workdir='.'
# paths are relative to the builder script. (octobercms)

# usage: buildnpush [tag_array] [path] [dockefile]
function buildnpush {
  tags=("$@")
  for i in "${tags[@]}"
  do
  	docker build -f $file -t aspendigital/octobercms:$i $path/.
    docker push aspendigital/octobercms:$i
  	# echo "docker build -f $file -t aspendigital/octobercms:$i $path/."
    # echo "docker push aspendigital/octobercms:$i"
    echo "-----"
  done
}


tags=("build.365-apache" "build.365-php7.0-apache" "php7.0-apache" "latest")
path="$workdir/php7.0/apache"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.365-fpm" "build.365-php7.0-fpm" "php7.0-fpm")
path="$workdir/php7.0/fpm"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.365-php5.6-apache" "php5.6-apache")
path="$workdir/php5.6/apache"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.365-php5.6-fpm" "php5.6-fpm")
path="$workdir/php5.6/fpm"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

#Edge builds
tags=("build.377-apache" "build.377-php7.0-apache" "edge")
path="$workdir/php7.0/apache"
file="$path/Dockerfile.edge"
buildnpush "${tags[@]}"

tags=("build.377-fpm" "build.377-php7.0-fpm")
path="$workdir/php7.0/fpm"
file="$path/Dockerfile.edge"
buildnpush "${tags[@]}"

tags=("build.377-php5.6-apache")
path="$workdir/php5.6/apache"
file="$path/Dockerfile.edge"
buildnpush "${tags[@]}"

tags=("build.377-php5.6-fpm")
path="$workdir/php5.6/fpm"
file="$path/Dockerfile.edge"
buildnpush "${tags[@]}"
