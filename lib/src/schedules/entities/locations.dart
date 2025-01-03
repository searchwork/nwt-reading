import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final locationsProvider =
    AsyncNotifierProvider<IncompleteNotifier<Locations>, Locations>(
        IncompleteNotifier.new,
        name: 'locationsProvider');

@immutable
class Locations {
  const Locations._internal(this.locations);
  factory Locations(Map<LocationID, Location> locations) =>
      Locations._internal(Map.unmodifiable(locations));

  final Map<LocationID, Location> locations;

  int get length => keys.length;

  Iterable<LocationID> get keys => locations.keys;
}

typedef LocationID = String;

@immutable
class Location extends Equatable {
  const Location({required this.key, required this.refs});

  final String key;
  final String refs;

  @override
  List<Object> get props => [key, refs];
}
