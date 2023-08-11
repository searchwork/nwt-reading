import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planFamilyProvider =
    FutureProviderFamily<PlanFamily?, String>((ref, planId) async {
  ref.watch(plansProvider);

  final plan = ref.read(plansProvider.notifier).getPlan(planId);
  if (plan != null) {
    ref.watch(scheduleFamilyProvider(plan.scheduleKey).future);

    return PlanFamily(ref, plan: plan);
  } else {
    return null;
  }
}, name: "planFamily");

class PlanFamily {
  PlanFamily(this.ref, {required this.plan})
      : plansNotifier = ref.read(plansProvider.notifier),
        schedule =
            ref.read(scheduleFamilyProvider(plan.scheduleKey)).valueOrNull;

  final Ref ref;
  final Plan plan;
  final PlansNotifier plansNotifier;
  final Schedule? schedule;

  DateTime? _calcTargetDate(Bookmark bookmark) => plan.withTargetDate
      ? DateUtils.dateOnly(DateTime.now())
          .add(Duration(days: _getRemainingDays(bookmark)))
      : null;

  void delete() => plansNotifier.removePlan(plan.id);

  int get deviationDays => plan.targetDate == null
      ? 0
      : plan.targetDate!.difference(_calcTargetDate(plan.bookmark)!).inDays;

  double getProgress() =>
      schedule == null ? 0 : plan.bookmark.dayIndex / schedule!.length;

  int _getRemainingDays(Bookmark bookmark) =>
      schedule == null ? 0 : schedule!.length - bookmark.dayIndex;

  int getRemainingDays() => _getRemainingDays(plan.bookmark);

  void resetTargetDate() {
    if (plan.withTargetDate) {
      plansNotifier.updatePlan(
          plan.copyWith(targetDate: _calcTargetDate(plan.bookmark)));
    }
  }

  void setRead({required int dayIndex, required int sectionIndex}) {
    final sections = schedule?.days[dayIndex].sections.length;
    final newBookmark = sections != null && sectionIndex >= sections - 1
        ? Bookmark(dayIndex: dayIndex + 1, sectionIndex: -1)
        : Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex);
    final startDate = plan.startDate ?? DateUtils.dateOnly(DateTime.now());

    plansNotifier.updatePlan(plan.copyWith(
      bookmark: newBookmark,
      startDate: startDate,
      targetDate: plan.targetDate ?? _calcTargetDate(newBookmark),
    ));
  }

  void setUnread({required int dayIndex, required int sectionIndex}) =>
      setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);
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

  bool isRead({dayIndex, sectionIndex}) =>
      bookmark.compareTo(
          Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex)) >=
      0;

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
