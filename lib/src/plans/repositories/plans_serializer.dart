import 'dart:convert';

import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

class PlansSerializer {
  List<String> convertPlansToStringList(Plans plans) => List<String>.from(
      plans.plans.map((plan) => jsonEncode(_convertPlanToMap(plan))));

  Map<String, dynamic> _convertPlanToMap(Plan plan) => {
        'id': plan.id,
        'name': plan.name,
        'scheduleKey': _convertScheduleKeyToMap(plan.scheduleKey),
        'language': plan.language,
        'bookmark': _convertBookmarkToMap(plan.bookmark),
        if (plan.startDate != null)
          'startDate': plan.startDate!.toIso8601String(),
        if (plan.lastDate != null) 'lastDate': plan.lastDate!.toIso8601String(),
        if (plan.targetDate != null)
          'targetDate': plan.targetDate!.toIso8601String(),
        'withTargetDate': plan.withTargetDate,
        'showEvents': plan.showEvents,
        'showLocations': plan.showLocations,
      };

  Map<String, dynamic> _convertBookmarkToMap(Bookmark bookmark) => {
        'dayIndex': bookmark.dayIndex,
        'sectionIndex': bookmark.sectionIndex,
      };

  Map<String, dynamic> _convertScheduleKeyToMap(ScheduleKey scheduleKey) => {
        'type': scheduleKey.type.index,
        'duration': scheduleKey.duration.index,
        'version': scheduleKey.version,
      };
}
