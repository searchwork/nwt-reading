import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/presentations/plans_page.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

class PlanEditDialog extends ConsumerWidget {
  const PlanEditDialog(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planEdit = ref.watch(planEditFamilyNotifier(planId).notifier);

    return Dialog.fullscreen(
      child: Column(
        children: [
          Row(children: [
            IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  planEdit.reset();
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => Navigator.pop(context));
                }),
            const Spacer(),
            IconButton(
                icon: const Icon(Icons.done),
                onPressed: () {
                  planEdit.save();
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => Navigator.pop(context));
                })
          ]),
          PlanTypeSegmentedButton(planId),
          PlanDurationSegmentedButton(planId),
          ElevatedButton.icon(
              onPressed: () {
                planEdit.delete();
                Navigator.popUntil(
                    context, ModalRoute.withName(PlansPage.routeName));
              },
              icon: const Icon(Icons.delete),
              label: const Text('Delete'))
        ],
      ),
    );
  }
}

class PlanTypeSegmentedButton extends ConsumerWidget {
  const PlanTypeSegmentedButton(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditFamilyNotifier(planId));
    final planEdit = ref.watch(planEditFamilyNotifier(planId).notifier);

    return SegmentedButton<ScheduleType>(
      segments: const <ButtonSegment<ScheduleType>>[
        ButtonSegment<ScheduleType>(
            value: ScheduleType.chronological,
            label: Text('chronological'),
            icon: Icon(Icons.hourglass_empty)),
        ButtonSegment<ScheduleType>(
            value: ScheduleType.sequential,
            label: Text('sequential'),
            icon: Icon(Icons.menu_book)),
        ButtonSegment<ScheduleType>(
            value: ScheduleType.written,
            label: Text('as written'),
            icon: Icon(Icons.edit_note)),
      ],
      selected: {plan.scheduleKey.type},
      onSelectionChanged: (Set<ScheduleType> newSelection) {
        planEdit.updateScheduleType(newSelection.single);
      },
    );
  }
}

class PlanDurationSegmentedButton extends ConsumerWidget {
  const PlanDurationSegmentedButton(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditFamilyNotifier(planId));
    final planEdit = ref.watch(planEditFamilyNotifier(planId).notifier);

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
