import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final locationsProvider =
    AsyncNotifierProvider<IncompleteNotifier<Locations>, Locations>(
        IncompleteNotifier.new,
        name: 'locations');

class Locations {
  Locations({required this.locations});

  final Map<LocationID, Location> locations;

  int get length => locations.keys.length;

  Iterable<LocationID> get keys => locations.keys;
}

typedef LocationID = String;

class Location {
  Location({required this.name, required this.refs});

  final String name;
  final String refs;
}
