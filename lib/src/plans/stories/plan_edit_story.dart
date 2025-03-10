import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

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

      state = state.copyWith(
        name: _name,
        scheduleKey: newScheduleKey,
        bookmark: Bookmark(dayIndex: newDayIndex, sectionIndex: -1),
        nullStartDate: true,
        nullLastDate: true,
        nullTargetDate: true,
      );
    }
  }

  void updateScheduleType(ScheduleType scheduleType) {
    if (scheduleType != state.scheduleKey.type) {
      final newScheduleKey = state.scheduleKey.copyWith(type: scheduleType);

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

  DateTime? calcTargetDate() {
    final notifier = ref.read(planProviderFamily(state.id).notifier);
    return notifier.calcTargetDate();
  }

  void resetTargetDate() {
    final notifier = ref.read(planProviderFamily(state.id).notifier);
    notifier.resetTargetDate();
  }

  /// **New Method: Set Target Date Manually**
  void setTargetDate(DateTime newDate) {
    state = state.copyWith(endDate: newDate);
  }

  void updateShowEvents(bool showEvents) {
    if (showEvents != state.showEvents) {
      state = state.copyWith(showEvents: showEvents);
    }
  }

  void updateShowLocations(bool showLocations) {
    if (showLocations != state.showLocations) {
      state = state.copyWith(showLocations: showLocations);
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
