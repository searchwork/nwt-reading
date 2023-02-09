import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/main.dart' as app;
import 'package:shared_preferences/shared_preferences.dart';

class SettledTester {
  SettledTester(this.tester, {this.sharedPreferences = const {}}) {
    SharedPreferences.setMockInitialValues(sharedPreferences);
  }

  final WidgetTester tester;
  final Map<String, Object> sharedPreferences;

  Future<ProviderContainer> get providerContainer async {
    UncontrolledProviderScope uncontrolledProviderScope = await app.main();
    await tester.pumpWidget(uncontrolledProviderScope);
    await tester.pumpAndSettle();

    return uncontrolledProviderScope.container;
  }
}
