import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../app_test.dart';

void testCancelEdit() {
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
}
