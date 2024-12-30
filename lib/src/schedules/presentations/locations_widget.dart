import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/locations_localizations_getter.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';

class LocationsWidget extends ConsumerWidget {
  const LocationsWidget(this.locations, {super.key});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsText = locations
        .asMap()
        .entries
        .map((location) =>
            '${context.locationsLoc.getLocation(location.value.key)} ${location.value.refs}')
        .toList()
        .join(' — ');

    return Text.rich(
      TextSpan(text: locationsText),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
