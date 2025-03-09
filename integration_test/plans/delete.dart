import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../app_test.dart';

void testDelete() {
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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

    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    await tester.scrollUntilVisible(find.byIcon(Icons.delete).first, 200.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
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
}
