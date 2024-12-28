import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

class PlanTypeSegmentedButton extends ConsumerWidget {
  const PlanTypeSegmentedButton(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        children: [
          SegmentedButton<ScheduleType>(
            showSelectedIcon: false,
            segments: <ButtonSegment<ScheduleType>>[
              ButtonSegment<ScheduleType>(
                  value: ScheduleType.chronological,
                  label: Text(context.loc.planEditPageChronologicalLabel),
                  icon: Icon(Icons.hourglass_empty)),
              ButtonSegment<ScheduleType>(
                  value: ScheduleType.canonical,
                  label: Text(context.loc.planEditPageCanonicalLabel),
                  icon: Icon(Icons.menu_book)),
              ButtonSegment<ScheduleType>(
                  value: ScheduleType.written,
                  label: Text(context.loc.planEditPageAsWrittenLabel),
                  icon: Icon(Icons.edit_note)),
            ],
            selected: {plan.scheduleKey.type},
            onSelectionChanged: (Set<ScheduleType> newSelection) {
              planEdit.updateScheduleType(newSelection.single);
            },
          ),
          const SizedBox(height: 10),
          Text(
            switch (plan.scheduleKey.type) {
              ScheduleType.chronological =>
                context.loc.planEditPageChronologicalDescription,
              ScheduleType.canonical =>
                context.loc.planEditPageCanonicalDescription,
              ScheduleType.written =>
                context.loc.planEditPageAsWrittenDescription,
            },
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
