import 'dart:convert';

import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

class PlansDeserializer {
  Plans convertStringListToPlans(List<String>? plansStringList) =>
      Plans((plansStringList ?? [])
          .map((planJson) =>
              _convertMapToPlan(jsonDecode(planJson) as Map<String, dynamic>))
          .toList());

  ScheduleKey convertMapToScheduleKey(Map<String, dynamic> scheduleKeyMap) {
    final type = ScheduleType.values[scheduleKeyMap['type'] as int];
    final duration = ScheduleDuration.values[scheduleKeyMap['duration'] as int];
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
    final schedule =
        convertMapToScheduleKey(planMap['scheduleKey'] as Map<String, dynamic>);
    final language = planMap['language'] as String;
    final bookmark =
        _convertMapToBookmark(planMap['bookmark'] as Map<String, dynamic>);
    final startDate = planMap['startDate'] == null
        ? null
        : DateTime.parse(planMap['startDate'] as String);
    final lastDate = planMap['lastDate'] == null
        ? null
        : DateTime.parse(planMap['lastDate'] as String);
    final targetDate = planMap['targetDate'] == null
        ? null
        : DateTime.parse(planMap['targetDate'] as String);
    final withTargetDate = planMap['withTargetDate'] as bool;
    final showEvents = planMap['showEvents'] as bool;
    final showLocations = planMap['showLocations'] as bool;

    return Plan(
        id: id,
        name: name,
        scheduleKey: schedule,
        language: language,
        bookmark: bookmark,
        startDate: startDate,
        lastDate: lastDate,
        targetDate: targetDate,
        withTargetDate: withTargetDate,
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
