import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanWithTargetDateTile extends ConsumerWidget {
  const PlanWithTargetDateTile(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditFamilyProvider(planId));
    ref.watch(planEditFamilyProvider(planId));
    final planEdit = ref.read(planEditFamilyProvider(planId).notifier);

    return ListTile(
      title: const Text('With Target Date'),
      subtitle: const Text('Track daily reading with a target date.'),
      trailing: Switch(
        key: const Key('with-end-date'),
        value: plan.withTargetDate,
        onChanged: (bool value) {
          planEdit.updateWithTargetDate(value);
        },
      ),
    );
  }
}
