flutter --version
flutter pub get

gen_i10n.sh

dart format --version
dart format --fix --set-exit-if-changed .
dart analyze --fatal-infos
flutter test --coverage
