import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planEditProviderFamily =
    AutoDisposeNotifierProviderFamily<PlanEdit, Plan, String?>(PlanEdit.new,
        name: 'planEditProviderFamily');

class PlanEdit extends AutoDisposeFamilyNotifier<Plan, String?> {
  @override
  Plan build(arg) => ref.watch(planProviderFamily(
      arg ?? ref.read(plansProvider.notifier).getNewPlanId()));


  Schedule? getSchedule() =>
      ref.read(scheduleProviderFamily(state.scheduleKey)).valueOrNull;

  void updateLanguage(String language) {
    if (language != state.language) {
      state = state.copyWith(language: language);
    }
  }

  void updateScheduleDuration(ScheduleDuration scheduleDuration) async {
    final oldScheduleDuration = state.scheduleKey.duration;

    if (scheduleDuration != oldScheduleDuration) {
      final newScheduleKey = state.scheduleKey.copyWith(duration: scheduleDuration);
      final newScheduleLength = (await ref.read(scheduleProviderFamily(newScheduleKey).future))?.length ?? 1;
      final oldScheduleLength = getSchedule()?.length ?? 1;
      final newDayIndex = (state.bookmark.dayIndex * newScheduleLength / oldScheduleLength).round();

      state = state.copyWith(
        scheduleKey: newScheduleKey,
        bookmark: Bookmark(dayIndex: newDayIndex, sectionIndex: -1),
        nullStartDate: true,
        nullTargetDate: true,
      );
    }
  }

  void updateScheduleType(ScheduleType scheduleType) {
    final isDefaultName = state.name == toBeginningOfSentenceCase(state.scheduleKey.type.name);

    if (scheduleType != state.scheduleKey.type) {
      state = state.copyWith(
        name: isDefaultName ? toBeginningOfSentenceCase(scheduleType.name) : state.name,
        scheduleKey: state.scheduleKey.copyWith(type: scheduleType),
        bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      );
    }
  }

  void updateWithTargetDate(bool withTargetDate) {
    if (withTargetDate != state.withTargetDate) {
      state = state.copyWith(withTargetDate: withTargetDate);
    }
  }

  void reset() => state = build(state.id);

  void save() {
    final notifier = ref.read(plansProvider.notifier);
    notifier.existPlan(state.id)
        ? notifier.updatePlan(state)
        : notifier.addPlan(state);
  }

  void delete() => ref.read(plansProvider.notifier).removePlan(state.id);
}
