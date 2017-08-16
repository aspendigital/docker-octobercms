#!/bin/bash
set -e

#####################
### Dependency check

if ! hash curl 2>&-; then echo "Error: curl is required" && exit 1; fi
if ! hash jq 2>&-; then echo "Error: jq is required" && exit 1; fi
if ! hash sha1sum 2>&-; then { if ! hash openssl 2>&-; then echo "Error: openssl/sha1sum is required" && exit 1; fi } fi

##############
### Functions

function check_october {
  [ "$1" = "edge" ] && EDGE=1 || EDGE=0

  # Host server PHP version - https://github.com/octobercms/october/blob/97b0bc481f948045f96a420bb54ab48628bfdddc/modules/system/classes/UpdateManager.php#L835
  OCTOBERCMS_SERVER_HASH=YToyOntzOjM6InBocCI7czo2OiI3LjAuMTMiO3M6MzoidXJsIjtzOjE2OiJodHRwOi8vbG9jYWxob3N0Ijt9

  # Set default NULL HASH if core hash isn't set
  [ -z "$OCTOBERCMS_CORE_HASH" ] && OCTOBERCMS_CORE_HASH=6c3e226b4d4795d518ab341b0824ec29
  [ -z "$OCTOBERCMS_EDGE_CORE_HASH" ] && OCTOBERCMS_EDGE_CORE_HASH=6c3e226b4d4795d518ab341b0824ec29

  [ "$EDGE" -eq 1 ] && CORE_HASH="$OCTOBERCMS_EDGE_CORE_HASH" || CORE_HASH="$OCTOBERCMS_CORE_HASH";
  [ "$EDGE" -eq 1 ] && CORE_BUILD="$OCTOBERCMS_EDGE_BUILD" || CORE_BUILD="$OCTOBERCMS_BUILD";

  curl -X POST -fsS --connect-timeout 15 --url http://gateway.octobercms.com/api/core/update \
   -F "build=$CORE_BUILD" -F "core=$CORE_HASH" -F "plugins=a:0:{}" -F "server=$OCTOBERCMS_SERVER_HASH" -F "edge=$EDGE" \
    | jq '. | { build: .core.build, hash: .core.hash, update: .update, updates: .core.updates }' || exit 1
}

function update_checksum {
  if [ -z "$1" ]; then
    echo "Error: Invalid slug. Aborting..." && exit 1;
  else
    local SLUG=$1;
  fi

  local ARCHIVE="octobercms-$SLUG.tar.gz"
  curl -o $ARCHIVE -fS#L --connect-timeout 15 https://codeload.github.com/octobercms/october/tar.gz/$SLUG || exit 1;
  if hash sha1sum 2>&-; then
    sha1sum $ARCHIVE | awk '{print $1}'
  elif hash openssl 2>&-; then
    openssl sha1 $ARCHIVE | awk '{print $2}'
  else
    echo "Error: Could not generate checksum. Aborting" && exit 1;
  fi
  rm $ARCHIVE
}

function update_dockerfiles {

  [ "$1" = "edge" ] && local current_tag="v1.0.$EDGE_BUILD" || local current_tag="v1.0.$STABLE_BUILD"
  [ "$1" = "edge" ] && local checksum=$EDGE_CHECKSUM || local checksum=$STABLE_CHECKSUM
  [ "$1" = "edge" ] && local hash=$EDGE_CORE_HASH || local hash=$STABLE_CORE_HASH
  [ "$1" = "edge" ] && local build=$EDGE_BUILD || local build=$STABLE_BUILD
  [ "$1" = "edge" ] && local ext=".edge" || local ext=""
  [ "$1" = "edge" ] && local phpVersions=( php7.*/ ) || local phpVersions=( php*.*/ )

  phpVersions=( "${phpVersions[@]%/}" )

  for phpVersion in "${phpVersions[@]}"; do
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
				-e '/^#.*$/d' -e '/^  #.*$/d' \
				-e 's!%%OCTOBERCMS_TAG%%!'"$current_tag"'!g' \
				-e 's!%%OCTOBERCMS_CHECKSUM%%!'"$checksum"'!g' \
				-e 's!%%OCTOBERCMS_CORE_HASH%%!'"$hash"'!g' \
				-e 's!%%OCTOBERCMS_CORE_BUILD%%!'"$build"'!g' \
				-e 's!%%OCTOBERCMS_DEVELOP_COMMIT%%!'"$GITHUB_LATEST_COMMIT"'!g' \
				-e 's!%%OCTOBERCMS_DEVELOP_CHECKSUM%%!'"$GITHUB_LATEST_CHECKSUM"'!g' \
				-e 's!%%PHP_VERSION%%!'"$phpVersion"'!g' \
				-e 's!%%VARIANT%%!'"$variant"'!g' \
				-e 's!%%VARIANT_EXTRAS%%!'"$extras"'!g' \
				-e 's!%%CMD%%!'"$cmd"'!g' \
				Dockerfile$ext.template > "$dir/Dockerfile$ext"

  	done
  done
}

