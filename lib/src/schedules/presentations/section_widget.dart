import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/event_widget.dart';
import 'package:nwt_reading/src/schedules/presentations/locations_widget.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final plan = ref.watch(planProviderFamily(planId));
    final planNotifier = ref.read(planProviderFamily(planId).notifier);
    final isRead =
        planNotifier.isRead(dayIndex: dayIndex, sectionIndex: sectionIndex);
    final bibleLanguage = ref.watch(bibleLanguagesProvider.select(
        (bibleLanguages) =>
            bibleLanguages.valueOrNull?.bibleLanguages[plan.language]));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
          isSelected: isRead == true,
          icon: const Icon(Icons.check_circle_outline),
          selectedIcon: const Icon(Icons.check_circle),
          onPressed: () => isRead == true
              ? planNotifier.setUnread(
                  dayIndex: dayIndex, sectionIndex: sectionIndex)
              : planNotifier.setRead(
                  dayIndex: dayIndex, sectionIndex: sectionIndex),
        ),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextButton(
              onPressed: () => _launchUrl(Uri.parse(
                  'https://www.jw.org/finder?srcid=jwlshare&wtlocale=${bibleLanguage?.wtCode}&prefer=lang&bible=${section.url}')),
              child: Text(
                  '${bibleLanguage?.books[section.bookIndex].name} ${section.ref}',
                  style: const TextStyle(color: Color(0xff007bff)))),
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

Future<void> _launchUrl(Uri url) async {
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
}
