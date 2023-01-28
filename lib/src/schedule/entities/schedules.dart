import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final schedulesProvider =
    AsyncNotifierProvider<IncompleteNotifier<Schedules>, Schedules>(
        IncompleteNotifier.new,
        name: 'schedules');

@immutable
class Schedules {
  const Schedules._internal(this.schedules);
  factory Schedules(Map<ScheduleKey, Schedule> schedules) =>
      Schedules._internal(Map.unmodifiable(schedules));

  final Map<ScheduleKey, Schedule> schedules;
}

enum ScheduleType {
  chronological,
  sequential,
  written,
}

enum ScheduleDuration { m3, m6, y1, y2, y4 }

final List<ScheduleKey> scheduleKeys = ScheduleType.values.fold(
    [],
    (scheduleKeys, type) =>
        scheduleKeys +
        [
          for (var duration in [ScheduleDuration.y1])
            ScheduleKey(type: type, duration: duration, version: "1.0")
        ]);

typedef Version = String;

@immutable
class ScheduleKey extends Equatable {
  const ScheduleKey(
      {required this.type, required this.duration, required this.version});
  final ScheduleType type;
  final ScheduleDuration duration;
  final Version version;

  @override
  List<Object> get props => [type, duration, version];
}

@immutable
class Schedule {
  const Schedule._internal(this.days);
  factory Schedule(List<Day> days) =>
      Schedule._internal(List.unmodifiable(days));

  final List<Day> days;

  int get length => days.length;

  Day getDay(int index) => days[index];

  @override
  String toString() => days.toString();
}

@immutable
class Day {
  const Day._internal(this.sections);
  factory Day(List<Section> sections) =>
      Day._internal(List.unmodifiable(sections));

  final List<Section> sections;

  @override
  String toString() => sections.toString();
}

@immutable
class Section extends Equatable {
  const Section(
      {required this.bookIndex,
      required this.chapter,
      required this.endChapter,
      required this.ref,
      required this.startIndex,
      required this.endIndex,
      required this.url,
      required this.events,
      required this.locations});

  final int bookIndex;
  final int chapter;
  final int endChapter;
  final String ref;
  final int startIndex;
  final int endIndex;
  final String url;
  final List<String> events;
  final List<String> locations;

  @override
  List<Object> get props => [
        bookIndex,
        chapter,
        endChapter,
        ref,
        startIndex,
        endIndex,
        url,
        events,
        locations
      ];
}
