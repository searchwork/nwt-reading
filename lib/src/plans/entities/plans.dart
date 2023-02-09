import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final plansNotifier = AsyncNotifierProvider<PlansNotifier, Plans>(
    PlansNotifier.new,
    name: "plans");

class PlansNotifier extends IncompleteNotifier<Plans> {
  bool existPlan(String planId) => state.when(
        data: (plans) =>
            plans.plans.indexWhere(
              (plan) => plan.id == planId,
            ) >=
            0,
        error: (error, stackTrace) => false,
        loading: () => false,
      );

  Future<void> newPlan() async {
    await update((plans) {
      final scheduleKey = ScheduleKey(
          type: ScheduleType.values[plans.plans.length % 3],
          duration: ScheduleDuration.y1,
          version: '1.0');
      const bookmark = Bookmark(dayIndex: 0, sectionIndex: -1);
      final plan = Plan(
          id: _uuid.v4(),
          name: toBeginningOfSentenceCase(scheduleKey.type.name)!,
          scheduleKey: scheduleKey,
          language: 'en',
          bookmark: bookmark,
          withEndDate: true,
          showEvents: true,
          showLocations: true);

      return Plans([...plans.plans, plan]);
    });
  }

  Future<void> addPlan(Plan plan) async {
    await update((plans) => Plans([...plans.plans, plan]));
  }

  Future<void> removePlan(String planId) async {
    await update((plans) =>
        Plans(plans.plans.where((plan) => plan.id != planId).toList()));
  }

  Future<void> updatePlan(Plan plan) async {
    await update((plans) =>
        Plans(plans.plans.map((p) => p.id == plan.id ? plan : p).toList()));
  }
}

@immutable
class Plans {
  const Plans._internal(this.plans);
  factory Plans(List<Plan> plans) => Plans._internal(List.unmodifiable(plans));

  final List<Plan> plans;
}
