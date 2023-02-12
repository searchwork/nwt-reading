import 'dart:io';
import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  try {
    await integrationDriver(
      onScreenshot: (String filePath, List<int> bytes) async {
        final File image = await File(filePath).create(recursive: true);
        image.writeAsBytesSync(bytes);

        return true;
      },
    );
  } catch (e) {
    // ignore: avoid_print
    print('Error occurred: $e');
  }
}
