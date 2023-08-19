import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planFamilyProvider =
    FutureProviderFamily<PlanFamily?, String>((ref, planId) async {
  final plan = ref.watch(plansProvider).getPlan(planId);

  if (plan != null) {
    ref.watch(scheduleFamilyProvider(plan.scheduleKey));

    return PlanFamily(ref, plan: plan);
  } else {
    return null;
  }
}, name: 'planFamilyProvider');

class PlanFamily {
  PlanFamily(this.ref, {required this.plan})
      : plansNotifier = ref.read(plansProvider.notifier),
        schedule =
            ref.read(scheduleFamilyProvider(plan.scheduleKey)).valueOrNull;

  final Ref ref;
  final Plan plan;
  final PlansNotifier plansNotifier;
  final Schedule? schedule;

  void delete() => plansNotifier.removePlan(plan.id);

  bool isRead({dayIndex, sectionIndex}) =>
      plan.bookmark.compareTo(
          Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex)) >=
      0;

  void setRead({required int dayIndex, required int sectionIndex}) {
    final sections = schedule?.days[dayIndex].sections.length;
    final newBookmark = sections != null && sectionIndex >= sections - 1
        ? Bookmark(dayIndex: dayIndex + 1, sectionIndex: -1)
        : Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex);

    plansNotifier.updatePlan(plan.copyWith(
      bookmark: newBookmark,
      startDate: _getStartDate(newBookmark),
      targetDate: plan.targetDate ?? _calcTargetDate(newBookmark),
    ));
  }

  void setUnread({required int dayIndex, required int sectionIndex}) =>
      setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);

  void resetTargetDate() {
    if (plan.withTargetDate) {
      plansNotifier.updatePlan(
          plan.copyWith(targetDate: _calcTargetDate(plan.bookmark)));
    }
  }

  double getProgress() =>
      schedule == null ? 0 : plan.bookmark.dayIndex / schedule!.length;

  int get deviationDays {
    if (plan.withTargetDate && targetDate != null) {
      final deviationDays = targetDate!.difference(_calcTargetDate()!).inDays;

      // If ahead, don't count the current day.
      return deviationDays <= 0 ? deviationDays : deviationDays - 1;
    } else {
      return 0;
    }
  }

  int get remainingDays => _getRemainingDays();

  DateTime? get startDate => _getStartDate();

  DateTime? get targetDate => plan.targetDate ?? _calcTargetDate();

  int? get todayTargetIndex =>
      plan.withTargetDate && targetDate != null && schedule != null
          ? schedule!.length -
              targetDate!.difference(DateUtils.dateOnly(DateTime.now())).inDays
          : null;

  DateTime? _getStartDate([Bookmark? bookmark]) => plan.withTargetDate
      ? plan.startDate ??
          DateUtils.dateOnly(DateTime.now())
              .add(Duration(days: -(bookmark ?? plan.bookmark).dayIndex))
      : null;

  DateTime? _calcTargetDate([Bookmark? bookmark]) => plan.withTargetDate
      ? DateUtils.dateOnly(DateTime.now())
          .add(Duration(days: _getRemainingDays(bookmark)))
      : null;

  int _getRemainingDays([Bookmark? bookmark]) => schedule == null
      ? 0
      : schedule!.length - (bookmark ?? plan.bookmark).dayIndex;
}

// @immutable
class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.name,
    required this.scheduleKey,
    required this.language,
    required this.bookmark,
    this.startDate,
    this.targetDate,
    required this.withTargetDate,
    required this.showEvents,
    required this.showLocations,
  });

  final String id;
  final String name;
  final ScheduleKey scheduleKey;
  final String language;
  final Bookmark bookmark;
  final DateTime? startDate;
  final DateTime? targetDate;
  final bool withTargetDate;
  final bool showEvents;
  final bool showLocations;

  Plan copyWith(
          {String? id,
          String? name,
          ScheduleKey? scheduleKey,
          String? language,
          Bookmark? bookmark,
          DateTime? startDate,
          DateTime? targetDate,
          bool? withTargetDate,
          bool? showEvents,
          bool? showLocations}) =>
      Plan(
        id: id ?? this.id,
        name: name ?? this.name,
        scheduleKey: scheduleKey ?? this.scheduleKey,
        language: language ?? this.language,
        bookmark: bookmark ?? this.bookmark,
        startDate: startDate ?? this.startDate,
        targetDate: targetDate ?? this.targetDate,
        withTargetDate: withTargetDate ?? this.withTargetDate,
        showEvents: showEvents ?? this.showEvents,
        showLocations: showLocations ?? this.showLocations,
      );

  @override
  List<Object?> get props => [
        name,
        scheduleKey,
        language,
        bookmark,
        startDate,
        targetDate,
        withTargetDate,
        showEvents,
        showLocations
      ];
}

@immutable
class Bookmark extends Equatable implements Comparable<Bookmark> {
  const Bookmark({
    required this.dayIndex,
    required this.sectionIndex,
  });

  final int dayIndex;
  final int sectionIndex;

  Bookmark copyWith({
    int? dayIndex,
    int? sectionIndex,
  }) =>
      Bookmark(
        dayIndex: dayIndex ?? this.dayIndex,
        sectionIndex: sectionIndex ?? this.sectionIndex,
      );

  @override
  List<Object> get props => [dayIndex, sectionIndex];

  @override
  int compareTo(Bookmark other) {
    if (dayIndex < other.dayIndex) return -1;
    if (dayIndex > other.dayIndex) return 1;
    return sectionIndex.compareTo(other.sectionIndex);
  }
}
