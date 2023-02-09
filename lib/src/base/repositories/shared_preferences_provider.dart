import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// See https://docs-v2.riverpod.dev/docs/concepts/scopes#initialization-of-synchronous-provider-for-async-apis
final sharedPreferencesRepository =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());
