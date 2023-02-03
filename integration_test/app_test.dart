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
    final uncontrolledProviderScope =
        await SettledTester(tester).uncontrolledProviderScope;
    final container = uncontrolledProviderScope.container;

    expect(
        deepCollectionEquals(
            container.read(plansNotifierProvider).valueOrNull?.plans, <Plan>[]),
        true);
    expect(container.read(locationsProvider).valueOrNull, isA<Locations>());
    expect(container.read(eventsProvider).valueOrNull, isA<Events>());
    expect(container.read(schedulesProvider).valueOrNull, isA<Schedules>());
    expect(container.read(bibleLanguagesProvider).valueOrNull,
        isA<BibleLanguages>());
    expect(container.read(themeModeProvider).valueOrNull, ThemeMode.system);
  });

  testWidgets('No plans', (tester) async {
    await SettledTester(tester).uncontrolledProviderScope;

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });

  testWidgets('Add plans', (tester) async {
    final uncontrolledProviderScope =
        await SettledTester(tester).uncontrolledProviderScope;
    final container = uncontrolledProviderScope.container;
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(container.read(plansNotifierProvider).valueOrNull?.plans.length, 1);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(container.read(plansNotifierProvider).valueOrNull?.plans.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });

  testWidgets('Check day 34', (tester) async {
    final uncontrolledProviderScope =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .uncontrolledProviderScope;
    final container = uncontrolledProviderScope.container;
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
        container
            .read(plansNotifierProvider)
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
    final uncontrolledProviderScope =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .uncontrolledProviderScope;
    final container = uncontrolledProviderScope.container;

    await tester.scrollUntilVisible(
      find.byKey(Key(
          'plan-${container.read(plansNotifierProvider).valueOrNull?.plans.last.id}')),
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
        container
            .read(plansNotifierProvider)
            .valueOrNull
            ?.plans
            .last
            .bookmark
            .dayIndex,
        10);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Delete plan', (tester) async {
    final uncontrolledProviderScope =
        await SettledTester(tester, sharedPreferences: testPlansPreferences)
            .uncontrolledProviderScope;
    final container = uncontrolledProviderScope.container;
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(container.read(plansNotifierProvider).valueOrNull?.plans.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });
}
