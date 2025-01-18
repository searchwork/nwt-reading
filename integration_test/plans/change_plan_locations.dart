import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/schedules/presentations/locations_widget.dart';

import '../app_test.dart';

void testChangePlanLocations() {
  testWidgets('Change plan show locations setting', (tester) async {
    final providerContainer = await getDefaultProviderContainer(tester);
    await tester.tap(find.byType(PlanCard).first);
    await tester.pumpAndSettle();

    expect(find.byType(LocationsWidget), findsAny);

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
}
