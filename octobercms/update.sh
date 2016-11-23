#!/bin/bash

# Dependency check
if ! hash curl 2>&-; then
  echo "Error: curl is required" && exit 1;
elif ! hash jq 2>&-; then
  echo "Error: jq is required" && exit 1;
fi

if ! hash sha1sum 2>&-; then
  if ! hash openssl 2>&-; then
    echo "Error: openssl/sha1sum is required" && exit 1;
  fi
fi

# Pull in current build values
source version

# Host server PHP version - https://github.com/octobercms/october/blob/97b0bc481f948045f96a420bb54ab48628bfdddc/modules/system/classes/UpdateManager.php#L835
OCTOBERCMS_SERVER_HASH=YToyOntzOjM6InBocCI7czo2OiI3LjAuMTMiO3M6MzoidXJsIjtzOjE2OiJodHRwOi8vbG9jYWxob3N0Ijt9

# Set default NULL HASH if core hash isn't set
if [ -z $OCTOBERCMS_CORE_HASH ]; then
  OCTOBERCMS_CORE_HASH=6c3e226b4d4795d518ab341b0824ec29
fi

echo -n " - Querying October CMS API for updates..."

OCTOBER_API_RESPONSE=$(
  curl --request POST \
    --fail --silent --show-error \
    --connect-timeout 15 \
    --url http://gateway.octobercms.com/api/core/update \
    --header 'cache-control: no-cache' \
    --form core=$OCTOBERCMS_CORE_HASH \
    --form 'plugins=a:0:{}' \
    --form server=$OCTOBERCMS_SERVER_HASH \
    --form build=$OCTOBERCMS_BUILD \
    --form edge=0 )

# Check if cURL exit code. Confirm success (0)
if [ 0 -eq $? ]; then
  OCTOBER_API_UPDATES=$( echo "$OCTOBER_API_RESPONSE" | jq '. | { build: .core.build, hash: .core.hash, update: .update, updates: .core.updates }')
else
  echo "Error: October CMS API query failed" && exit 1;
fi

# Exit if no updates.
if [ "$(echo "$OCTOBER_API_RESPONSE" | jq -r '. | .update')" == "0" ]; then
  echo "up to date" && exit 0;
fi

echo -e "\n - Fetching GitHub repository for latest commit hash..."

GITHUB_API_RESPONSE=$(curl --fail --connect-timeout 15 -sS https://api.github.com/repos/octobercms/october/commits/master)

if [ 0 -eq $? ]; then
  LATEST_COMMIT_HASH=$( echo "$GITHUB_API_RESPONSE" | jq -r '.sha') || exit 1;
else
  echo "Error: GitHub API call failed" && exit 1;
fi

# Compare latest commit hash with stored value.
#  Generate new checksum if new. If not, abort.
if [ "$LATEST_COMMIT_HASH" != "$OCTOBERCMS_MASTER_HASH" ]; then

  echo " - Downloading latest build..."
  LATEST_ARCHIVE="octobercms-$OCTOBERCMS_BUILD.tar.gz"
  curl -o $LATEST_ARCHIVE --fail --show-error --connect-timeout 15 \
   --progress-bar --location https://github.com/octobercms/october/archive/$LATEST_COMMIT_HASH.tar.gz

  if [ 0 -eq $? ]; then
    echo " - Generating new checksum..."
    if hash sha1sum 2>&-; then
      LATEST_ARCHIVE_CHECKSUM=$(sha1sum $LATEST_ARCHIVE | awk '{print $1}')
    elif hash openssl 2>&-; then
      LATEST_ARCHIVE_CHECKSUM=$(openssl sha1 $LATEST_ARCHIVE | awk '{print $2}')
    else
      echo "Error: Could not generate checksum" && exit 1;
    fi
    echo " - Removing latest build..."
    rm $LATEST_ARCHIVE
  else
    echo "Error: Failed to download GitHub archive" && exit 1;
  fi
else
  echo " - The latest commit on master hasn't changed. Aborting..." && exit 0;
fi

NEW_BUILD=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .build')
NEW_CORE_HASH=$(echo "$OCTOBER_API_UPDATES" | jq -r '. | .hash')

if [ -z "$NEW_BUILD" ] || [ -z "$NEW_CORE_HASH" ] || [ -z "$LATEST_ARCHIVE_CHECKSUM" ]; then
  echo "Error: No new build, core hash or archive checksum" && exit 1;
else
  echo " - Setting new build values..." && echo "# Updated `date +%Y-%m-%d-%H%M%S`" > version
  echo "    OCTOBERCMS_BUILD: $NEW_BUILD" && echo "OCTOBERCMS_BUILD=$NEW_BUILD" >> version
  echo "    OCTOBERCMS_CORE_HASH: $NEW_CORE_HASH" && echo "OCTOBERCMS_CORE_HASH=$NEW_CORE_HASH" >> version
  echo "    OCTOBERCMS_MASTER_HASH: $LATEST_COMMIT_HASH" && echo "OCTOBERCMS_MASTER_HASH=$LATEST_COMMIT_HASH" >> version
  echo "    OCTOBERCMS_CHECKSUM: $LATEST_ARCHIVE_CHECKSUM" && echo "OCTOBERCMS_CHECKSUM=$LATEST_ARCHIVE_CHECKSUM" >> version
fi

echo " - Update complete."

# echo $(echo "$OCTOBER_API_UPDATES" | jq '. | .updates')
exit 0;
