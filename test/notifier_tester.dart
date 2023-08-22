import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';
import 'package:nwt_reading/src/logs/repositories/provider_logger.dart';

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
      listener,
      fireImmediately: true,
    );
  }

  final NotifierProvider<Notifier<dynamic>, T> provider;
  final listener = Listener<T>();
  ProviderContainer container = ProviderContainer();
}

class IncompleteNotifierTester<T> {
  IncompleteNotifierTester(this.provider,
      {List<Override> overrides = const []}) {
    container = ProviderContainer(
      overrides: overrides,
      observers: [ProviderLogger()],
    );
    container.listen(
      provider,
      listener,
      fireImmediately: true,
    );
  }

  final AsyncNotifierProvider<IncompleteNotifier<dynamic>, T> provider;
  final listener = Listener<AsyncValue<T>>();
  ProviderContainer container = ProviderContainer();
}
