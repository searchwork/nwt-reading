import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_deserializer.dart';
import 'package:nwt_reading/src/plans/repositories/plans_serializer.dart';

const _preferenceKey = 'plans';

final plansRepository = Provider<void>((ref) {
  final preferences = ref.watch(sharedPreferencesRepository);
  final plansSerialized = preferences.getStringList(_preferenceKey) ?? [];
  final plans = PlansDeserializer().convertStringListToPlans(plansSerialized);
  ref.read(plansNotifier.notifier).init(plans);

  ref.listen(
      plansNotifier,
      (previousPlans, currentPlans) => currentPlans.whenData((plans) {
            final plansSerialized =
                PlansSerializer().convertPlansToStringList(plans);
            preferences.setStringList(_preferenceKey, plansSerialized);
          }));
}, name: 'plansRepository');
