@echo off

echo Generating App Localizations
call flutter gen-l10n ^
  --arb-dir assets/localization ^
  --no-nullable-getter ^
  --output-localization-file app_localizations.dart ^
  --preferred-supported-locales en ^
  --template-arb-file app_en.arb ^
  --untranslated-messages-file i18n_untranslated_app.json ^
  --use-escaping
if %errorlevel% neq 0 (
  echo Error generating app l10n
  echo Error code: %errorlevel%
)

echo Generating Location Localizations
call flutter gen-l10n ^
  --arb-dir assets/localization/locations ^
  --no-nullable-getter ^
  --output-class LocationsLocalizations ^
  --output-localization-file locations_localizations.dart ^
  --preferred-supported-locales en ^
  --template-arb-file locations_en.arb ^
  --untranslated-messages-file i18n_untranslated_locations.json ^
  --use-escaping
if %errorlevel% neq 0 (
  echo Error generating locations l10n
  echo Error code: %errorlevel%
  exit /b 1
)
