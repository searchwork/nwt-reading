import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../settled_tester.dart';

void testNoPlans() {
  testWidgets('Initially, there are no plans', (tester) async {
    await SettledTester(tester).providerContainer;

    expect(find.byKey(const Key('no-plan-yet')), findsOneWidget);
    expect(find.byType(PlanCard), findsNothing);
  });
}
