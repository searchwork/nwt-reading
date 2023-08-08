import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/base/repositories/shared_preferences_provider.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/repositories/plans_deserializer.dart';
import 'package:nwt_reading/src/plans/repositories/plans_serializer.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:uuid/uuid.dart';

const _legacyExportPreferenceKey = 'legacyExport';
const _preferenceKey = 'plans';
const _uuid = Uuid();

final plansRepository = Provider<void>((ref) {
  final preferences = ref.watch(sharedPreferencesRepository);
  final plansSerialized = preferences.getStringList(_preferenceKey);
  final legacyExportSerialized =
      preferences.getString(_legacyExportPreferenceKey);

  Plans plans = Plans(const []);

  try {
    if (plansSerialized != null || legacyExportSerialized == null) {
      plans = PlansDeserializer().convertStringListToPlans(plansSerialized);
    } else {
      final Map<String, dynamic> legacyExport =
          jsonDecode(legacyExportSerialized);
      final currentSchedule = legacyExport['currentSchedule'] as String?;

      if (currentSchedule != null) {
        final schedules = legacyExport['schedules'] as Map<String, dynamic>?;
        final language = legacyExport['language'] as String?;
        final readingLanguage = legacyExport['readingLanguage'] as String?;
        final withTargetDate = legacyExport['withEndDate'] as bool? ?? true;
        final showEvents = legacyExport['showEvents'] as bool? ?? true;
        final showLocations = legacyExport['showLocations'] as bool? ?? true;

        final schedule =
            (schedules ?? {})[currentSchedule] as Map<String, dynamic>? ?? {};
        final scheduleKey = ScheduleKey(
            type: ScheduleType.values.byName(currentSchedule),
            duration: ScheduleDuration.values.byName(
                (schedule['duration'] ?? '1y').split('').reversed.join('')),
            version: '1.0');
        final bookmark = Bookmark(
            dayIndex: int.tryParse(schedule['readIndex'] ?? '0') ?? 0,
            sectionIndex: -1);
        final DateTime? targetDate =
            withTargetDate && schedule['endDate'] != null
                ? DateTime.tryParse(schedule['endDate'])
                : null;

        plans = Plans([
          Plan(
            id: _uuid.v4(),
            name: toBeginningOfSentenceCase(currentSchedule)!,
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
  ref.read(plansNotifier.notifier).init(plans);

  ref.listen(
      plansNotifier,
      (previousPlans, currentPlans) => currentPlans.whenData((plans) {
            final plansSerialized =
                PlansSerializer().convertPlansToStringList(plans);
            preferences.setStringList(_preferenceKey, plansSerialized);
          }));
}, name: 'plansRepository');
