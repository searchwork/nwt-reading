import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      title: const Text('Show Locations'),
      subtitle: const Text('Show the referred locations in the sections.'),
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
