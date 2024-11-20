import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanShowEventsTile extends ConsumerWidget {
  const PlanShowEventsTile(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return ListTile(
      title: Text(AppLocalizations.of(context).planEditPageShowEventsTitle),
      subtitle:
          Text(AppLocalizations.of(context).planEditPageShowEventsSubtitle),
      trailing: Switch(
        key: const Key('show-events'),
        value: plan.showEvents,
        onChanged: (bool value) {
          planEdit.updateShowEvents(value);
        },
      ),
    );
  }
}
