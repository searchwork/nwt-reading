import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/plans/presentations/plan_card.dart';

class PlansGrid extends ConsumerWidget {
  const PlansGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);

    return plans.plans.isEmpty
        ? Center(
            key: const Key('no-plan-yet'),
            child: Text(context.loc.plansPageNoPlanYet),
          )
        : GridView.extent(
            childAspectRatio: 1.6,
            maxCrossAxisExtent: 600,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            restorationId: 'plansView',
            children: buildPlansGrid(plans),
          );
  }

  List<PlanCard> buildPlansGrid(Plans plans) =>
      plans.plans.map((plan) => PlanCard(plan.id)).toList();
}
