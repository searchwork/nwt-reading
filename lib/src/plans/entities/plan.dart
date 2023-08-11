import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

final planFamilyProvider =
    FutureProviderFamily<PlanFamily?, String>((ref, planId) async {
  ref.watch(plansProvider);

  final plans = await ref.read(plansProvider.notifier).future;
  final plan = plans.plans.firstWhere((plan) => plan.id == planId);

  return PlanFamily(ref,
      plansNotifier: await ref.read(plansProvider.notifier), plan: plan);
}, name: "planFamily");

class PlanFamily {
  PlanFamily(this.ref, {required this.plansNotifier, required this.plan});

  final Ref ref;
  final Plan plan;
  final PlansNotifier plansNotifier;

  void delete() => plansNotifier.removePlan(plan.id);

  int get deviationDays => plan.targetDate == null
      ? 0
      : plan.targetDate!.difference(_calcTargetDate(plan.bookmark)!).inDays;

  void resetTargetDate() {
    if (plan.withTargetDate) {
      plansNotifier.updatePlan(
          plan.copyWith(targetDate: _calcTargetDate(plan.bookmark)));
    }
  }

  DateTime? _calcTargetDate(Bookmark bookmark) {
    if (plan.withTargetDate) {
      final scheduleProvider =
          ref.read(scheduleFamilyProvider(plan.scheduleKey)).valueOrNull;

      return scheduleProvider?.calcTargetDate(bookmark);
    } else {
      return null;
    }
  }

  void setRead({required int dayIndex, required int sectionIndex}) {
    final bookmark = Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex);
    final startDate = plan.startDate ?? DateUtils.dateOnly(DateTime.now());

    plansNotifier.updatePlan(plan.copyWith(
      bookmark: bookmark,
      startDate: startDate,
      targetDate: plan.targetDate ?? _calcTargetDate(bookmark),
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
