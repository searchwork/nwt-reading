import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart' as mocktail;
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

class Listener<T> extends mocktail.Mock {
  void call(T? previous, T next);
}

class IncompleteNotifierTester<T> {
  IncompleteNotifierTester(this.provider);

  final AsyncNotifierProvider<IncompleteNotifier, T> provider;
  final listener = Listener<AsyncValue<T>>();
  ProviderContainer container = ProviderContainer();

  void reset() {
    mocktail.reset(listener);
    container.dispose();
    container = ProviderContainer();
    container.listen(
      provider,
      listener,
      fireImmediately: true,
    );
  }
}
