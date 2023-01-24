flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
flutter test

flutter build apk
flutter build appbundle

if [[ $(uname) == 'Darwin' ]]; then
    flutter build ios --release --no-codesign

    flutter build web

    flutter config --enable-macos-desktop
    flutter build macos
fi
