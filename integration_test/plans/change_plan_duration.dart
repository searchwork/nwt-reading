import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../app_test.dart';

void testChangePlanDuration() {
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
      await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
}
