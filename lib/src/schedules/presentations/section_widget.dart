import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/event_widget.dart';
import 'package:nwt_reading/src/schedules/presentations/locations_widget.dart';

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
    final plan = ref.watch(planFamilyEdit(planId));
    final planEdit = ref.watch(planFamilyEdit(planId).notifier);
    final isRead = plan.isRead(dayIndex: dayIndex, sectionIndex: sectionIndex);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          isSelected: isRead == true,
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          onPressed: () => isRead == true
              ? planEdit.saveUnread(
                  dayIndex: dayIndex, sectionIndex: sectionIndex)
              : planEdit.saveRead(
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
