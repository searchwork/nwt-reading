import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/presentations/event_widget.dart';

import '../app_test.dart';

void testChangePlanEvents() {
  testWidgets('Change plan show events setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(EventWidget), findsAny);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
}
