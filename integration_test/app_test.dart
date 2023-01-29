import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nwt_reading/main.dart' as app;
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final deepCollectionEquals = const DeepCollectionEquality().equals;
  SharedPreferences.setMockInitialValues({});
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final ProviderContainer container = await app.main();

  testWidgets('Initialized to system theme', (tester) async {
    await tester.pumpAndSettle();
    final actualTheme = await container.read(themeModeProvider.future);

    expect(actualTheme, ThemeMode.system);
  });

  testWidgets('Entities are initialized', (tester) async {
    await tester.pumpAndSettle();

    expect(
        deepCollectionEquals(
            container.read(plansProvider).valueOrNull?.plans, <Plan>[]),
        true);
    expect(container.read(locationsProvider).valueOrNull, isA<Locations>());
    expect(container.read(eventsProvider).valueOrNull, isA<Events>());
    expect(container.read(schedulesProvider).valueOrNull, isA<Schedules>());
    expect(container.read(bibleLanguagesProvider).valueOrNull,
        isA<BibleLanguages>());
    expect(container.read(themeModeProvider).valueOrNull, isA<ThemeMode>());
  });
}
