import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

final schedulesProvider =
    AsyncNotifierProvider<IncompleteNotifier<Schedules>, Schedules>(
        IncompleteNotifier.new,
        name: 'schedulesProvider');

@immutable
class Schedules {
  const Schedules._internal(this.schedules);
  factory Schedules(Map<ScheduleKey, Schedule> schedules) =>
      Schedules._internal(Map.unmodifiable(schedules));

  final Map<ScheduleKey, Schedule> schedules;

  int get length => schedules.length;
}
