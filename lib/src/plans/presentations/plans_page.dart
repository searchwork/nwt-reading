import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';
import 'package:nwt_reading/src/plans/presentations/plan_edit_dialog.dart';
import 'package:nwt_reading/src/plans/presentations/plans_grid.dart';
import 'package:nwt_reading/src/settings/stories/settings_story.dart';
import 'package:nwt_reading/src/whats_new/presentations/whats_new_dialog.dart';

import '../../settings/presentations/settings_page.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) => FutureBuilder(
        future: _showWhatsNewDialog(context, ref),
        builder: (context, snapshot) => Scaffold(
          appBar: AppBar(
            title: Text(context.loc.plansPageTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.restorablePushNamed(
                      context, SettingsPage.routeName);
                },
              ),
            ],
          ),
          body: PlansGrid(),
          floatingActionButton: FloatingActionButton(
            tooltip: context.loc.plansPageAddPlanTooltip,
            onPressed: () => showDialog<String>(
              context: context,
              builder: (BuildContext context) => PlanEditDialog(),
            ),
            child: const Icon(Icons.add),
          ),
        ),
      );

  List<PlanCard> buildPlansGrid(Plans plans) =>
      plans.plans.map((plan) => PlanCard(plan.id)).toList();

  Future<void> _showWhatsNewDialog(BuildContext context, WidgetRef ref) async {
    final seenWhatsNewVersion =
        (await ref.read(settingsProvider.future)).seenWhatsNewVersion;
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      showWhatsNewDialog(context, ref, seenWhatsNewVersion);
    });
  }
}
