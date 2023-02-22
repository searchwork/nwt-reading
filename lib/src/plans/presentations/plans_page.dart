import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

import '../../settings/presentations/settings_page.dart';

class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});
  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.plansPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsPage.routeName);
            },
          ),
        ],
      ),
      body: plans.when(
          data: (plans) => plans.plans.isEmpty
              ? Center(
                  key: const Key('no-plan-yet'),
                  child: Text(AppLocalizations.of(context)!.noPlanYet),
                )
              : GridView.extent(
                  childAspectRatio: 1.6,
                  maxCrossAxisExtent: 600,
                  padding: const EdgeInsets.all(20),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  restorationId: 'plansView',
                  children: buildPlansGrid(plans),
                ),
          error: (error, stack) => Text(error.toString()),
          loading: () => const Center(
                child: CircularProgressIndicator(),
              )),
      floatingActionButton: FloatingActionButton(
        tooltip: AppLocalizations.of(context)!.addPlanTooltip,
        onPressed: () => ref.read(plansNotifier.notifier).newPlan(),
        child: const Icon(Icons.add),
      ),
    );
  }

  List<PlanCard> buildPlansGrid(Plans plans) =>
      plans.plans.map((plan) => PlanCard(plan)).toList();
}
