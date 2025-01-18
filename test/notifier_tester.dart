import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/logs/repositories/provider_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Listener<T> extends mocktail.Mock {
  void call(T? previous, T next);
}

class NotifierTester<T> {
  NotifierTester(this.provider, {List<Override> overrides = const []}) {
    container = ProviderContainer(
      overrides: overrides,
      observers: [ProviderLogger()],
    );
    container.listen(
      provider,
      listener.call,
      fireImmediately: true,
    );
  }

  final NotifierProvider<Notifier<dynamic>, T> provider;
  final listener = Listener<T>();
  ProviderContainer container = ProviderContainer();
}

class AsyncNotifierTester<T> {
  AsyncNotifierTester(this.provider, {List<Override> overrides = const []}) {
    container = ProviderContainer(
      overrides: overrides,
      observers: [ProviderLogger()],
    );
    container.listen(
      provider,
      listener.call,
      fireImmediately: true,
    );
  }

  final AsyncNotifierProvider<AsyncNotifier<dynamic>, T> provider;
  final listener = Listener<AsyncValue<T>>();
  ProviderContainer container = ProviderContainer();
}

Future<NotifierTester<dynamic>> getNotifierTester(
    NotifierProvider<Notifier<dynamic>, dynamic> provider,
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester = NotifierTester<dynamic>(provider, overrides: [
    sharedPreferencesRepositoryProvider
        .overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}

Future<AsyncNotifierTester<dynamic>> getAsyncNotifierTester(
    AsyncNotifierProvider<AsyncNotifier<dynamic>, dynamic> provider,
    [Map<String, Object> preferences = const {}]) async {
  SharedPreferences.setMockInitialValues(preferences);
  final sharedPreferences = await SharedPreferences.getInstance();

  final tester = AsyncNotifierTester<dynamic>(provider, overrides: [
    sharedPreferencesRepositoryProvider
        .overrideWith((ref) => sharedPreferences),
  ]);
  addTearDown(tester.container.dispose);

  return tester;
}
