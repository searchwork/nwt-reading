import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/logs/repositories/provider_logger.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';

Future<UncontrolledProviderScope> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    observers: [ProviderLogger()],
    overrides: [
      sharedPreferencesRepositoryProvider.overrideWithValue(sharedPreferences),
    ],
  );
  container.read(plansRepositoryProvider).load();
  container.read(locationsRepositoryProvider);
  container.read(eventsRepositoryProvider);
  container.read(schedulesRepositoryProvider);
  container.read(bibleLanguagesRepositoryProvider);
  container.read(settingsRepositoryProvider);

  final uncontrolledProviderScope = UncontrolledProviderScope(
    container: container,
    child: const App(),
  );

  runApp(uncontrolledProviderScope);

  return uncontrolledProviderScope;
}
