import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

    return SegmentedButton<ScheduleDuration>(
      segments: <ButtonSegment<ScheduleDuration>>[
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.m3,
            label: Text(
                AppLocalizations.of(context).planEditPageThreeMonthsLabel)),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.m6,
            label:
                Text(AppLocalizations.of(context).planEditPageSixMonthsLabel)),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y1,
            label: Text(AppLocalizations.of(context).planEditPageOneYearLabel)),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y2,
            label:
                Text(AppLocalizations.of(context).planEditPageTwoYearsLabel)),
        ButtonSegment<ScheduleDuration>(
            value: ScheduleDuration.y4,
            label:
                Text(AppLocalizations.of(context).planEditPageFourYearsLabel)),
      ],
      selected: {plan.scheduleKey.duration},
      onSelectionChanged: (Set<ScheduleDuration> newSelection) {
        planEdit.updateScheduleDuration(newSelection.single);
      },
    );
  }
}
