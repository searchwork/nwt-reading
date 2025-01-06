import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:nwt_reading/src/base/presentation/plan.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';

import 'package:nwt_reading/src/bible_languages/repositories/bible_languages_repository.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/plans/presentations/plan_name_tile.dart';
import 'package:nwt_reading/src/plans/repositories/plans_repository.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';
import 'package:nwt_reading/src/schedules/presentations/event_widget.dart';
import 'package:nwt_reading/src/schedules/presentations/locations_widget.dart';
import 'package:nwt_reading/src/schedules/repositories/events_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/locations_repository.dart';
import 'package:nwt_reading/src/schedules/repositories/schedules_repository.dart';
import 'package:nwt_reading/src/settings/repositories/settings_repository.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/test_data.dart';
import 'settled_tester.dart';
import 'take_screenshot.dart';

Future<ProviderContainer> getDefaultProviderContainer(
        WidgetTester tester) async =>
    SettledTester(tester, sharedPreferences: {
      ...testPlansPreferences,
      ...await getWhatsNewSeenPreference()
    }).providerContainer;

void main() async {
  final deepCollectionEquals = const DeepCollectionEquality().equals;
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;

  testWidgets('Entities are initialized', (tester) async {
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

  testWidgets('Initially, there are no plans', (tester) async {
    await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });

  testWidgets('Later on What\'s New dialog does not change settings',
      (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('whats-new-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('later')));
    await tester.pumpAndSettle();

    final seenWhatsNewVersion = (await SharedPreferences.getInstance())
        .getString(seenWhatsNewVersionPreferenceKey);
    expect(seenWhatsNewVersion, null);
    expect(await providerContainer.read(settingsProvider.future),
        Settings(themeMode: ThemeMode.system));
    expect(find.byKey(const Key('whats-new-dialog')), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  });

  testWidgets('Got It on What\'s New dialog changes settings', (tester) async {
    final providerContainer = await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('whats-new-dialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('got-it')));
    await tester.pumpAndSettle();

    final version = (await PackageInfo.fromPlatform()).version;
    final seenWhatsNewVersion = (await SharedPreferences.getInstance())
        .getString(seenWhatsNewVersionPreferenceKey);
    expect(seenWhatsNewVersion, version);
    expect(await providerContainer.read(settingsProvider.future),
        Settings(themeMode: ThemeMode.system, seenWhatsNewVersion: version));
    expect(find.byKey(const Key('whats-new-dialog')), findsNothing);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
  });

  testWidgets('Add new plans', (tester) async {
    final providerContainer = await SettledTester(tester,
            sharedPreferences: await getWhatsNewSeenPreference())
        .providerContainer;

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await takeScreenshot(tester: tester, binding: binding, filename: 'new');

    BuildContext buildContext =
        tester.firstElement(find.byKey(const Key('plan-name')));
    TextFormField nameTextFormField =
        tester.firstWidget(find.byKey(const Key('plan-name')));
    String? planId =
        (tester.firstWidget(find.byKey(const Key('plan-name-tile')))
                as PlanNameTile)
            .planId;
    expect(
        nameTextFormField.controller?.text,
        getPlanName(buildContext,
            providerContainer.read(planEditProviderFamily(planId))));
    expect(providerContainer.read(plansProvider).plans.length, 0);
    expect(find.byKey(const Key('target-status')), findsNothing);

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    Plan plan = providerContainer.read(plansProvider).plans.first;
    buildContext = tester.element(find.byKey(const Key('plans-grid')));
    expect(plan.name, null);
    expect(plan.scheduleKey.type, ScheduleType.chronological);
    expect(plan.scheduleKey.duration, ScheduleDuration.y1);
    expect(plan.scheduleKey.version, '1.0');
    expect(plan.language, Localizations.localeOf(buildContext).languageCode);
    expect(plan.withTargetDate, true);
    expect(plan.showEvents, true);
    expect(plan.showLocations, true);
    expect(plan.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));
    expect(providerContainer.read(plansProvider).plans.length, 1);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsOneWidget);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.menu_book));
    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .last);
    await tester.pumpAndSettle();

    buildContext = tester.firstElement(find.byKey(const Key('plan-name')));
    nameTextFormField =
        tester.firstWidget(find.byKey(const Key('plan-name'))) as TextFormField;
    planId = (tester.firstWidget(find.byKey(const Key('plan-name-tile')))
            as PlanNameTile)
        .planId;
    expect(
        nameTextFormField.controller?.text,
        getPlanName(buildContext,
            providerContainer.read(planEditProviderFamily(planId))));

    final firstBibleLanguageKey = providerContainer
        .read(bibleLanguagesProvider)
        .valueOrNull
        ?.bibleLanguages
        .keys
        .first;
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('plan-name')), 'Test 😃');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(Key('language-$firstBibleLanguageKey')), -500.0,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(Key('language-$firstBibleLanguageKey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.last;
    expect(plan.name, 'Test 😃');
    expect(plan.scheduleKey.type, ScheduleType.written);
    expect(plan.scheduleKey.duration, ScheduleDuration.m3);
    expect(plan.scheduleKey.version, '1.0');
    expect(plan.language, firstBibleLanguageKey);
    expect(plan.withTargetDate, false);
    expect(plan.showEvents, true);
    expect(plan.showLocations, true);
    expect(plan.bookmark, const Bookmark(dayIndex: 0, sectionIndex: -1));
    expect(providerContainer.read(plansProvider).plans.length, 2);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(2));
  });

  testWidgets('Cancel new plan', (tester) async {
    final providerContainer = await SettledTester(tester,
            sharedPreferences: await getWhatsNewSeenPreference())
        .providerContainer;
    final plans = providerContainer.read(plansProvider).plans;
    final firstBibleLanguageKey = providerContainer
        .read(bibleLanguagesProvider)
        .valueOrNull
        ?.bibleLanguages
        .keys
        .first;
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_note));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('plan-name')), 'Test 😃');
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(Key('language-$firstBibleLanguageKey')), -500.0,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(Key('language-$firstBibleLanguageKey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-events')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-locations')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans, plans);
  });

  testWidgets('Show schedule of last plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final lastPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans.last.id}'));
    await tester.scrollUntilVisible(lastPlanCardFinder, 500.0);
    await tester.pumpAndSettle();

    expect(find.byType(Card).last.evaluate(), lastPlanCardFinder.evaluate());

    await tester.tap(lastPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard), findsWidgets);
  });

  testWidgets('Show continue notice on new plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final secondPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans[1].id}'));
    await tester.scrollUntilVisible(secondPlanCardFinder, 500.0);
    await tester.pumpAndSettle();
    await tester.tap(secondPlanCardFinder);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue-notice')), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-2')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('continue-notice')), findsNothing);
  });

  testWidgets('Return to plans page', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(Card).first);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard), findsWidgets);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(
        find.byKey(
            Key('plan-${providerContainer.read(plansProvider).plans[1].id}')),
        findsOneWidget);
  });

  testWidgets('Schedule starts at bookmark', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final lastPlanCardFinder = find.byKey(
        Key('plan-${providerContainer.read(plansProvider).plans.last.id}'));
    await takeScreenshot(tester: tester, binding: binding, filename: 'plans');
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-75')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    expect(find.byType(Scrollable), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).at(1));
    await tester.pumpAndSettle();

    expect(find.byType(DayCard).first.evaluate(),
        find.byKey(const Key('day-0')).evaluate());
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.tap(find.byType(BackButton));
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
    final providerContainer = await getDefaultProviderContainer(tester);
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
    await tester.tap(find.byKey(const Key('reject-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        75);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-115')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        115);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Uncheck day', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
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
    await tester.tap(find.byKey(const Key('reject-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        75);
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-33')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        33);
    expect(find.byIcon(Icons.check_circle), findsNothing);
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
  });

  testWidgets('Show deviations', (tester) async {
    await getDefaultProviderContainer(tester);

    expect(find.byType(Badge), findsNothing);

    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-81')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byType(Divider), findsNothing);
    expect(find.byKey(const Key('current-day')), findsNothing);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-82')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-82')),
            matching: find.byType(IconButton))
        .at(1));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byKey(const Key('target-day')), findsOneWidget);

    await tester.scrollUntilVisible(find.byKey(const Key('current-day')), 50.0);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(
        (tester.firstWidget(find.byKey(const Key('current-day'))) as Divider)
            .color,
        Colors.green);

    await tester.scrollUntilVisible(find.byKey(const Key('day-81')), -50.0);
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-82')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-81')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '1');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.red);
    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.byKey(const Key('target-day')), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(
        (tester.firstWidget(find.byKey(const Key('current-day'))) as Divider)
            .color,
        Colors.red);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-82')),
      50.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-83')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '1');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.green);
    expect(find.byKey(const Key('target-day')), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(
        (tester.firstWidget(find.byKey(const Key('current-day'))) as Divider)
            .color,
        Colors.green);

    await tester.scrollUntilVisible(
      find.byKey(const Key('day-89')),
      500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '1');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.green);
    expect(find.byType(Divider), findsNothing);
    expect(find.byKey(const Key('current-day')), findsNothing);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-90')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '7');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.green);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '7');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.green);

    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('target-status')), findsOneWidget);

    await tester.tap(find.byKey(const Key('reset-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reject-reset-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsOneWidget);
    expect(
        ((tester.firstWidget(find.byType(Badge)) as Badge).label as Text).data,
        '7');
    expect((tester.firstWidget(find.byType(Badge)) as Badge).backgroundColor,
        Colors.green);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-target-date')), findsNothing);
    expect(find.byKey(const Key('target-status')), findsNothing);

    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reset-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-reset-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(Badge), findsNothing);
    expect(find.byType(Divider), findsOneWidget);
    expect(find.byKey(const Key('current-day')), findsOneWidget);
    expect(find.byKey(const Key('target-day')), findsNothing);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reset-target-date')), findsNothing);
    expect(find.byKey(const Key('target-status')), findsOneWidget);
  });

  testWidgets('Plans showing if finished', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified), findsOneWidget);

    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('day-365')), 500.0,
        maxScrolls: 300);
    await tester.pumpAndSettle();
    await Future<void>.delayed(Duration(seconds: 2));
    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-365')),
            matching: find.byType(IconButton))
        .last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
    await tester.pumpAndSettle();

    expect(providerContainer.read(plansProvider).plans.first.bookmark.dayIndex,
        366);
    expect(providerContainer.read(plansProvider).plans.first.lastDate,
        DateUtils.dateOnly(DateTime.now()));
    expect(find.byIcon(Icons.check_circle), findsWidgets);
    expect(find.byIcon(Icons.check_circle_outline), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified), findsExactly(2));
  });

  testWidgets('Bookmark button resets schedule view', (tester) async {
    await getDefaultProviderContainer(tester);
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
    await tester.tap(find.byKey(const Key('confirm-toggle-read')));
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

    expect(find.byKey(const Key('day-33')), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsAtLeastNWidgets(3));
    expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    await takeScreenshot(
        tester: tester, binding: binding, filename: 'schedule');
  });

  testWidgets('Change plan name', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await takeScreenshot(tester: tester, binding: binding, filename: 'edit');

    Plan plan = providerContainer.read(plansProvider).plans.first;
    BuildContext buildContext =
        tester.firstElement(find.byKey(const Key('plan-name')));
    expect(
        (tester.firstWidget(find.byKey(const Key('plan-name')))
                as TextFormField)
            .controller
            ?.text,
        getPlanName(buildContext, plan));

    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .last);
    await tester.pumpAndSettle();

    expect(
        (tester.firstWidget(find.byKey(const Key('plan-name')))
                as TextFormField)
            .controller
            ?.text,
        getPlanName(buildContext,
            providerContainer.read(planEditProviderFamily(plan.id))));

    await tester.enterText(find.byKey(const Key('plan-name')), 'Test 😃');
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.name, null);

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.name, 'Test 😃');
  });

  testWidgets('Change plan duration', (tester) async {
    const expectedBookmarks = [
      Bookmark(dayIndex: 75, sectionIndex: 0),
      Bookmark(dayIndex: 19, sectionIndex: -1),
      Bookmark(dayIndex: 38, sectionIndex: -1),
      Bookmark(dayIndex: 76, sectionIndex: -1),
      Bookmark(dayIndex: 152, sectionIndex: -1),
      Bookmark(dayIndex: 304, sectionIndex: -1),
    ];
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    for (final (index, _) in ScheduleDuration.values.indexed) {
      final oldDuration = providerContainer
          .read(plansProvider)
          .plans
          .first
          .scheduleKey
          .duration;

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();
      await tester.tap(find
          .descendant(
              of: find.byType(SegmentedButton<ScheduleDuration>),
              matching: find.byType(Text))
          .at(index));
      await tester.pumpAndSettle();

      var plan = providerContainer.read(plansProvider).plans.first;
      expect(plan.scheduleKey.duration, oldDuration);
      expect(plan.bookmark, expectedBookmarks[index]);

      await tester.tap(find.byIcon(Icons.done));
      await tester.pumpAndSettle();

      plan = providerContainer.read(plansProvider).plans.first;
      expect(plan.scheduleKey.duration, ScheduleDuration.values[index]);
      expect(plan.bookmark, expectedBookmarks[index + 1]);
    }
  });

  testWidgets('Change plan language', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final firstBibleLanguageKey = providerContainer
        .read(bibleLanguagesProvider)
        .valueOrNull
        ?.bibleLanguages
        .keys
        .first;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await takeScreenshot(tester: tester, binding: binding, filename: 'edit');
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(Key('language-$firstBibleLanguageKey')), -500.0,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(Key('language-$firstBibleLanguageKey')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.language, 'en');

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.language, firstBibleLanguageKey);
  });

  testWidgets('Change plan with target date setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('day-74')),
      -500.0,
    );
    await tester.pumpAndSettle();

    // Day indices are shown as there is no target date yet in the model.
    expect(find.byKey(const Key('date')), findsNothing);
    expect(find.byKey(const Key('day-index')), findsWidgets);
    expect(
        (tester.firstWidget(find.byKey(const Key('day-index'))) as Text).data,
        '75');

    await tester.tap(find
        .descendant(
            of: find.byKey(const Key('day-74')),
            matching: find.byType(IconButton))
        .first);
    await tester.pumpAndSettle();

    final dayOfMonth = DateTime.now().day;
    expect(find.byKey(const Key('date')), findsWidgets);
    expect(find.byKey(const Key('day-index')), findsNothing);
    expect((tester.firstWidget(find.byKey(const Key('date'))) as Text).data,
        dayOfMonth.toString());

    await tester.scrollUntilVisible(
      find.byKey(Key('day-${(74 - dayOfMonth).toString()}')),
      -500.0,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('month')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, true);

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, false);
    expect(find.byKey(const Key('month')), findsNothing);
    expect(find.byKey(const Key('date')), findsNothing);
    expect(find.byKey(const Key('day-index')), findsWidgets);
    expect(
        (tester.firstWidget(find
                .descendant(
                    of: find.byKey(Key('day-${(74 - dayOfMonth).toString()}')),
                    matching: find.byKey(const Key('day-index')))
                .last) as Text)
            .data,
        (75 - dayOfMonth).toString());

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.withTargetDate, true);
  });

  testWidgets('Change plan show events setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(EventWidget), findsAny);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('show-events')), 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-events')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showEvents, true);

    await tester.scrollUntilVisible(find.byIcon(Icons.done), -50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showEvents, false);
    expect(find.byType(EventWidget), findsNothing);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byKey(const Key('show-events')), 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-events')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byIcon(Icons.done), -50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showEvents, true);
    expect(find.byType(EventWidget), findsAny);
  });

  testWidgets('Change plan show locations setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(LocationsWidget), findsAny);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const Key('show-locations')), 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-locations')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showLocations, true);

    await tester.scrollUntilVisible(find.byIcon(Icons.done), -50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showLocations, false);
    expect(find.byType(LocationsWidget), findsNothing);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(const Key('show-locations')), 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-locations')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.byIcon(Icons.done), -50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.showLocations, true);
    expect(find.byType(LocationsWidget), findsAny);
  });

  testWidgets('Cancel edit plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    final firstBibleLanguageKey = providerContainer
        .read(bibleLanguagesProvider)
        .valueOrNull
        ?.bibleLanguages
        .keys
        .first;
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .first);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(Key('language-$firstBibleLanguageKey')), -500.0,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byKey(Key('language-$firstBibleLanguageKey')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('with-target-date')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-events')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('show-locations')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    final plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.scheduleKey.type, ScheduleType.chronological);
    expect(plan.bookmark, const Bookmark(dayIndex: 75, sectionIndex: 0));
    expect(plan.scheduleKey.duration, ScheduleDuration.y1);
    expect(plan.language, 'en');
    expect(plan.withTargetDate, true);
    expect(plan.showEvents, true);
    expect(plan.showLocations, true);
  });

  testWidgets('Delete plan', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.scrollUntilVisible(
      find.byKey(
          Key('plan-${providerContainer.read(plansProvider).plans.last.id}')),
      500.0,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(PlanCard).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await tester.tap(find
        .descendant(
            of: find.byType(SegmentedButton<ScheduleDuration>),
            matching: find.byType(Text))
        .first);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.byIcon(Icons.delete).first, 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reject-delete-plan')));
    await tester.pumpAndSettle();

    var plans = providerContainer.read(plansProvider).plans;
    expect(plans.last.id, 'e37bf9df-077a-49db-adcb-d56384906103');

    await tester.scrollUntilVisible(find.byIcon(Icons.delete).first, 50.0,
        scrollable: find.byType(Scrollable).last);
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirm-delete-plan')));
    await tester.pumpAndSettle();

    plans = providerContainer.read(plansProvider).plans;
    expect(plans.last.id, '2dab49f3-aecf-4aba-9e91-d75c297d4b7e');
    expect(plans.length, 3);
    expect(find.byKey(const Key('no-plan-yet')), findsNothing);
    expect(find.byType(PlanCard), findsNWidgets(3));
  });

  testWidgets('Settings', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('version')), findsOneWidget);
    expect(find.byKey(const Key('copyright')), findsOneWidget);

    await tester.tap(find.byIcon(Icons.light_mode));
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold));
    expect(Theme.of(context).brightness, Brightness.light);

    await tester.tap(find.byIcon(Icons.auto_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness,
        SchedulerBinding.instance.platformDispatcher.platformBrightness);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness, Brightness.dark);

    await tester.tap(find.byIcon(Icons.auto_mode));
    await tester.pumpAndSettle();

    expect(Theme.of(context).brightness,
        SchedulerBinding.instance.platformDispatcher.platformBrightness);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(
        find.byKey(
            Key('plan-${providerContainer.read(plansProvider).plans[1].id}')),
        findsOneWidget);
  });
}
