
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedule/entities/events.dart';
import 'package:nwt_reading/src/schedule/entities/locations.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/schedule/presentations/event_widget.dart';
import 'package:nwt_reading/src/schedule/presentations/locations_widget.dart';

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
    final events = ref.watch(eventsNotifier).valueOrNull;
    final locations = ref.watch(locationsNotifier).valueOrNull;
    final bibleLanguage = ref.watch(bibleLanguagesNotifier.select(
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
                  ? EventWidget(events!.events[eventKey]!)
                  : null)
              .toList()
              .whereType<Widget>(),
          if (section.locations.isNotEmpty)
            LocationsWidget(section.locations
                .map((locationKey) => locations?.locations[locationKey])
                .whereType<Location>()
                .toList()),
        ])),
      ],
    );
  }
}
