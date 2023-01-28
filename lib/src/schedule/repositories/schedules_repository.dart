import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedule/repositories/schedule_deserializer.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';

final schedulesRepositoryProvider = Provider<SchedulesRepository>(
    (ref) => SchedulesRepository(ref),
    name: 'schedulesRepository');

class SchedulesRepository {
  SchedulesRepository(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() async {
    final schedules = await _getSchedulesFromJsonFiles();
    ref.read(schedulesProvider.notifier).init(schedules);
  }

  Future<Schedules> _getSchedulesFromJsonFiles() async => Schedules({
        for (var scheduleKey in scheduleKeys)
          scheduleKey: await _getScheduleFromJsonFile(scheduleKey)
      });

  Future<Schedule> _getScheduleFromJsonFile(ScheduleKey key) async {
    debugPrint(
        '... getScheduleFromJsonFile: assets/repositories/schedule_${key.type.name}_${key.duration.name}.json');
    final json = await rootBundle.loadString(
        'assets/repositories/schedule_${key.type.name}_${key.duration.name}.json');

    return ScheduleDeserializer().convertJsonToSchedule(json);
  }
}
