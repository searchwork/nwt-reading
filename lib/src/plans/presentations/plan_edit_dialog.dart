import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/presentations/plan_duration_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_language_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_type_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_with_target_date_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plans_page.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanEditDialog extends ConsumerWidget {
  const PlanEditDialog([this.planId, Key? key]) : super(key: key);

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(planEditProviderFamily(planId));

    final planEdit = ref.read(planEditProviderFamily(planId).notifier);
    final isNewPlan = planId == null;

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
          if (isNewPlan) PlanTypeSegmentedButton(planId),
          const SizedBox(height: 20),
          PlanDurationSegmentedButton(planId),
          const SizedBox(height: 20),
          PlanLanguageTile(planId),
          PlanWithTargetDateTile(planId),
          if (!isNewPlan) ElevatedButton.icon(
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
