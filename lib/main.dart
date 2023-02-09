import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/logs/repositories/provider_logger.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

import 'src/app.dart';

Future<UncontrolledProviderScope> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(observers: [ProviderLogger()]);
  container.read(plansRepository);
  container.read(locationsRepository);
  container.read(eventsRepository);
  container.read(schedulesRepository);
  container.read(bibleLanguagesRepository);
  container.read(themeModeRepository);
  await container.read(themeModeProvider.future);

  final uncontrolledProviderScope = UncontrolledProviderScope(
    container: container,
    child: const App(),
  );

  runApp(uncontrolledProviderScope);

  return uncontrolledProviderScope;
}
