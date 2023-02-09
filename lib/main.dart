import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/logs/repositories/provider_logger.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'src/app.dart';

Future<UncontrolledProviderScope> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    observers: [ProviderLogger()],
    overrides: [
      sharedPreferencesRepository.overrideWithValue(preferences),
    ],
  );
  container.read(plansRepository);
  container.read(locationsRepository);
  container.read(eventsRepository);
  container.read(schedulesRepository);
  container.read(bibleLanguagesRepository);
  container.read(themeModeRepository);

  final uncontrolledProviderScope = UncontrolledProviderScope(
    container: container,
    child: const App(),
  );

  runApp(uncontrolledProviderScope);

  return uncontrolledProviderScope;
}
