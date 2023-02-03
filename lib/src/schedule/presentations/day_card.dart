import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';

class DayCard extends ConsumerWidget {
  const DayCard(
      {super.key,
      required this.planId,
      required this.day,
      required this.dayIndex});
  final String planId;
  final Day day;
  final int dayIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(
              children: [
                ...day.sections.asMap().entries.map((section) => SectionWidget(
                    key: Key('section-${section.key}'),
                    planId: planId,
                    section: section.value,
                    dayIndex: dayIndex,
                    sectionIndex: section.key)),
              ],
            )),
            Container(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                width: 25,
                child: Text((dayIndex + 1).toString(),
                    style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}

class SectionWidget extends ConsumerWidget {
  const SectionWidget(
      {super.key,
      required this.planId,
      required this.section,
      required this.dayIndex,
      required this.sectionIndex});
  final String planId;
  final Section section;
  final int dayIndex;
  final int sectionIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider).valueOrNull;
    final locations = ref.watch(locationsProvider).valueOrNull;
    final bibleLanguage = ref.watch(bibleLanguagesProvider.select(
        (bibleLanguages) => bibleLanguages.valueOrNull
            ?.bibleLanguages[Localizations.localeOf(context).languageCode]));
    final planProvider = ref.read(planFamilyProvider(planId)).valueOrNull;
    final isRead =
        planProvider?.isRead(dayIndex: dayIndex, sectionIndex: sectionIndex);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          isSelected: isRead == true,
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          onPressed: () => isRead == true
              ? planProvider?.setUnread(
                  dayIndex: dayIndex, sectionIndex: sectionIndex)
              : planProvider?.setRead(
                  dayIndex: dayIndex, sectionIndex: sectionIndex),
        ),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("${bibleLanguage?.books[section.bookIndex].name} ${section.ref}",
              style: const TextStyle(color: Color(0xff007bff))),
          ...section.events
              .map((eventKey) => events?.events[eventKey] != null
                  ? EventWidget(event: events!.events[eventKey]!)
                  : null)
              .toList()
              .whereType<Widget>(),
          if (section.locations.isNotEmpty)
            LocationsWidget(
                locations: section.locations
                    .map((locationKey) => locations?.locations[locationKey])
                    .whereType<Location>()
                    .toList()),
        ])),
      ],
    );
  }
}

class EventWidget extends ConsumerWidget {
  const EventWidget({super.key, required this.event});
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
                ' ${event.isCE ? 'C.E.' : 'B.C.E'} Cain slays Abel (Gen. 4:8)',
          ),
        ],
      ),
    );
  }
}

class LocationsWidget extends ConsumerWidget {
  const LocationsWidget({super.key, required this.locations});
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
