import 'dart:convert';

import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';

class PlansDeserializer {
  Plans convertStringListToPlans(List<String> plansStringList) =>
      List<Plan>.from(plansStringList
          .map((planJson) => _convertMapToPlan(jsonDecode(planJson))));

  ScheduleKey convertMapToScheduleKey(Map<String, dynamic> scheduleKeyMap) {
    final type = ScheduleType.values[scheduleKeyMap['type']];
    final duration = ScheduleDuration.values[scheduleKeyMap['duration']];
    final version = scheduleKeyMap['version'] as String;

    return ScheduleKey(
      type: type,
      duration: duration,
      version: version,
    );
  }

  Plan _convertMapToPlan(Map<String, dynamic> planMap) {
    final id = planMap['id'] as String;
    final name = planMap['name'] as String;
    final schedule = convertMapToScheduleKey(planMap['scheduleKey']);
    final language = planMap['language'] as String;
    final bookmark = _convertMapToBookmark(planMap['bookmark']);
    final startDate = planMap['startDate'] as DateTime?;
    final endDate = planMap['endDate'] as DateTime?;
    final withEndDate = planMap['withEndDate'] as bool;
    final showEvents = planMap['showEvents'] as bool;
    final showLocations = planMap['showLocations'] as bool;

    return Plan(
        id: id,
        name: name,
        scheduleKey: schedule,
        language: language,
        bookmark: bookmark,
        startDate: startDate,
        endDate: endDate,
        withEndDate: withEndDate,
        showEvents: showEvents,
        showLocations: showLocations);
  }

  Bookmark _convertMapToBookmark(Map<String, dynamic> bookmarkMap) {
    final dayIndex = bookmarkMap['dayIndex'] as int;
    final sectionIndex = bookmarkMap['sectionIndex'] as int;

    return Bookmark(
      dayIndex: dayIndex,
      sectionIndex: sectionIndex,
    );
  }
}
