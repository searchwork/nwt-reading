import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedule/repositories/schedules_repository.dart';

import 'src/app.dart';
import 'src/settings/repositories/theme_mode_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final container = ProviderContainer(observers: [Logger()]);
  await container.read(themeModeProvider.future);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const App(),
  ));
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
