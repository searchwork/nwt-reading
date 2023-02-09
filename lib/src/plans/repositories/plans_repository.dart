import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repositories.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_deserializer.dart';
import 'package:nwt_reading/src/plans/repositories/plans_serializer.dart';

final plansRepository = Provider<PlansRepository>((ref) => PlansRepository(ref),
    name: 'plansRepository');

class PlansRepository
    extends AbstractStringListSharedPreferencesRepository<Plans> {
  PlansRepository(ref)
      : super(ref: ref, stateProvider: plansNotifier, preferenceKey: 'plans');

  @override
  List<String> serialize(Plans state) =>
      PlansSerializer().convertPlansToStringList(state);

  @override
  Plans deserialize(List<String>? serialized) =>
      PlansDeserializer().convertStringListToPlans(serialized);
}
