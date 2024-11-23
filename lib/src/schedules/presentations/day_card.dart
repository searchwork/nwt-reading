import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:nwt_reading/src/schedules/presentations/section_widget.dart';

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
