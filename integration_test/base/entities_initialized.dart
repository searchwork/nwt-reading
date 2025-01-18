import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';

import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/settings_repository.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';

import '../settled_tester.dart';

void testEntitiesInitialized() {
  testWidgets('Entities are initialized', (tester) async {
    final deepCollectionEquals = const DeepCollectionEquality().equals;
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(await providerContainer.read(bibleLanguagesProvider.future),
        isA<BibleLanguages>());
    expect(await providerContainer.read(eventsProvider.future), isA<Events>());
    expect(await providerContainer.read(locationsProvider.future),
        isA<Locations>());
    expect(
        deepCollectionEquals(
            providerContainer.read(plansProvider).plans, <Plan>[]),
        true);
    expect(await providerContainer.read(schedulesProvider.future),
        isA<Schedules>());
    expect(await providerContainer.read(settingsProvider.future),
        Settings(themeMode: ThemeMode.system));

    for (ProviderBase<Object?> provider in [
      bibleLanguagesRepositoryProvider,
      eventsRepositoryProvider,
      locationsRepositoryProvider,
      plansRepositoryProvider,
      schedulesRepositoryProvider,
      sharedPreferencesRepositoryProvider,
      settingsRepositoryProvider,
    ]) {
      expect(providerContainer.exists(provider), true);
    }
  });
}
