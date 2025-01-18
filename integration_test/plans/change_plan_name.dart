import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/base/presentation/plan.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../app_test.dart';

void testChangePlanName() {
  testWidgets('Change plan name', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

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
}
