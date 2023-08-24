import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/presentations/plan_duration_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_language_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_type_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_with_target_date_tile.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanNewDialog extends ConsumerWidget {
  const PlanNewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(planEditProviderFamily(null));

    final planEdit = ref.read(planEditProviderFamily(null).notifier);

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
          const PlanTypeSegmentedButton(null),
          const SizedBox(height: 20),
          const PlanDurationSegmentedButton(null),
          const SizedBox(height: 20),
          const PlanLanguageTile(null),
          const PlanWithTargetDateTile(null),
        ],
      ),
    );
  }
}

