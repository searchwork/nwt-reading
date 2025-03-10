import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

class PlanDurationSegmentedButton extends ConsumerWidget {
  const PlanDurationSegmentedButton(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SegmentedButton<ScheduleDuration>(
        showSelectedIcon: false,
        segments: <ButtonSegment<ScheduleDuration>>[
          ButtonSegment<ScheduleDuration>(
              value: ScheduleDuration.m3,
              label: Text(context.loc.planEditPageMonthsLabel(3))),
          ButtonSegment<ScheduleDuration>(
              value: ScheduleDuration.m6,
              label: Text(context.loc.planEditPageMonthsLabel(6))),
          ButtonSegment<ScheduleDuration>(
              value: ScheduleDuration.y1,
              label: Text(context.loc.planEditPageYearsLabel(1))),
          ButtonSegment<ScheduleDuration>(
              value: ScheduleDuration.y2,
              label: Text(context.loc.planEditPageYearsLabel(2))),
          ButtonSegment<ScheduleDuration>(
              value: ScheduleDuration.y4,
              label: Text(context.loc.planEditPageYearsLabel(4))),
        ],
        selected: {plan.scheduleKey.duration},
        onSelectionChanged: (Set<ScheduleDuration> newSelection) {
          planEdit.updateScheduleDuration(newSelection.single);
        },
      ),
    );
  }
}
