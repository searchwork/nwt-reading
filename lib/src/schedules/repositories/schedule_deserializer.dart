import 'dart:convert';

import 'package:nwt_reading/src/schedules/entities/schedule.dart';

class ScheduleDeserializer {
  Schedule convertJsonToSchedule(String json) {
    final dayList = jsonDecode(json) as List<dynamic>;
    final days = List<Day>.from(
        dayList.map((dayMap) => _convertMapToDay(dayMap as List<dynamic>)));

    return Schedule(days);
  }

  Day _convertMapToDay(List<dynamic> dayMap) {
    final sections = dayMap
        .map((sectionMap) =>
            _convertMapToSection(sectionMap as Map<String, dynamic>))
        .toList();

    return Day(List<Section>.from(sections));
  }

  Section _convertMapToSection(Map<String, dynamic> sectionMap) {
    final bookIndex = sectionMap['bookIndex'] as int;
    final chapter = sectionMap['chapter'] as int;
    final endChapter = sectionMap['endChapter'] as int;
    final ref = sectionMap['ref'] as String;
    final startIndex = sectionMap['startIndex'] as int;
    final endIndex = sectionMap['endIndex'] as int;
    final url = sectionMap['url'] as String;
    final events = List<String>.from(sectionMap['events'] as List<dynamic>);
    final locations =
        List<String>.from(sectionMap['locations'] as List<dynamic>);

    return Section(
      bookIndex: bookIndex,
      chapter: chapter,
      endChapter: endChapter,
      ref: ref,
      startIndex: startIndex,
      endIndex: endIndex,
      url: url,
      events: events,
      locations: locations,
    );
  }
}
