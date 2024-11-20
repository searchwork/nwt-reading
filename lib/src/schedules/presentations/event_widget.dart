import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';

class EventWidget extends ConsumerWidget {
  const EventWidget(this.event, {super.key});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text.rich(
      style: Theme.of(context).textTheme.bodySmall,
      TextSpan(
        children: <TextSpan>[
          TextSpan(
              text:
                  '${event.prefix != null ? '${event.prefix} ' : ''}${event.year}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text:
                ' ${AppLocalizations.of(context).schedulePageEventCommonEraTerm(event.isCE.toString())} Cain slays Abel (Gen. 4:8)',
          ),
        ],
      ),
    );
  }
}
