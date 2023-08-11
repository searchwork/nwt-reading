import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/repositories/events_deserializer.dart';

final eventsRepositoryProvider = Provider<EventsRepository>(
    (ref) => EventsRepository(ref),
    name: 'eventsRepositoryProvider');

class EventsRepository {
  EventsRepository(this.ref) {
    _setEventsFromJsonFiles();
  }

  final Ref ref;

  void _setEventsFromJsonFiles() async {
    final json = await rootBundle.loadString('assets/repositories/events.json');
    final events = EventsDeserializer().convertJsonToEvents(json);
    ref.read(eventsProvider.notifier).init(events);
  }
}
