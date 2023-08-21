import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

const _uuid = Uuid();

final plansProvider = NotifierProvider<PlansNotifier, Plans>(PlansNotifier.new,
    name: 'plansProvider');

class PlansNotifier extends Notifier<Plans> {
  @override
  build() => Plans(const []);

  bool existPlan(String planId) => state.existPlan(planId);

  Plan? getPlan(String planId) => state.getPlan(planId);

  void newPlan() {
    final scheduleKey = ScheduleKey(
        type: ScheduleType.values[state.plans.length % 3],
        duration: ScheduleDuration.y1,
        version: '1.0');
    const bookmark = Bookmark(dayIndex: 0, sectionIndex: -1);
    final plan = Plan(
        id: _uuid.v4(),
        name: toBeginningOfSentenceCase(scheduleKey.type.name)!,
        scheduleKey: scheduleKey,
        language: 'en',
        bookmark: bookmark,
        withTargetDate: true,
        showEvents: true,
        showLocations: true);

    state = Plans([...state.plans, plan]);
  }

  void addPlan(Plan plan) {
    state = Plans([...state.plans, plan]);
  }

  void removePlan(String planId) {
    state = Plans(state.plans.where((plan) => plan.id != planId).toList());
  }

  void updatePlan(Plan plan) {
    state = Plans(state.plans.map((p) => p.id == plan.id ? plan : p).toList());
  }
}

@immutable
class Plans {
  const Plans._internal(this.plans);
  factory Plans(List<Plan> plans) => Plans._internal(List.unmodifiable(plans));

  final List<Plan> plans;

  bool existPlan(String planId) => plans.any((plan) => plan.id == planId);

  Plan? getPlan(String planId) =>
      plans.firstWhereOrNull((plan) => plan.id == planId);
}
