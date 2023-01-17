import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/domains/incomplete_notifier.dart';

final eventsProvider =
    AsyncNotifierProvider<IncompleteNotifier<Events>, Events>(
        IncompleteNotifier.new,
        name: 'events');

class Events {
  Events({required this.events});

  final Map<EventID, Event> events;

  int get length => events.keys.length;

  Iterable<EventID> get keys => events.keys;
}

typedef EventID = String;

class Event {
  Event({this.prefix, required this.year, required this.isCE});

  final String? prefix;
  final String year;
  final bool isCE;
}
