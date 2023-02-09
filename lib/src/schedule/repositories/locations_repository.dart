import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/repositories/locations_deserializer.dart';

final locationsRepository = Provider<LocationsRepository>(
    (ref) => LocationsRepository(ref),
    name: 'locationsRepository');

class LocationsRepository {
  LocationsRepository(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() async {
    _setLocationsFromJsonFiles();
  }

  void _setLocationsFromJsonFiles() async {
    final json =
        await rootBundle.loadString('assets/repositories/locations.json');
    final locations = LocationsDeserializer().convertJsonToLocations(json);
    ref.read(locationsNotifier.notifier).init(locations);
  }
}
