import 'dart:convert';

import 'package:nwt_reading/src/schedules/entities/locations.dart';

class LocationsDeserializer {
  Locations convertJsonToLocations(String json) {
    final locationsMap = jsonDecode(json) as Map<String, dynamic>;
    final locations = Map<String, Location>.from(locationsMap.map(
        (locationKey, locationMap) => MapEntry(locationKey,
            _convertMapToLocation(locationMap as Map<String, dynamic>))));

    return Locations(locations);
  }

  Location _convertMapToLocation(Map<String, dynamic> locationMap) {
    final name = locationMap['name'] as String;
    final refs = locationMap['refs'] as String;

    return Location(name: name, refs: refs);
  }
}
