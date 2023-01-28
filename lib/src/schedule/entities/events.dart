import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/entities/incomplete_notifier.dart';

final eventsProvider =
    AsyncNotifierProvider<IncompleteNotifier<Events>, Events>(
        IncompleteNotifier.new,
        name: 'events');

@immutable
class Events {
  const Events._internal(this.events);
  factory Events(Map<EventID, Event> bibleLanguages) =>
      Events._internal(Map.unmodifiable(bibleLanguages));

  final Map<EventID, Event> events;

  int get length => events.keys.length;

  Iterable<EventID> get keys => events.keys;
}

typedef EventID = String;

@immutable
class Event extends Equatable {
  const Event({this.prefix, required this.year, required this.isCE});

  final String? prefix;
  final String year;
  final bool isCE;

  @override
  List<Object?> get props => [prefix, year, isCE];
}
