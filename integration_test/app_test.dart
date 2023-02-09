import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/settings/stories/theme_mode_story.dart';

import '../test/test_plans.dart';
import 'settled_tester.dart';

void main() async {
  final deepCollectionEquals = const DeepCollectionEquality().equals;
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('Entities are initialized', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(
        deepCollectionEquals(
            providerContainer.read(plansNotifier).valueOrNull?.plans, <Plan>[]),
        true);
    expect(providerContainer.read(locationsNotifier).valueOrNull,
        isA<Locations>());
    expect(providerContainer.read(eventsNotifier).valueOrNull, isA<Events>());
    expect(providerContainer.read(schedulesNotifier).valueOrNull,
        isA<Schedules>());
    expect(providerContainer.read(bibleLanguagesNotifier).valueOrNull,
        isA<BibleLanguages>());
    expect(providerContainer.read(themeModeProvider).valueOrNull,
        ThemeMode.system);
  });

  testWidgets('No plans', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

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
