#!/bin/bash
set -e

# Dependency check
if ! hash curl 2>&-; then echo "Error: curl is required" && exit 1; fi
if ! hash jq 2>&-; then echo "Error: jq is required" && exit 1; fi
if ! hash sha1sum 2>&-; then { if ! hash openssl 2>&-; then echo "Error: openssl/sha1sum is required" && exit 1; fi } fi

# Pull in current build values
source version

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

echo " - Querying October CMS API for updates..."
check_october

if [ "$(echo "$OCTOBER_API_RESPONSE" | jq -r '. | .update')" == "0" ]; then
  STABLE_BUILD=$OCTOBERCMS_BUILD
  STABLE_CORE_HASH=$OCTOBERCMS_CORE_HASH
  STABLE_UPDATE=0
  echo "    No STABLE build updates";
else
  STABLE_BUILD=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .build')
  STABLE_CORE_HASH=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .hash')
  STABLE_UPDATE=1
  echo "    New STABLE build ($OCTOBERCMS_BUILD -> $STABLE_BUILD)";
fi

echo "     STABLE Build: $STABLE_BUILD"
echo "     STABLE core hash: $STABLE_CORE_HASH"

# Check EDGE updates
echo " - Querying October CMS API for EDGE updates..."
check_october edge

if [ "$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .build')" -eq "$OCTOBERCMS_EDGE_BUILD" ]; then
  EDGE_BUILD=$OCTOBERCMS_EDGE_BUILD
  EDGE_CORE_HASH=$OCTOBERCMS_EDGE_CORE_HASH
  EDGE_UPDATE=0
  echo "    No EDGE build updates";
else
  EDGE_BUILD=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .build')
  EDGE_CORE_HASH=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .hash')
  EDGE_UPDATE=1
  echo "    New EDGE build ($OCTOBERCMS_EDGE_BUILD -> $EDGE_BUILD)";
fi

echo "     EDGE Build: $EDGE_BUILD"
echo "     EDGE core hash: $EDGE_CORE_HASH"

echo " - Fetching GitHub repository for latest tag..."

GITHUB_API_RESPONSE=$(curl -fsS --connect-timeout 15 https://api.github.com/repos/octobercms/october/tags)
GITHUB_LATEST_TAG=$( echo "$GITHUB_API_RESPONSE" | jq -r '.[0] | .name') || exit 1;
GITHUB_EDGE_BUILD=${GITHUB_LATEST_TAG#*0.} #Strip v1.0.
echo "     Latest repo tag: $GITHUB_LATEST_TAG"


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

if [ "$STABLE_UPDATE" -eq 1 ]; then
  update_checksum "v1.0.$STABLE_BUILD"
  STABLE_CHECKSUM=$LATEST_ARCHIVE_CHECKSUM
else
  STABLE_CHECKSUM=$OCTOBERCMS_CHECKSUM
fi

if [ "$EDGE_UPDATE" -eq 1 ]; then
  if [ "$GITHUB_EDGE_BUILD" -eq "$EDGE_BUILD" ]; then
    update_checksum $GITHUB_LATEST_TAG
    EDGE_CHECKSUM=$LATEST_ARCHIVE_CHECKSUM
  else
    echo "Error: October CMS API and the GitHub repo's latest tag do not match. Aborting..." && exit 1;
  fi
else
  EDGE_CHECKSUM=$OCTOBERCMS_EDGE_CHECKSUM
fi

if [ -z "$STABLE_BUILD" ] || [ -z "$STABLE_CORE_HASH" ] || [ -z "$STABLE_CHECKSUM" ] || [ "$STABLE_UPDATE" -eq 0 ]; then
  echo " - No new STABLE build, core hash or checksum";
else
  echo " - Setting new build values..."
  echo "    OCTOBERCMS_BUILD: $STABLE_BUILD" && sed -i '' -e "s/^\(OCTOBERCMS_BUILD\s*=\s*\).*$/\1$STABLE_BUILD/" version
  echo "    OCTOBERCMS_CORE_HASH: $STABLE_CORE_HASH" && sed -i '' -e "s/^\(OCTOBERCMS_CORE_HASH\s*=\s*\).*$/\1$STABLE_CORE_HASH/" version
  echo "    OCTOBERCMS_CHECKSUM: $STABLE_CHECKSUM" && sed -i '' -e "s/^\(OCTOBERCMS_CHECKSUM\s*=\s*\).*$/\1$STABLE_CHECKSUM/" version
fi

if [ -z "$EDGE_BUILD" ] || [ -z "$EDGE_CORE_HASH" ] || [ -z "$EDGE_CHECKSUM" ] || [ "$EDGE_UPDATE" -eq 0 ]; then
  echo " - No new EDGE build, core hash or checksum";
else
  echo " - Setting EDGE build values..."
  echo "    OCTOBERCMS_EDGE_BUILD: $EDGE_BUILD" && sed -i '' -e "s/^\(OCTOBERCMS_EDGE_BUILD\s*=\s*\).*$/\1$EDGE_BUILD/" version
  echo "    OCTOBERCMS_EDGE_CORE_HASH: $EDGE_CORE_HASH" && sed -i '' -e "s/^\(OCTOBERCMS_EDGE_CORE_HASH\s*=\s*\).*$/\1$EDGE_CORE_HASH/" version
  echo "    OCTOBERCMS_EDGE_CHECKSUM: $EDGE_CHECKSUM" && sed -i '' -e "s/^\(OCTOBERCMS_EDGE_CHECKSUM\s*=\s*\).*$/\1$EDGE_CHECKSUM/" version
fi

echo " - Update complete." && exit 0;
