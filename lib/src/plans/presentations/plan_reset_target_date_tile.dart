import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanResetTargetDateTile extends ConsumerWidget {
  const PlanResetTargetDateTile(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);
    final adjustedTargetDate = planEdit.calcTargetDate();
    final formattedAdjustedTargetDate = adjustedTargetDate != null
        ? DateFormat.yMd(Localizations.localeOf(context).toLanguageTag())
            .format(adjustedTargetDate)
        : '';

    return ListTile(
      key: const Key('reset-target-date'),
      title: const Text('Reset Target Date'),
      subtitle: Text(
          'Change target date to $formattedAdjustedTargetDate to be on time with reading.'),
      trailing: Icon(Icons.arrow_forward),
      onTap: () {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Confirm resetting target date'),
            content: const Text(
                'Do you want to change the target date to be on time with reading?'),
            actions: <Widget>[
              TextButton(
                key: const Key('reject-reset-target-date'),
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                key: const Key('confirm-reset-target-date'),
                onPressed: () {
                  planEdit.resetTargetDate();
                  Navigator.pop(context, 'OK');
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}
