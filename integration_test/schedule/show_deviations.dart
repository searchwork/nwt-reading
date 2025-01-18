import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../app_test.dart';

void testShowDeviations() {
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    expect(find.byKey(const Key('reset-target-date')), findsNothing);
    expect(find.byKey(const Key('target-status')), findsOneWidget);
  });
}
