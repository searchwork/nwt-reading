import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedule/domains/events.dart';
import 'package:nwt_reading/src/schedule/repositories/events_deserializer.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
    (ref) => EventsRepository(ref),
    name: 'eventsRepository');

class EventsRepository {
  EventsRepository(this.ref) {
    _init();
  }

  final Ref ref;

  void _init() async {
    _setEventsFromJsonFiles();
  }

  void _setEventsFromJsonFiles() async {
    final json = await rootBundle.loadString('assets/repositories/events.json');
    final events = EventsDeserializer().convertJsonToEvents(json);
    ref.read(eventsProvider.notifier).init(events);
  }
}