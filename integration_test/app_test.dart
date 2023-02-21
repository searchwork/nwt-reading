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
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/theme_mode_repository.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

import 'settled_tester.dart';
import 'take_screenshot.dart';
import 'test_plans.dart';

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

  testWidgets('Initially, there are no plans', (tester) async {
    await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });

  testWidgets('Adding plans', (tester) async {
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

  testWidgets('Show schedule of last plan', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    final lastPlanCardFinder = find.byKey(Key(
        'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}'));
    await tester.scrollUntilVisible(lastPlanCardFinder, 500.0);
    await tester.pumpAndSettle();

    expect(find.byType(Card).last.evaluate(), lastPlanCardFinder.evaluate());

    await tester.tap(lastPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard), findsWidgets);
  });

  testWidgets('Schedule starts at bookmark', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    final lastPlanCardFinder = find.byKey(Key(
        'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}'));
    await takeScreenshot(tester: tester, binding: binding, filename: 'plans');
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-75')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-0')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(lastPlanCardFinder, 500.0);
    await tester.pumpAndSettle();
    await tester.tap(lastPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).last.evaluate(),
        find.byKey(const Key('day-182')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);
  });

  testWidgets('Check day', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-115')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-115')),
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
        115);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Uncheck day', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      -500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

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
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Bookmark button resets schedule view', (tester) async {
    await SettledTester(tester, sharedPreferences: testPlansPreferences)
        .providerContainer;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-33')),
      -500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-34')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-70')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-33')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    await takeScreenshot(
        tester: tester, binding: binding, filename: 'schedule');
  });

  testWidgets('Change plan type', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await takeScreenshot(tester: tester, binding: binding, filename: 'edit');
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.scheduleKey.type, ScheduleType.written);
    expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.scheduleKey.type, ScheduleType.sequential);
    expect(plan?.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.hourglass_empty));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.scheduleKey.type, ScheduleType.chronological);
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

  testWidgets('Change plan language', (tester) async {
    final providerContainer =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .providerContainer;
    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${providerContainer.read(plansNotifier).valueOrNull?.plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-es')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.language, 'en');

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language-es')).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.language, 'es');
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
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    final plan = providerContainer.read(plansNotifier).valueOrNull?.plans.first;
    expect(plan?.scheduleKey.type, ScheduleType.chronological);
    expect(plan?.bookmark, const Bookmark(dayIndex: 75, sectionIndex: 0));
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
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    final plans = providerContainer.read(plansNotifier).valueOrNull?.plans;
    expect(plans?.last.id, "2dab49f3-aecf-4aba-9e91-d75c297d4b7e");
    expect(plans?.length, 3);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(3));
  });
}
