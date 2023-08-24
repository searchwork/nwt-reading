import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planProviderFamily =
    AutoDisposeNotifierProviderFamily<PlanNotifier, Plan, String>(
        PlanNotifier.new,
        dependencies: [plansProvider],
        name: 'planProviderFamily');

class PlanNotifier extends AutoDisposeFamilyNotifier<Plan, String> {
  PlansNotifier? plansNotifier;
  Schedule? schedule;

  @override
  Plan build(arg) {
    final planId = arg;

    plansNotifier = ref.read(plansProvider.notifier);
    if (plansNotifier!.existPlan(planId)) {
      ref.watch(plansProvider);
    }

    return plansNotifier!.getPlan(planId) ?? plansNotifier!.getNewPlan(planId);
  }

  Plan? getPlan() {
    return state;
  }

  Schedule? getSchedule() =>
      ref.read(scheduleProviderFamily(state.scheduleKey)).valueOrNull;

  void delete() {
    plansNotifier?.removePlan(state.id);
  }

  bool isRead({required int dayIndex, required int sectionIndex}) =>
      state.bookmark.compareTo(
          Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex)) >=
      0;

  void setRead({required int dayIndex, required int sectionIndex}) {
    final sections = getSchedule()?.days[dayIndex].sections.length;
    final newBookmark = sections != null && sectionIndex >= sections - 1
        ? Bookmark(dayIndex: dayIndex + 1, sectionIndex: -1)
        : Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex);

    plansNotifier?.updatePlan(state.copyWith(
      bookmark: newBookmark,
      startDate: _getStartDate(newBookmark),
      targetDate: state.targetDate ?? _calcTargetDate(newBookmark),
    ));
  }

  void setUnread({required int dayIndex, required int sectionIndex}) =>
      setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);

  void resetTargetDate() {
    if (state.withTargetDate) {
      plansNotifier?.updatePlan(
          state.copyWith(targetDate: _calcTargetDate(state.bookmark)));
    }
  }

  double getProgress() => getSchedule() == null
      ? 0
      : state.bookmark.dayIndex / getSchedule()!.length;

  int getDeviationDays() {
    if (state.withTargetDate && getTargetDate() != null) {
      final deviationDays =
          getTargetDate()!.difference(_calcTargetDate()!).inDays;

      // If ahead, don't count the current day.
      return deviationDays <= 0 ? deviationDays : deviationDays - 1;
    } else {
      return 0;
    }
  }

  int getRemainingDays() => _getRemainingDays();

  DateTime? getStartDate() => _getStartDate();

  DateTime? getTargetDate() => state.targetDate ?? _calcTargetDate();

  int? todayTargetIndex() => state.withTargetDate &&
          getTargetDate() != null &&
          getSchedule() != null
      ? getSchedule()!.length -
          getTargetDate()!.difference(DateUtils.dateOnly(DateTime.now())).inDays
      : null;

  DateTime? _getStartDate([Bookmark? bookmark]) => state.withTargetDate
      ? state.startDate ??
          DateUtils.dateOnly(DateTime.now())
              .add(Duration(days: -(bookmark ?? state.bookmark).dayIndex))
      : null;

  DateTime? _calcTargetDate([Bookmark? bookmark]) => state.withTargetDate
      ? DateUtils.dateOnly(DateTime.now())
          .add(Duration(days: _getRemainingDays(bookmark)))
      : null;

  int _getRemainingDays([Bookmark? bookmark]) => getSchedule() == null
      ? 0
      : getSchedule()!.length - (bookmark ?? state.bookmark).dayIndex;
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
