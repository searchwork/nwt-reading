import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';

class PlanShowLocationsTile extends ConsumerWidget {
  const PlanShowLocationsTile(this.planId, {super.key});

  final String? planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planEditProviderFamily(planId));
    ref.watch(planEditProviderFamily(planId));
    final planEdit = ref.read(planEditProviderFamily(planId).notifier);

    return ListTile(
      title: Text(context.loc.planEditPageShowLocationsTitle),
      subtitle: Text(context.loc.planEditPageShowLocationsSubtitle),
      trailing: Switch(
        key: const Key('show-locations'),
        value: plan.showLocations,
        onChanged: (bool value) {
          planEdit.updateShowLocations(value);
        },
      ),
    );
  }
}
