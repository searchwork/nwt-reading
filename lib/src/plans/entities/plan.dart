import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planNotifierProviderFamily =
    ProviderFamily<PlanNotifier?, String>((ref, planId) {
  final plan = ref.watch(plansProvider).getPlan(planId);

  if (plan != null) {
    ref.watch(scheduleProviderFamily(plan.scheduleKey));

    return PlanNotifier(ref, plan: plan);
  } else {
    return null;
  }
}, name: 'planNotifierProviderFamily');

class PlanNotifier extends Notifier<Plan> {
  PlanNotifier(this._ref, {required Plan plan})
      : _plan = plan,
        _plansNotifier = _ref.read(plansProvider.notifier),
        _schedule =
            _ref.read(scheduleProviderFamily(plan.scheduleKey)).valueOrNull;

  final Ref _ref;
  final Plan _plan;
  final PlansNotifier _plansNotifier;
  final Schedule? _schedule;

  @override
  build() => _plan;

  Plan getPlan() => _plan;

  void delete() => _plansNotifier.removePlan(_plan.id);

  bool isRead({dayIndex, sectionIndex}) =>
      _plan.bookmark.compareTo(
          Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex)) >=
      0;

  void setRead({required int dayIndex, required int sectionIndex}) {
    final sections = _schedule?.days[dayIndex].sections.length;
    final newBookmark = sections != null && sectionIndex >= sections - 1
        ? Bookmark(dayIndex: dayIndex + 1, sectionIndex: -1)
        : Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex);

    _plansNotifier.updatePlan(_plan.copyWith(
      bookmark: newBookmark,
      startDate: _getStartDate(newBookmark),
      targetDate: _plan.targetDate ?? _calcTargetDate(newBookmark),
    ));
  }

  void setUnread({required int dayIndex, required int sectionIndex}) =>
      setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);

  void resetTargetDate() {
    if (_plan.withTargetDate) {
      _plansNotifier.updatePlan(
          _plan.copyWith(targetDate: _calcTargetDate(_plan.bookmark)));
    }
  }

  double getProgress() =>
      _schedule == null ? 0 : _plan.bookmark.dayIndex / _schedule!.length;

  int getDeviationDays() {
    if (_plan.withTargetDate && getTargetDate() != null) {
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

  DateTime? getTargetDate() => _plan.targetDate ?? _calcTargetDate();

  int? todayTargetIndex() => _plan.withTargetDate &&
          getTargetDate() != null &&
          _schedule != null
      ? _schedule!.length -
          getTargetDate()!.difference(DateUtils.dateOnly(DateTime.now())).inDays
      : null;

  DateTime? _getStartDate([Bookmark? bookmark]) => _plan.withTargetDate
      ? _plan.startDate ??
          DateUtils.dateOnly(DateTime.now())
              .add(Duration(days: -(bookmark ?? _plan.bookmark).dayIndex))
      : null;

  DateTime? _calcTargetDate([Bookmark? bookmark]) => _plan.withTargetDate
      ? DateUtils.dateOnly(DateTime.now())
          .add(Duration(days: _getRemainingDays(bookmark)))
      : null;

  int _getRemainingDays([Bookmark? bookmark]) => _schedule == null
      ? 0
      : _schedule!.length - (bookmark ?? _plan.bookmark).dayIndex;
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
