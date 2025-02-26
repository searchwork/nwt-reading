import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/bible_languages/entities/bible_languages.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/events.dart';
import 'package:nwt_reading/src/schedules/entities/locations.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
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

    void toggleRead() {
      try {
        planNotifier.toggleRead(dayIndex: dayIndex, sectionIndex: sectionIndex);
      } on TogglingTooManyDaysException {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(context.loc.schedulePageToggleReadDialogTitle),
            content: Text(context.loc.schedulePageToggleReadDialogText),
            actions: <Widget>[
              TextButton(
                key: const Key('reject-toggle-read'),
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                key: const Key('confirm-toggle-read'),
                onPressed: () {
                  planNotifier.toggleRead(
                      dayIndex: dayIndex,
                      sectionIndex: sectionIndex,
                      force: true);
                  Navigator.pop(context, 'OK');
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconButton(
            iconSize: 27.0,
            isSelected: isRead == true,
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: const Icon(Icons.check_circle),
            onPressed: toggleRead),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: 5.0,
          ),
          TextButton(
              onPressed: () {
                final url = Uri.parse(
                    'https://www.jw.org/finder?srcid=jwlshare&wtlocale=${bibleLanguage?.wtCode}&prefer=lang&bible=${section.url}');
                launchUrl(url, mode: LaunchMode.externalNonBrowserApplication);
              },
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  alignment: Alignment.centerLeft),
              child: Text(
                  '${bibleLanguage?.books[section.bookIndex].name} ${section.ref}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ))),
          if (plan.showEvents && section.events.isNotEmpty)
            Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: -16,
                top: 2,
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ...section.events
                    .map((eventKey) => events?.events[eventKey] != null
                        ? EventWidget(eventKey, events!.events[eventKey]!)
                        : null)
                    .toList()
                    .whereType<Widget>()
              ]),
            ]),
          if (plan.showLocations && section.locations.isNotEmpty)
            Stack(clipBehavior: Clip.none, children: [
              Positioned(
                left: -16,
                top: 2,
                child: Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              LocationsWidget(section.locations
                  .map((locationKey) => locations?.locations[locationKey])
                  .whereType<Location>()
                  .toList()),
            ])
        ])),
      ],
    );
  }
}
