import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

class PlanDurationSegmentedButton extends ConsumerWidget {
  const PlanDurationSegmentedButton(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return SegmentedButton<ScheduleDuration>(
      segments: const <ButtonSegment<ScheduleDuration>>[
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.m3, label: Text('3 months')),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.m6, label: Text('6 months')),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y1, label: Text('1 year')),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y2, label: Text('2 years')),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y4, label: Text('4 years')),
      ],
      selected: {plan.scheduleKey.duration},
      onSelectionChanged: (Set<ScheduleDuration> newSelection) {
        planEdit.updateScheduleDuration(newSelection.single);
      },
    );
  }
}
