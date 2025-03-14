#!/bin/sh
set -e
DIR=$(dirname "$(realpath $0)")
echo $DIR
$DIR/check.sh

if [[ $(uname) == 'Darwin' ]]; then
    flutter test integration_test --device-id macos --coverage
else
    flutter test integration_test --coverage
fi
