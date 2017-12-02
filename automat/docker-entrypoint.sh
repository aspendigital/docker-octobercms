#!/bin/bash
set -eu

# Git profile config
git config --global user.email $GIT_USER_EMAIL
git config --global user.name $GIT_USER_NAME

# Add repository key
echo "$GIT_REPO_KEY" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Reset git remote URL to allow key
git remote set-url origin git@github.com:aspendigital/docker-octobercms.git
git pull
./update.sh --push

exec "$@"
