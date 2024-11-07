import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planEditProviderFamily =
    AutoDisposeNotifierProviderFamily<PlanEdit, Plan, String?>(PlanEdit.new,
        name: 'planEditProviderFamily');

class PlanEdit extends AutoDisposeFamilyNotifier<Plan, String?> {
  String? planId;
  String? _name;

  @override
  Plan build(arg) {
    if (arg == null && planId == null) {
      planId = ref.read(plansProvider.notifier).getNewPlanId();
    }
    return ref.watch(planProviderFamily(arg ?? planId!));
  }

  Schedule? getSchedule() =>
      ref.read(scheduleProviderFamily(state.scheduleKey)).valueOrNull;

  void changeName(String name) => _name = name;

  void updateDefaultName(ScheduleKey scheduleKey) {
    final plansNotifier = ref.read(plansProvider.notifier);
    final isDefaultName = _name == null ||
        _name == plansNotifier.getDefaultName(state.scheduleKey);

    if (isDefaultName) {
      _name = plansNotifier.getDefaultName(scheduleKey);
    }
  }

  void updateLanguage(String language) {
    if (language != state.language) {
      state = state.copyWith(language: language);
    }
  }

  void updateScheduleDuration(ScheduleDuration scheduleDuration) async {
    final oldScheduleDuration = state.scheduleKey.duration;

    if (scheduleDuration != oldScheduleDuration) {
      final newScheduleKey =
          state.scheduleKey.copyWith(duration: scheduleDuration);
      final newScheduleLength =
          (await ref.read(scheduleProviderFamily(newScheduleKey).future))
                  ?.length ??
              1;
      final oldScheduleLength = getSchedule()?.length ?? 1;
      final newDayIndex =
          (state.bookmark.dayIndex * newScheduleLength / oldScheduleLength)
              .round();
      updateDefaultName(newScheduleKey);

      state = state.copyWith(
        name: _name,
        scheduleKey: newScheduleKey,
        bookmark: Bookmark(dayIndex: newDayIndex, sectionIndex: -1),
        nullStartDate: true,
        nullTargetDate: true,
      );
    }
  }

  void updateScheduleType(ScheduleType scheduleType) {
    if (scheduleType != state.scheduleKey.type) {
      final newScheduleKey = state.scheduleKey.copyWith(type: scheduleType);
      updateDefaultName(newScheduleKey);

      state = state.copyWith(
        name: _name,
        scheduleKey: newScheduleKey,
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
    state = state.copyWith(name: _name);
    final notifier = ref.read(plansProvider.notifier);
    notifier.existPlan(state.id)
        ? notifier.updatePlan(state)
        : notifier.addPlan(state);
  }

  void delete() => ref.read(plansProvider.notifier).removePlan(state.id);
}
