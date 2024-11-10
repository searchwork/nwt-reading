import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanWithTargetDateTile extends ConsumerWidget {
  const PlanWithTargetDateTile(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);
    final formattedTargetDate = plan.targetDate != null
        ? DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
            .format(plan.targetDate!)
        : '';
    final planNotifier =
        planId != null ? ref.read(planProviderFamily(planId!).notifier) : null;
    final deviationDays = planNotifier?.getDeviationDays() ?? 0;

    return ListTile(
      title: const Text('With Target Date'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Track daily reading with a target date.'),
          if (planId != null && plan.withTargetDate)
            Text(
                key: const Key('target-status'),
                'The target date is $formattedTargetDate. You are ${deviationDays == 0 ? 'on time' : '${deviationDays.abs()} days ${deviationDays < 0 ? 'behind' : 'ahead'}'} with reading.'),
        ],
      ),
      trailing: Switch(
        key: const Key('with-target-date'),
        value: plan.withTargetDate,
        onChanged: (bool value) {
          planEdit.updateWithTargetDate(value);
        },
      ),
    );
  }
}
