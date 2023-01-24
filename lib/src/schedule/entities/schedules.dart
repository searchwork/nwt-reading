import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final schedulesProvider =
    AsyncNotifierProvider<IncompleteNotifier<Schedules>, Schedules>(
        IncompleteNotifier.new,
        name: 'schedules');

typedef Schedules = Map<ScheduleKey, Schedule>;

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

class ScheduleKey extends Equatable {
  const ScheduleKey(
      {required this.type, required this.duration, required this.version});
  final ScheduleType type;
  final ScheduleDuration duration;
  final Version version;

  @override
  List<Object> get props => [type, duration, version];
}

class Schedule {
  Schedule(this.days);

  final List<Day> days;

  int get length => days.length;

  Day getDay(int index) => days[index];
}

class Day {
  Day(this.sections);

  final List<Section> sections;
}

class Section {
  Section(
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
}
