import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final planFamilyEdit =
    NotifierProvider.family<PlanEdit, Plan, String?>(PlanEdit.new);

class PlanEdit extends FamilyNotifier<Plan, String?> {
  @override
  Plan build(arg) => _getPlan(arg ?? _uuid.v4());

  Plan get plan => state;

  Plan _getNew(String planId) => Plan(
      id: planId,
      name: toBeginningOfSentenceCase(ScheduleType.chronological.name)!,
      scheduleKey: const ScheduleKey(
          type: ScheduleType.chronological,
          duration: ScheduleDuration.y1,
          version: '1.0'),
      language: 'en',
      bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      withEndDate: true,
      showEvents: true,
      showLocations: true);

  Plan _getPlan(planId) =>
      ref.read(plansNotifier).valueOrNull?.plans.firstWhere(
          (plan) => plan.id == planId,
          orElse: () => _getNew(planId)) ??
      _getNew(planId);

  void setRead({required int dayIndex, required int sectionIndex}) =>
      state = state.copyWith(
          bookmark: Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex));

  void saveRead({required int dayIndex, required int sectionIndex}) {
    setRead(dayIndex: dayIndex, sectionIndex: sectionIndex);
    save();
  }

  void setUnread({required int dayIndex, required int sectionIndex}) =>
      setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);

  void saveUnread({required int dayIndex, required int sectionIndex}) {
    setUnread(dayIndex: dayIndex, sectionIndex: sectionIndex);
    save();
  }

  void updateScheduleType(ScheduleType scheduleType) {
    if (scheduleType != state.scheduleKey.type) {
      state = state.copyWith(
        name: toBeginningOfSentenceCase(scheduleType.name),
        scheduleKey: state.scheduleKey.copyWith(type: scheduleType),
        bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      );
    }
  }

  void reset() => state = build(state.id);

  void save() {
    final notifier = ref.read(plansNotifier.notifier);
    notifier.existPlan(state.id)
        ? notifier.updatePlan(state)
        : notifier.addPlan(state);
  }

  // void delete() => {};
  void delete() => ref.read(plansNotifier.notifier).removePlan(state.id);
}
