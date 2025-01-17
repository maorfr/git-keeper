#!/bin/bash

# Required secrets (vault env vars)
# - $CONFIG_TOML
# - $GPG_KEYS
# - $CONFIG_NETRC
# - $USERNAME_PRODUCTION
# - $PASSWORD_PRODUCTION

CONFIG_DIR="$PWD/config"
mkdir -p $CONFIG_DIR/

# get repos
export APP_INTERFACE_USER="${USERNAME_PRODUCTION}"
export APP_INTERFACE_PASSWORD="${PASSWORD_PRODUCTION}"
bash repos.sh > repos.txt

# dump gpg keys to file
echo "$GPG_KEYS" | base64 -d > $CONFIG_DIR/gpg_keys

# get config.toml -- includes s3/gitlab creds
echo "$CONFIG_TOML" | base64 -d > $CONFIG_DIR/config.toml

# hack for .netrc
echo "$CONFIG_NETRC" | base64 -d > $CONFIG_DIR/.netrc
chmod 0666 $CONFIG_DIR/.netrc

cat repos.txt | docker run --rm -i \
            -e GIT_SSL_NO_VERIFY=true \
            -v $CONFIG_DIR:/config:z \
            quay.io/app-sre/git-keeper:latest \
            --config /config/config.toml \
            --gpgs /config/gpg_keys
