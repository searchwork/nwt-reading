import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class _AbstractSharedPreferencesRepository<T, S> {
  _AbstractSharedPreferencesRepository(
      {required this.ref,
      required this.stateProvider,
      required this.preferenceKey}) {
    _init();
  }

  final Ref ref;
  final AsyncNotifierProvider<IncompleteNotifier<T>, T> stateProvider;
  final String preferenceKey;
  SharedPreferences? _preferences;

  void _init() async {
    _preferences = await SharedPreferences.getInstance();
    _setStateFromPreferences();

    ref.listen(stateProvider, ((previous, next) {
      final state = next.value;
      if (state != null) {
        _storePreference(serialize(state));
      }
    }));
  }

  Future<void> _storePreference(S serialized);

  S? _readPreference();

  S serialize(T state);

  T? deserialize(S? serialized);

  Future<void> _setStateFromPreferences() async {
    final serialized = _readPreference();
    final state = deserialize(serialized);
    if (state != null) {
      ref.read(stateProvider.notifier).init(state);
    }
  }
}

abstract class AbstractIntSharedPreferencesRepository<T>
    extends _AbstractSharedPreferencesRepository<T, int> {
  AbstractIntSharedPreferencesRepository(
      {required super.ref,
      required super.stateProvider,
      required super.preferenceKey});

  @override
  Future<void> _storePreference(int serialized) async {
    await _preferences?.setInt(preferenceKey, serialized);
  }

  @override
  int? _readPreference() => _preferences?.getInt(preferenceKey);
}

abstract class AbstractStringListSharedPreferencesRepository<T>
    extends _AbstractSharedPreferencesRepository<T, List<String>> {
  AbstractStringListSharedPreferencesRepository(
      {required super.ref,
      required super.stateProvider,
      required super.preferenceKey});

  @override
  Future<void> _storePreference(List<String> serialized) async {
    await _preferences?.setStringList(preferenceKey, serialized);
  }

  @override
  List<String>? _readPreference() => _preferences?.getStringList(preferenceKey);
}
