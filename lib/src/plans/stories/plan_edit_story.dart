import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

final planEditFamilyProvider =
    AutoDisposeNotifierProviderFamily<PlanEdit, Plan, String?>(PlanEdit.new,
        name: 'planEditFamilyProvider');

class PlanEdit extends AutoDisposeFamilyNotifier<Plan, String?> {
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
      withTargetDate: true,
      showEvents: true,
      showLocations: true);

  Plan _getPlan(planId) => ref
      .read(plansProvider)
      .plans
      .firstWhere((plan) => plan.id == planId, orElse: () => _getNew(planId));

  void updateLanguage(String language) {
    if (language != state.language) {
      state = state.copyWith(language: language);
    }
  }

  void updateScheduleDuration(ScheduleDuration scheduleDuration) {
    if (scheduleDuration != state.scheduleKey.duration) {
      state = state.copyWith(
        scheduleKey: state.scheduleKey.copyWith(duration: scheduleDuration),
        bookmark: const Bookmark(dayIndex: 0, sectionIndex: -1),
      );
    }
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
