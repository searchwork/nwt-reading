import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../app_test.dart';

void testChangePlanLanguage() {
  testWidgets('Change plan language', (tester) async {
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
    await tester.tap(find.byKey(const Key('language')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.byKey(Key('language-$firstBibleLanguageKey')), -500.0,
        scrollable: find.byType(Scrollable).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('language-$firstBibleLanguageKey')));
    await tester.pumpAndSettle();

    var plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.language, 'en');

    await tester.tap(find.byIcon(Icons.done));
    await tester.pumpAndSettle();

    plan = providerContainer.read(plansProvider).plans.first;
    expect(plan.language, firstBibleLanguageKey);
  });
}
