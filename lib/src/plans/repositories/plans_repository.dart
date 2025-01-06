import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_repository.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_deserializer.dart';
import 'package:nwt_reading/src/plans/repositories/plans_serializer.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _legacyExportPreferenceKey = 'legacyExport';
const _preferenceKey = 'plans';
const _uuid = Uuid();

final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesRepositoryProvider);

  ref.listen(plansProvider, (previousPlans, currentPlans) {
    final plansSerialized =
        PlansSerializer().convertPlansToStringList(currentPlans);
    sharedPreferences.setStringList(_preferenceKey, plansSerialized);
  });

  return PlansRepository(ref, preferences: sharedPreferences);
}, name: 'plansRepositoryProvider');

class PlansRepository {
  PlansRepository(this.ref, {required this.preferences});

  final SharedPreferences preferences;
  final Ref ref;

  void load() {
    final plansSerialized = preferences.getStringList(_preferenceKey);
    final legacyExportSerialized =
        preferences.getString(_legacyExportPreferenceKey);
    final plansNotifier = ref.read(plansProvider.notifier);

    Plans plans = Plans(const []);

    try {
      if (plansSerialized != null || legacyExportSerialized == null) {
        plans = PlansDeserializer().convertStringListToPlans(plansSerialized);
      } else {
        final legacyExport =
            jsonDecode(legacyExportSerialized) as Map<String, dynamic>;
        var currentSchedule = legacyExport['currentSchedule'] as String?;
        if (currentSchedule == 'sequential') {
          currentSchedule = 'canonical';
        }

        if (currentSchedule != null) {
          final schedules = legacyExport['schedules'] as Map<String, dynamic>?;
          final language = legacyExport['language'] as String?;
          final readingLanguage = legacyExport['readingLanguage'] as String?;
          final withTargetDate = legacyExport['withEndDate'] as bool? ?? true;
          final showEvents = legacyExport['showEvents'] as bool? ?? true;
          final showLocations = legacyExport['showLocations'] as bool? ?? false;

          final schedule =
              (schedules ?? {})[currentSchedule] as Map<String, dynamic>? ?? {};
          final scheduleKey = ScheduleKey(
              type: ScheduleType.values.byName(currentSchedule),
              duration: ScheduleDuration.values.byName(
                  (schedule['duration'] as String? ?? '1y')
                      .split('')
                      .reversed
                      .join('')),
              version: '1.0');

          Bookmark bookmark;
          try {
            bookmark = Bookmark(
                dayIndex:
                    int.tryParse(schedule['readIndex'] as String? ?? '0') ?? 0,
                sectionIndex: -1);
          } catch (e) {
            debugPrint(
                'Import readIndex from legacy failed with error $e. Trying to import as int');
            bookmark = Bookmark(
                dayIndex: schedule['readIndex'] as int? ?? 0, sectionIndex: -1);
          }

          final DateTime? targetDate =
              withTargetDate && schedule['endDate'] != null
                  ? DateTime.tryParse(schedule['endDate'] as String)
                  : null;

          plans = Plans([
            Plan(
              id: _uuid.v4(),
              scheduleKey: scheduleKey,
              language: readingLanguage ?? language ?? 'en',
              bookmark: bookmark,
              targetDate: targetDate,
              withTargetDate: withTargetDate,
              showEvents: showEvents,
              showLocations: showLocations,
            )
          ]);
        }
      }
    } catch (e) {
      debugPrint('Import from legacy failed with error $e');
    }
    for (Plan plan in plans.plans) {
      plansNotifier.addPlan(plan);
    }
  }
}
