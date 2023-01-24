import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_deserializer.dart';
import 'package:nwt_reading/src/plans/repositories/plans_serializer.dart';
import 'package:shared_preferences/shared_preferences.dart';

final plansRepositoryProvider = Provider<PlansRepository>(
    (ref) => PlansRepository(ref),
    name: 'plansRepository');

class PlansRepository {
  PlansRepository(this.ref) {
    _init();
  }

  final preferenceKey = 'plans';
  final Ref ref;

  void _init() async {
    _setPlansFromPreferences();

    ref.listen(plansProvider, ((previous, next) {
      final plans = next.value;
      if (plans != null) {
        final plansStringList =
            PlansSerializer().convertPlansToStringList(plans);
        _storePlansToPreferences(plansStringList);
      }
    }));
  }

  void _storePlansToPreferences(plansStringList) async {
    final preferences = await SharedPreferences.getInstance();
    preferences.setStringList(preferenceKey, plansStringList);
  }

  void _setPlansFromPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    final plansStringList = preferences.getStringList(preferenceKey) ?? [];
    final plans = PlansDeserializer().convertStringListToPlans(plansStringList);
    // final List<Plan> plans = [];
    ref.read(plansProvider.notifier).init(plans);
  }
}
