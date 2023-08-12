import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProviderLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint(
        'didAddProvider: ${provider.name ?? provider.runtimeType} -- value: ${value.toString().characters.take(70)}');
  }

  @override
  void providerDidFail(ProviderBase provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    debugPrint(
        'providerDidFail: ${provider.name ?? provider.runtimeType} -- error: ${error.toString()}');
  }

  @override
  void didDisposeProvider(
    ProviderBase provider,
    ProviderContainer container,
  ) {
    debugPrint('didDisposeProvider: ${provider.name ?? provider.runtimeType}');
  }

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint(
        'didUpdateProvider: ${provider.name ?? provider.runtimeType} -- newValue: ${newValue.toString().characters.take(70)}');
  }
}
