import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/base/presentation/plan.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/plans/presentations/plan_name_tile.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../../test/test_data.dart';
import '../settled_tester.dart';

void testAddPlans() {
  testWidgets('Add new plans', (tester) async {
    final providerContainer = await SettledTester(tester,
            sharedPreferences: await getWhatsNewSeenPreference())
        .providerContainer;

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    await tester.pumpAndSettle();
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
}
