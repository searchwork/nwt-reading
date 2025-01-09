import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes,
        [Map<String, Object?>? args]) async {
      // ignore: avoid_print
      print('Saving screen shot $screenshotName.');
      final File image = File(screenshotName);
      image.writeAsBytesSync(screenshotBytes);
      // Return false if the screenshot is invalid.
      return true;
    },
  );
}
