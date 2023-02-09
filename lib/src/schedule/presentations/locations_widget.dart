import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';

class LocationsWidget extends ConsumerWidget {
  const LocationsWidget(this.locations, {super.key});

  final List<Location> locations;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Text.rich(
      style: Theme.of(context).textTheme.bodySmall,
      TextSpan(
        children: [
          const TextSpan(
              text: '📍', style: TextStyle(fontWeight: FontWeight.bold)),
          ...locations.asMap().entries.map((location) =>
              TextSpan(text: (location.key == 0) ? '' : ' — ', children: [
                TextSpan(text: '${location.value.name} ${location.value.refs}'),
              ])),
        ],
      ),
    );
  }
}
