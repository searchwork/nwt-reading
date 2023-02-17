import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';

import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

import 'take_screenshot.dart';
import 'test_plans.dart';
import 'settled_tester.dart';

void main() async {
  final deepCollectionEquals = const DeepCollectionEquality().equals;
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('Entities are initialized', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(await providerContainer.read(bibleLanguagesNotifier.future),
        isA<BibleLanguages>());
    expect(await providerContainer.read(eventsNotifier.future), isA<Events>());
    expect(await providerContainer.read(locationsNotifier.future),
        isA<Locations>());
    expect(
        deepCollectionEquals(
            (await providerContainer.read(plansNotifier.future)).plans,
            <Plan>[]),
        true);
    expect(await providerContainer.read(schedulesNotifier.future),
        isA<Schedules>());
    expect(await providerContainer.read(themeModeNotifier.future),
        ThemeMode.system);

    for (ProviderBase<Object?> provider in [
      bibleLanguagesRepository,
      eventsRepository,
      locationsRepository,
      plansRepository,
      schedulesRepository,
      sharedPreferencesRepository,
      themeModeRepository,
    ]) {
      expect(providerContainer.exists(provider), true);
    }
  });

  testWidgets('No plans', (tester) async {
    await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });

  testWidgets('Add plans', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansNotifier).valueOrNull?.plans.length, 1);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansNotifier).valueOrNull?.plans.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });

  testWidgets('Check day 34', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await takeScreenshot(tester: tester, binding: binding, filename: 'plans');
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('day-0')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      500.0,
    );
    await tester.pumpAndSettle();
    await takeScreenshot(
        tester: tester, binding: binding, filename: 'schedule');

    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-33')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(
        providerContainer
            .read(plansNotifier)
            .valueOrNull
            ?.plans
            .first
            .bookmark
            .dayIndex,
        33);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
  });

  testWidgets('Uncheck day 10', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );

    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('day-0')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-10')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
    expect(find.byIcon(Icons.check_circle), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-10')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(
        providerContainer
            .read(plansNotifier)
            .valueOrNull
            ?.plans
            .last
            .bookmark
            .dayIndex,
        10);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Change plan type', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await takeScreenshot(tester: tester, binding: binding, filename: 'edit');
    await tester.tap(find.byIcon(Icons.hourglass_empty));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansNotifier).valueOrNull?.plans.last;
    expect(plan?.scheduleKey.type, ScheduleType.chronological);
    expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansNotifier).valueOrNull?.plans.last;
    expect(plan?.scheduleKey.type, ScheduleType.written);
    expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansNotifier).valueOrNull?.plans.last;
    expect(plan?.scheduleKey.type, ScheduleType.sequential);
    expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));
  });

  testWidgets('Change plan duration', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();

    for (var duration in ScheduleDuration.values) {
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find
          .descendant(
              of: find.byType(SegmentedButton<ScheduleDuration>),
              matching: find.byType(Text))
          .at(duration.index));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      var plan = providerContainer.read(plansNotifier).valueOrNull?.plans.last;
      expect(plan?.scheduleKey.duration, duration);
      expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));
    }
  });

  testWidgets('Cancel edit plan', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.hourglass_empty));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    final plan = providerContainer.read(plansNotifier).valueOrNull?.plans.last;
    expect(plan?.scheduleKey.type, ScheduleType.written);
    expect(plan?.bookmark, const Bookmark(dayIndex: 364, sectionIndex: 1));
  });

  testWidgets('Delete plan', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.hourglass_empty));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    final plans = providerContainer.read(plansNotifier).valueOrNull?.plans;
    expect(plans?.last.id, "0da6b8a7-ccd4-4270-8058-9e30a3f55ceb");
    expect(plans?.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });
}
