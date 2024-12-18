import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
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
    final planNotifier =
        planId != null ? ref.read(planProviderFamily(planId!).notifier) : null;
    final deviationDays = planNotifier?.getDeviationDays() ?? 0;

    return ListTile(
      title: Text(context.loc.planEditPageWithTargetDateTitle),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(context.loc.planEditPageWithTargetDateSubtitle),
          if (planId != null && plan.withTargetDate && plan.targetDate != null)
            Text(
                key: const Key('target-status'),
                context.loc.planEditPageWithTargetDateStatusSubtitle(
                    plan.targetDate!,
                    deviationDays > 0
                        ? 'ahead'
                        : deviationDays < 0
                            ? 'behind'
                            : 'on time',
                    deviationDays.abs())),
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
