import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/presentations/plan_duration_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_language_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_name_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_reset_target_date_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_show_events_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_show_locations_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plan_type_segmented_button.dart';
import 'package:nwt_reading/src/plans/presentations/plan_with_target_date_tile.dart';
import 'package:nwt_reading/src/plans/presentations/plans_page.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanEditDialog extends ConsumerWidget {
  PlanEditDialog([this.planId, Key? key]) : super(key: key);

  final String? planId;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);
    final adjustedTargetDate = planEdit.calcTargetDate();
    final isNewPlan = planId == null;

    return Dialog.fullscreen(
        child: Form(
      key: _formKey,
      child: SingleChildScrollView(
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
                    if (_formKey.currentState!.validate()) {
                      planEdit.save();
                      WidgetsBinding.instance
                          .addPostFrameCallback((_) => Navigator.pop(context));
                    }
                  })
            ]),
            PlanNameTile(planId),
            const SizedBox(height: 20),
            if (isNewPlan) PlanTypeSegmentedButton(planId),
            if (isNewPlan) const SizedBox(height: 20),
            PlanDurationSegmentedButton(planId),
            const SizedBox(height: 20),
            PlanLanguageTile(planId),
            PlanWithTargetDateTile(planId),
            if (plan.withTargetDate &&
                adjustedTargetDate != null &&
                plan.targetDate != adjustedTargetDate)
              PlanResetTargetDateTile(planId, adjustedTargetDate),
            PlanShowEventsTile(planId),
            PlanShowLocationsTile(planId),
            if (!isNewPlan)
              ElevatedButton.icon(
                  onPressed: () {
                    showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text(context.loc.planEditDeleteDialogTitle),
                        content: Text(context.loc.planEditDeleteDialogText),
                        actions: <Widget>[
                          TextButton(
                            key: const Key('reject-delete-plan'),
                            onPressed: () => Navigator.pop(context, 'Cancel'),
                            child: Text(MaterialLocalizations.of(context)
                                .cancelButtonLabel),
                          ),
                          TextButton(
                            key: const Key('confirm-delete-plan'),
                            style: ButtonStyle(
                                foregroundColor: WidgetStatePropertyAll<Color>(
                                    Theme.of(context).colorScheme.error)),
                            onPressed: () {
                              planEdit.delete();
                              Navigator.popUntil(context,
                                  ModalRoute.withName(PlansPage.routeName));
                            },
                            child: Text(MaterialLocalizations.of(context)
                                .deleteButtonTooltip),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete),
                  label: Text(
                      MaterialLocalizations.of(context).deleteButtonTooltip))
          ],
        ),
      ),
    ));
  }
}
