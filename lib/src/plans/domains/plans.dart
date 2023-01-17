import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/base/domains/incomplete_notifier.dart';
import 'package:nwt_reading/src/plans/domains/plan.dart';
import 'package:nwt_reading/src/schedule/domains/schedules.dart';
import 'package:uuid/uuid.dart';

typedef Plans = List<Plan>;

final plansProvider = AsyncNotifierProvider<PlansNotifier, Plans>(
    PlansNotifier.new,
    name: "plans");

class PlansNotifier extends IncompleteNotifier<Plans> {
  Future<void> addPlan() async {
    await update((plans) {
      final scheduleKey = ScheduleKey(
          type: ScheduleType.values[plans.length % 3],
          duration: ScheduleDuration.y1,
          version: '1.0');
      final bookmark = Bookmark(dayIndex: 0, sectionIndex: -1);
      final plan = Plan(
          id: const Uuid().v4(),
          name: toBeginningOfSentenceCase(scheduleKey.type.name)!,
          scheduleKey: scheduleKey,
          language: 'en',
          bookmark: bookmark,
          withEndDate: true,
          showEvents: true,
          showLocations: true);

      return [...plans, plan];
    });
  }

  Future<void> removePlan(String planId) async {
    await update((plans) => plans.where((plan) => plan.id != planId).toList());
  }

  Future<void> updatePlan({required String planId, required Plan plan}) async {
    await update(
        (plans) => plans.map((p) => p.id == planId ? plan : p).toList());
  }
}
