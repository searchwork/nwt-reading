import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

void main() {
  test('Stays on isLoading before init', () async {
    final incompleteNotifierProvider =
        AsyncNotifierProvider<IncompleteNotifier<int>, int>(
            IncompleteNotifier.new);
    final container = ProviderContainer();
    final result = await Future.any([
      Future.value(container.read(incompleteNotifierProvider.future)),
      Future.delayed(const Duration(seconds: 1))
    ]);

    expect(result, null);

    final isLoading = container.read(incompleteNotifierProvider).isLoading;

    expect(isLoading, true);
  });

  test('Resolves to init value', () async {
    const testValue = 'test';
    final incompleteNotifierProvider =
        AsyncNotifierProvider<IncompleteNotifier<String>, String>(
            IncompleteNotifier.new);
    final container = ProviderContainer();
    container.read(incompleteNotifierProvider.notifier).init(testValue);
    final state = await container.read(incompleteNotifierProvider.future);

    expect(state, testValue);
  });
}
