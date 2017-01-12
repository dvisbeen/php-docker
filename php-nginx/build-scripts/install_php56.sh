#!/bin/bash

# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# A shell script for installing PHP 5.6.x.
set -xe

apt-get install -y \
        gcp-php56 \
        gcp-php56-apcu \
        gcp-php56-grpc \
        gcp-php56-json \
        gcp-php56-mailparse \
        gcp-php56-memcache \
        gcp-php56-memcached \
        gcp-php56-mongodb \
        gcp-php56-redis \
        gcp-php56-suhosin

# Enable some extensions for backward compatibility
${PHP56_DIR}/bin/php56-enmod apcu
${PHP56_DIR}/bin/php56-enmod json
${PHP56_DIR}/bin/php56-enmod mailparse
${PHP56_DIR}/bin/php56-enmod memcached

# Making php56 the default version
ln -s ${PHP56_DIR} ${PHP_DIR}

# Install composer
EXPECTED_SIGNATURE=$(curl -f https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid composer installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php \
    --quiet \
    --install-dir=/usr/local/bin \
    --filename=composer

rm composer-setup.php