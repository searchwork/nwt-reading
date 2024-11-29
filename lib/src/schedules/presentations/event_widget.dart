import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';

class EventWidget extends ConsumerWidget {
  const EventWidget(this.eventKey, this.event, {super.key});

  final String eventKey;
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizationKey =
        'event_${eventKey.replaceAll(RegExp(r'\.'), '').replaceAll(RegExp(r'[^a-zA-Z\d]+'), '_')}';
    return Text.rich(
      style: Theme.of(context).textTheme.bodySmall,
      TextSpan(
        children: <TextSpan>[
          TextSpan(
              text:
                  '${event.prefix != null ? '${context.loc.schedulePageEventPrefixTerm(event.prefix!)} ' : ''}${event.year}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text:
                ' ${context.loc.schedulePageEventCommonEraTerm(event.isCE.toString())} ${context.loc.getEvent(localizationKey)}',
          ),
        ],
      ),
    );
  }
}
