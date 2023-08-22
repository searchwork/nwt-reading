import 'dart:convert';

import 'package:nwt_reading/src/schedules/entities/events.dart';

class EventsDeserializer {
  Events convertJsonToEvents(String json) {
    final eventsMap = jsonDecode(json) as Map<String, dynamic>;
    final events = Map<String, Event>.from(eventsMap.map(
        (eventKey, eventMap) =>
            MapEntry(eventKey, _convertMapToEvent(eventMap as Map<String, dynamic>))));

    return Events(events);
  }

  Event _convertMapToEvent(Map<String, dynamic> eventMap) {
    final prefix = eventMap['prefix'] as String?;
    final year = eventMap['year'] as String;
    final isCE = eventMap['isCE'] as bool;

    return Event(prefix: prefix, year: year, isCE: isCE);
  }
}
