import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

import '../../test/test_data.dart';
import '../settled_tester.dart';

void testCancelNew() {
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
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
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

    expect(providerContainer.read(plansProvider).plans, plans);
  });
}
