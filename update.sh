#!/bin/bash
set -e

# Dependency check
if ! hash curl 2>&-; then echo "Error: curl is required" && exit 1; fi
if ! hash jq 2>&-; then echo "Error: jq is required" && exit 1; fi
if ! hash sha1sum 2>&-; then { if ! hash openssl 2>&-; then echo "Error: openssl/sha1sum is required" && exit 1; fi } fi

# Load cached version if not forced
[ "$1" = "force" ] && echo ' - Force Update' || source version

function check_october {
  [ "$1" = "edge" ] && EDGE=1 || EDGE=0

  # Host server PHP version - https://github.com/octobercms/october/blob/97b0bc481f948045f96a420bb54ab48628bfdddc/modules/system/classes/UpdateManager.php#L835
  OCTOBERCMS_SERVER_HASH=YToyOntzOjM6InBocCI7czo2OiI3LjAuMTMiO3M6MzoidXJsIjtzOjE2OiJodHRwOi8vbG9jYWxob3N0Ijt9

  # Set default NULL HASH if core hash isn't set
  [ -z "$OCTOBERCMS_CORE_HASH" ] && OCTOBERCMS_CORE_HASH=6c3e226b4d4795d518ab341b0824ec29

  OCTOBER_API_RESPONSE=$(
    curl -X POST -fsS --connect-timeout 15 --url http://gateway.octobercms.com/api/core/update \
     -F "build=$OCTOBERCMS_BUILD" -F "core=$OCTOBERCMS_CORE_HASH" -F "plugins=a:0:{}" -F "server=$OCTOBERCMS_SERVER_HASH" -F "edge=$EDGE")
  OCTOBER_API_UPDATES=$( echo "$OCTOBER_API_RESPONSE" | jq '. | { build: .core.build, hash: .core.hash, update: .update, updates: .core.updates }')
}

function update_checksum {
  echo " - Generating new checksum..."
  if [ -z "$1" ]; then
    echo "Error: Invalid tag. Aborting..." && exit 1;
  else
    TAG=$1;
  fi
  LATEST_ARCHIVE="octobercms-$TAG.tar.gz"
  curl -o $LATEST_ARCHIVE -fS#L --connect-timeout 15 https://codeload.github.com/octobercms/october/legacy.tar.gz/{$TAG}
  if hash sha1sum 2>&-; then
    LATEST_ARCHIVE_CHECKSUM=$(sha1sum $LATEST_ARCHIVE | awk '{print $1}')
  elif hash openssl 2>&-; then
    LATEST_ARCHIVE_CHECKSUM=$(openssl sha1 $LATEST_ARCHIVE | awk '{print $2}')
  else
    echo "Error: Could not generate checksum. Aborting" && exit 1;
  fi
  echo "     $TAG | $LATEST_ARCHIVE_CHECKSUM"
  rm $LATEST_ARCHIVE
}

echo " - Querying October CMS API for updates..."
check_october

if [ "$(echo "$OCTOBER_API_RESPONSE" | jq -r '. | .update')" == "0" ]; then
  STABLE_UPDATE=0
  echo "    No STABLE build updates ($OCTOBERCMS_BUILD)";
else
  STABLE_BUILD=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .build')
  STABLE_CORE_HASH=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .hash')
  STABLE_UPDATE=1
  echo "    New STABLE build ($OCTOBERCMS_BUILD -> $STABLE_BUILD)";
  echo "     STABLE Build: $STABLE_BUILD"
  echo "     STABLE core hash: $STABLE_CORE_HASH"
fi

echo " - Fetching GitHub repository for latest tag..."

GITHUB_API_RESPONSE=$(curl -fsS --connect-timeout 15 https://api.github.com/repos/octobercms/october/tags)
GITHUB_LATEST_TAG=$( echo "$GITHUB_API_RESPONSE" | jq -r '.[0] | .name') || exit 1;
echo "    Latest repo tag: $GITHUB_LATEST_TAG"

if [ "$STABLE_UPDATE" -eq 1 ]; then
  update_checksum "v1.0.$STABLE_BUILD"
  STABLE_CHECKSUM=$LATEST_ARCHIVE_CHECKSUM
else
  STABLE_CHECKSUM=$OCTOBERCMS_CHECKSUM
fi

function update_dockerfiles {

  current_tag="v1.0.$STABLE_BUILD"
  checksum=$STABLE_CHECKSUM

	phpVersions=( php*.*/ )
  phpVersions=( "${phpVersions[@]%/}" )

  for phpVersion in "${phpVersions[@]}"; do
    echo $phpVersion
  	phpVersionDir="$phpVersion"
  	phpVersion="${phpVersion#php}"

  	for variant in apache fpm; do
  		dir="$phpVersionDir/$variant"
  		mkdir -p "$dir"

  		if [ "$variant" == "apache" ]; then
  			extras="RUN a2enmod rewrite"
  			cmd="apache2-foreground"
  		elif [ "$variant" == "fpm" ]; then
  			extras=""
  			cmd="php-fpm"
  		fi

			sed \
				-e 's!%%OCTOBERCMS_TAG%%!'"$current_tag"'!g' \
				-e 's!%%OCTOBERCMS_CHECKSUM%%!'"$checksum"'!g' \
				-e 's!%%PHP_VERSION%%!'"$phpVersion"'!g' \
				-e 's!%%VARIANT%%!'"$variant"'!g' \
				-e 's!%%VARIANT_EXTRAS%%!'"$extras"'!g' \
				-e 's!%%CMD%%!'"$cmd"'!g' \
				Dockerfile.template > "$dir/Dockerfile"

  			cp docker-entrypoint.sh "$dir/docker-entrypoint.sh"
  	done
  done
}

if [ "$STABLE_UPDATE" -eq 1 ]; then
  if [ -z "$STABLE_BUILD" ] || [ -z "$STABLE_CORE_HASH" ] || [ -z "$STABLE_CHECKSUM" ]; then
    echo " - No STABLE build, core hash or checksum";
  else
    echo " - Setting new build values..."
    echo "    OCTOBERCMS_BUILD: $STABLE_BUILD" && sed -i '' -e "s/^\(OCTOBERCMS_BUILD\s*=\s*\).*$/\1$STABLE_BUILD/" version
    echo "    OCTOBERCMS_CORE_HASH: $STABLE_CORE_HASH" && sed -i '' -e "s/^\(OCTOBERCMS_CORE_HASH\s*=\s*\).*$/\1$STABLE_CORE_HASH/" version
    echo "    OCTOBERCMS_CHECKSUM: $STABLE_CHECKSUM" && sed -i '' -e "s/^\(OCTOBERCMS_CHECKSUM\s*=\s*\).*$/\1$STABLE_CHECKSUM/" version
    update_dockerfiles
  fi
fi

echo " - Update complete." && exit 0;
