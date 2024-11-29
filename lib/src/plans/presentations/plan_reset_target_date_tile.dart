import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanResetTargetDateTile extends ConsumerWidget {
  const PlanResetTargetDateTile(this.planId, this.adjustedTargetDate,
      {super.key});

  final String? planId;
  final DateTime adjustedTargetDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return ListTile(
      key: const Key('reset-target-date'),
      title: Text(context.loc.planEditPageResetTargetDateTitle),
      subtitle: Text(
          context.loc.planEditPageResetTargetDateSubtitle(adjustedTargetDate)),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text(context.loc.planEditPageResetTargetDateDialogTitle),
            content: Text(context.loc.planEditPageResetTargetDateDialogText),
            actions: <Widget>[
              TextButton(
                key: const Key('reject-reset-target-date'),
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child:
                    Text(MaterialLocalizations.of(context).cancelButtonLabel),
              ),
              TextButton(
                key: const Key('confirm-reset-target-date'),
                onPressed: () {
                  planEdit.resetTargetDate();
                  Navigator.pop(context, 'OK');
                },
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}
