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


tags=("build.382-apache" "build.382-php7.0-apache" "php7.0-apache" "latest")
path="$workdir/php7.0/apache"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.382-fpm" "build.382-php7.0-fpm" "php7.0-fpm")
path="$workdir/php7.0/fpm"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.382-php5.6-apache" "php5.6-apache")
path="$workdir/php5.6/apache"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

tags=("build.382-php5.6-fpm" "php5.6-fpm")
path="$workdir/php5.6/fpm"
file="$path/Dockerfile"
buildnpush "${tags[@]}"

#audit
docker images aspendigital/octobercms | awk '{print $1","$2","$3 }' > audit.csv
