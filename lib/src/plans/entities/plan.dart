import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';

final plansFamilyProvider =
    FutureProvider.family<PlansFamilyProvider?, String>((ref, planId) async {
  ref.watch(plansProvider);
  final plans = await ref.watch(plansProvider.notifier).future;
  final planList = plans.plans.where((plan) => plan.id == planId);

  return planList.isEmpty
      ? null
      : PlansFamilyProvider(ref, plan: planList.first);
}, name: "plansFamily");

class PlansFamilyProvider {
  PlansFamilyProvider(this.ref, {required this.plan});

  final Ref ref;
  final Plan plan;

  Schedule? get schedule {
    final schedules = ref.read(schedulesProvider).valueOrNull;

    return schedules?.schedules[plan.scheduleKey];
  }

  int? get length => schedule?.length;

  int? get remainingDays {
    if (length == null) return null;
    return length! - plan.bookmark.dayIndex;
  }

  double? get progress {
    if (length == null) return null;
    return plan.bookmark.dayIndex / length!;
  }

  DateTime? get endDate {
    if (remainingDays == null) return null;
    return plan.endDate ?? DateTime.now().add(Duration(days: remainingDays!));
  }

  bool isRead({dayIndex, sectionIndex}) =>
      plan.bookmark.compareTo(
          Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex)) >=
      0;

  void setRead({required int dayIndex, required int sectionIndex}) {
    final updatedPlan = plan.copyWith(
        bookmark: Bookmark(dayIndex: dayIndex, sectionIndex: sectionIndex));
    ref
        .read(plansProvider.notifier)
        .updatePlan(planId: plan.id, plan: updatedPlan);
  }

  void setUnread({required int dayIndex, required int sectionIndex}) {
    setRead(dayIndex: dayIndex, sectionIndex: sectionIndex - 1);
  }
}

@immutable
class Plan extends Equatable {
  const Plan({
    required this.id,
    required this.name,
    required this.scheduleKey,
    required this.language,
    required this.bookmark,
    this.startDate,
    this.endDate,
    required this.withEndDate,
    required this.showEvents,
    required this.showLocations,
  });

  final String id;
  final String name;
  final ScheduleKey scheduleKey;
  final String language;
  final Bookmark bookmark;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool withEndDate;
  final bool showEvents;
  final bool showLocations;

  Plan copyWith(
          {String? id,
          String? name,
          ScheduleKey? scheduleKey,
          String? language,
          Bookmark? bookmark,
          DateTime? startDate,
          DateTime? endDate,
          bool? withEndDate,
          bool? showEvents,
          bool? showLocations}) =>
      Plan(
        id: id ?? this.id,
        name: name ?? this.name,
        scheduleKey: scheduleKey ?? this.scheduleKey,
        language: language ?? this.language,
        bookmark: bookmark ?? this.bookmark,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        withEndDate: withEndDate ?? this.withEndDate,
        showEvents: showEvents ?? this.showEvents,
        showLocations: showLocations ?? this.showLocations,
      );

  @override
  List<Object?> get props => [
        id,
        name,
        scheduleKey,
        language,
        bookmark,
        startDate,
        endDate,
        withEndDate,
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
