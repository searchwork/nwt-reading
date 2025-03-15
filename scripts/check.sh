#!/bin/sh
set -e
DIR=$(dirname "$(realpath $0)")

flutter --version
flutter pub get

$DIR/gen_i10n.sh

dart format --version
dart format --set-exit-if-changed .
dart analyze --fatal-infos
flutter test --coverage
