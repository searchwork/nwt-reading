import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

import 'src/app.dart';

Future<UncontrolledProviderScope> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(observers: [Logger()]);
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

class Logger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint(
        'didAddProvider: ${provider.name ?? provider.runtimeType} -- value: ${value.toString()}');
  }

  @override
  void providerDidFail(ProviderBase provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    debugPrint(
        'didAddProvider: ${provider.name ?? provider.runtimeType} -- error: ${error.toString()}');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    debugPrint('didAddProvider: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint(
        'didAddProvider: ${provider.name ?? provider.runtimeType} -- newValue: $newValue');
  }
}
