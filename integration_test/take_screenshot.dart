import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// ignore: inference_failure_on_function_return_type
takeScreenshot(
    {required WidgetTester tester,
    required IntegrationTestWidgetsFlutterBinding binding,
    required String filename}) async {
  if (kIsWeb) {
    await binding.takeScreenshot('docs/screenshots/$filename.png');
  }
}
