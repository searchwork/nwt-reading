#!/bin/sh
set -e
DIR=$(dirname "$(realpath $0)")
$DIR/test.sh

flutter build apk --release
flutter build appbundle --release

if [[ $(uname) == 'Darwin' ]]; then
    flutter build ios --release
    flutter config --enable-macos-desktop
    flutter build macos
fi

flutter build web
