import 'dart:convert';

import 'package:nwt_reading/src/schedule/entities/events.dart';

class EventsDeserializer {
  Events convertJsonToEvents(String json) {
    final eventsMap = jsonDecode(json);
    final events = Map<String, Event>.from(eventsMap.map(
        (String eventKey, eventMap) =>
            MapEntry(eventKey, _convertMapToEvent(eventMap))));

    return Events(events);
  }

  Event _convertMapToEvent(Map<String, dynamic> eventMap) {
    final prefix = eventMap['prefix'] as String?;
    final year = eventMap['year'] as String;
    final isCE = eventMap['isCE'] as bool;

    return Event(prefix: prefix, year: year, isCE: isCE);
  }
}