function join {
	local sep="$1"; shift
	local out; printf -v out "${sep//%/%%}\`%s\`" "$@"
	echo "${out#$sep}"
}

function update_buildtags {

  defaultPhpVersion='php7.1'
  defaultVariant='apache'

  phpFolders=( php*.*/ )
  phpVersions=()
  # process in descending order
  for (( idx=${#phpFolders[@]}-1 ; idx>=0 ; idx-- )) ; do
  	phpVersions+=( "${phpFolders[idx]%/}" )
  done

  for phpVersion in "${phpVersions[@]}"; do
  	for variant in apache fpm; do
  		dir="$phpVersion/$variant"
  		[ -f "$dir/Dockerfile" ] || continue

  		fullVersion="$(cat "$dir/Dockerfile" | awk '$1 == "ENV" && $2 == "OCTOBERCMS_CORE_BUILD" { print $3; exit }')"
  		fullVersion=build.$fullVersion

      versionAliases=()
  		versionAliases+=( $fullVersion latest )

      phpVersionVariantAliases=( "${versionAliases[@]/%/-$phpVersion-$variant}" )
  		phpVersionVariantAliases=( "${phpVersionVariantAliases[@]//latest-/}" )

  		fullAliases=( "${phpVersionVariantAliases[@]}" )

  		if [ "$phpVersion" = "$defaultPhpVersion" ]; then
  			if [ "$variant" = "$defaultVariant" ]; then
  				fullAliases+=( "${versionAliases[@]}" )
  			fi
  		fi

      # Build edge tags
      [ -f "$dir/Dockerfile.edge" ] || continue
      edgeVersion="$(cat "$dir/Dockerfile.edge" | awk '$1 == "ENV" && $2 == "OCTOBERCMS_CORE_BUILD" { print $3; exit }')"
      edgeVersion=build.$edgeVersion

      edgeAliases=()
      edgeAliases+=( $edgeVersion edge )

      phpEdgeVersionVariantAliases=( "${edgeAliases[@]/%/-$phpVersion-$variant}" )
      phpEdgeVersionVariantAliases=( "${phpEdgeVersionVariantAliases[@]//latest-/}" )

      fullEdgeAliases=( "${phpEdgeVersionVariantAliases[@]}" )

      if [ "$phpVersion" = "$defaultPhpVersion" ]; then
  			if [ "$variant" = "$defaultVariant" ]; then
  				fullEdgeAliases+=( "${edgeAliases[@]}" )
  			fi
  		fi

  		tagsMarkdown+="- $(join ', ' "${fullAliases[@]}"): [$dir/Dockerfile](https://github.com/aspendigital/docker-octobercms/blob/master/$dir/Dockerfile)\n"
  		edgeTagsMarkdown+="- $(join ', ' "${fullEdgeAliases[@]}"): [$dir/Dockerfile.edge](https://github.com/aspendigital/docker-octobercms/blob/master/$dir/Dockerfile.edge)\n"
  	done
  done

	# Recreate README.md
	sed '/Supported Tags/q' README.md \
   | sed -e "s/CMS Build [0-9]*/CMS Build $STABLE_BUILD/" \
   | sed -e "s/CMS%20Build-[0-9]*/CMS%20Build-$STABLE_BUILD/" \
   | sed -e "s/Edge Build [0-9]*/Edge Build $EDGE_BUILD/" \
   | sed -e "s/Edge%20Build-[0-9]*/Edge%20Build-$EDGE_BUILD/" > README_TMP.md
	echo -e "\n${tagsMarkdown[*]}" >> README_TMP.md
  echo -e "\n### Edge Build Tags" >> README_TMP.md
  echo -e "\n${edgeTagsMarkdown[*]}" >> README_TMP.md
	sed -n -e '/Quick Start/,$p' README.md >> README_TMP.md
	mv README_TMP.md README.md
}

function update_repo {
  # commit changes to repository
	echo " - Committing changes to repo..."
  git add php*/*/Dockerfile* README.md version

  if [ "$STABLE_UPDATE" -eq 1 ] && [ "$EDGE_UPDATE" -eq 1 ]; then
    git commit -m "Build $STABLE_BUILD / Edge Build $EDGE_BUILD" -m "Automated update"
  elif [ "$STABLE_UPDATE" -eq 1 ]; then
    git commit -m "Build $STABLE_BUILD" -m "Automated update"
  elif [ "$EDGE_UPDATE" -eq 1 ]; then
    git commit -m "Edge Build $EDGE_BUILD" -m "Automated update"
  fi

  if git rev-parse "build.$STABLE_BUILD" >/dev/null 2>&1; then
    echo "    Tag 'build.$STABLE_BUILD' already exists..."
  else
    echo "    Setting tag 'build.$STABLE_BUILD'..."
    git tag "build.$STABLE_BUILD"
  fi

  if git rev-parse "build.$EDGE_BUILD" >/dev/null 2>&1; then
    echo "    Tag 'build.$EDGE_BUILD' already exists..."
  else
    echo "    Setting tag 'build.$EDGE_BUILD'..."
    git tag "build.$EDGE_BUILD"
  fi

  git push && git push --tags
}

#########################
### Command line options

while true; do
  case "$1" in
    --force)  FORCE=1; shift ;;
    --test)   TEST=1; shift ;;
    *)
      break
  esac
done

########
### Run

echo "Automat: `date`"

[ "$TEST" ] && echo ' - Test mode'
# Load cached version if not forced
[ "$FORCE" ] && echo ' - Force update' || source version


echo " - Querying October CMS API for updates..."
STABLE_RESPONSE=$(check_october)
if [ "$(echo "$STABLE_RESPONSE" | jq -r '. | .update')" == "0" ]; then
  STABLE_UPDATE=0
  STABLE_BUILD=$OCTOBERCMS_BUILD
  STABLE_CORE_HASH=$OCTOBERCMS_CORE_HASH
  STABLE_CHECKSUM=$OCTOBERCMS_CHECKSUM
  echo "    No STABLE build updates ($OCTOBERCMS_BUILD)";
else
  STABLE_UPDATE=1
  STABLE_BUILD=$(echo "$STABLE_RESPONSE" | jq -r '.build')
  STABLE_CORE_HASH=$(echo "$STABLE_RESPONSE" | jq -r '.hash')
  echo "    New STABLE build ($OCTOBERCMS_BUILD -> $STABLE_BUILD)";
  echo "     STABLE Build: $STABLE_BUILD"
  echo "     STABLE core hash: $STABLE_CORE_HASH"
  echo " - Generating new checksum..."
  STABLE_CHECKSUM=$(update_checksum "v1.0.$STABLE_BUILD")
  echo "     GitHub Tag v1.0.$STABLE_BUILD | $STABLE_CHECKSUM"
fi

echo " - Querying October CMS API for EDGE updates..."
EDGE_RESPONSE=$(check_october edge)
if [ "$(echo "$EDGE_RESPONSE" | jq -r '. | .update')" == "0" ]; then
  EDGE_UPDATE=0
  EDGE_BUILD=$OCTOBERCMS_EDGE_BUILD
  EDGE_CORE_HASH=$OCTOBERCMS_EDGE_CORE_HASH
  EDGE_CHECKSUM=$OCTOBERCMS_EDGE_CHECKSUM
  echo "    No EDGE build updates ($OCTOBERCMS_EDGE_BUILD)";
else
  EDGE_UPDATE=1
  EDGE_BUILD=$(echo "$EDGE_RESPONSE" | jq -r '.build')
  EDGE_CORE_HASH=$(echo "$EDGE_RESPONSE" | jq -r '.hash')
  echo "    New EDGE build ($OCTOBERCMS_EDGE_BUILD -> $EDGE_BUILD)";
  echo "     EDGE Build: $EDGE_BUILD"
  echo "     EDGE core hash: $EDGE_CORE_HASH"
  echo " - Generating new checksum..."
  EDGE_CHECKSUM=$(update_checksum "v1.0.$EDGE_BUILD")
  echo "     GitHub Tag v1.0.$EDGE_BUILD | $EDGE_CHECKSUM"
fi

echo " - Fetching GitHub repository for latest tag..."
GITHUB_LATEST_TAG=$( curl -fsS --connect-timeout 15 https://api.github.com/repos/octobercms/october/tags | jq -r '.[0] | .name') || exit 1;
[ -z "$GITHUB_LATEST_TAG" ] && exit 1 || echo "    Latest repo tag: $GITHUB_LATEST_TAG";

echo " - Fetching latest commit on develop branch..."
GITHUB_LATEST_COMMIT=$( curl -fsS --connect-timeout 15 https://api.github.com/repos/octobercms/october/commits/develop | jq -r '.sha') || exit 1;
[ -z "$GITHUB_LATEST_COMMIT" ] && exit 1 || echo "    Latest commit hash: $GITHUB_LATEST_COMMIT";

echo " - Generating develop checksum..."
GITHUB_LATEST_CHECKSUM=$(update_checksum $GITHUB_LATEST_COMMIT)

if [ "$STABLE_UPDATE" -eq 1 ] || [ "$EDGE_UPDATE" -eq 1 ]; then
  echo " - Setting build values..."
  echo "    OCTOBERCMS_BUILD: $STABLE_BUILD" && echo "OCTOBERCMS_BUILD=$STABLE_BUILD" > version
  echo "    OCTOBERCMS_CORE_HASH: $STABLE_CORE_HASH" && echo "OCTOBERCMS_CORE_HASH=$STABLE_CORE_HASH" >> version
  echo "    OCTOBERCMS_CHECKSUM: $STABLE_CHECKSUM" && echo "OCTOBERCMS_CHECKSUM=$STABLE_CHECKSUM" >> version
  echo "    OCTOBERCMS_EDGE_BUILD: $EDGE_BUILD" && echo "OCTOBERCMS_EDGE_BUILD=$EDGE_BUILD" >> version
  echo "    OCTOBERCMS_EDGE_CORE_HASH: $EDGE_CORE_HASH" && echo "OCTOBERCMS_EDGE_CORE_HASH=$EDGE_CORE_HASH" >> version
  echo "    OCTOBERCMS_EDGE_CHECKSUM: $EDGE_CHECKSUM" && echo "OCTOBERCMS_EDGE_CHECKSUM=$EDGE_CHECKSUM" >> version
  echo "    OCTOBERCMS_DEVELOP_COMMIT: $GITHUB_LATEST_COMMIT" && echo "OCTOBERCMS_DEVELOP_COMMIT=$GITHUB_LATEST_COMMIT" >> version
  echo "    OCTOBERCMS_DEVELOP_CHECKSUM: $GITHUB_LATEST_CHECKSUM" && echo "OCTOBERCMS_DEVELOP_CHECKSUM=$GITHUB_LATEST_CHECKSUM" >> version
  update_dockerfiles && update_dockerfiles edge
  update_buildtags
  [ "$TEST" ] && echo ' - Testing. No changes committed.' || update_repo

  if [ "$SLACK_WEBHOOK_URL" ]; then
    echo -n " - Posting update to Slack..."
    curl -X POST -fsS --connect-timeout 15 --data-urlencode "payload={
	    'text': 'October CMS Build $STABLE_BUILD | Edge Build $EDGE_BUILD',
    }" $SLACK_WEBHOOK_URL
    echo -e ""
  fi
fi

echo " - Update complete." && exit 0;
