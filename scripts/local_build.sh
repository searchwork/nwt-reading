#!/bin/sh
DIR=$(dirname "$(pwd)/$0")
$DIR/check.sh

if [[ $(uname) == 'Darwin' ]]; then
    flutter test integration_test --device-id macos --coverage
fi

flutter build apk --release
flutter build appbundle --release

if [[ $(uname) == 'Darwin' ]]; then
    flutter build ios --release

    flutter build web

    flutter config --enable-macos-desktop
    flutter build macos
fi
