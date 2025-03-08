import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/base/presentation/plan.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:nwt_reading/src/schedules/presentations/schedule_page.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plan = ref.watch(planProviderFamily(planId));
    final planNotifier = ref.read(planProviderFamily(planId).notifier);
    final deviationDays = planNotifier.getDeviationDays();
    final remainingDays = planNotifier.getRemainingDays();
    final isFinished = planNotifier.isFinished();
    final progress = planNotifier.getProgress();
    const planTypeIcons = {
      ScheduleType.chronological: Icons.hourglass_empty,
      ScheduleType.canonical: Icons.menu_book,
      ScheduleType.written: Icons.edit_note,
    };

    buildNameTitle() => Row(children: [
          Icon(
            planTypeIcons[plan.scheduleKey.type],
            color: Theme.of(context).colorScheme.surface,
            size: 56,
            shadows: [
              Shadow(
                  offset: Offset(-1, -1),
                  color: Theme.of(context).colorScheme.primary,
                  blurRadius: 2),
              Shadow(
                  offset: Offset(1, 1),
                  color: Theme.of(context).colorScheme.onPrimary,
                  blurRadius: 2)
            ],
          ),
          Text(
            getPlanName(context, plan),
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.secondary),
          )
        ]);

    buildYearText() => Text(
          plan.lastDate == null
              ? ''
              : MaterialLocalizations.of(context).formatYear(plan.lastDate!),
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: MediaQuery.of(context).size.width * 0.1, // Dynamic font size
                color: Theme.of(context).colorScheme.primary,
              ),
        );

    buildRemainingDaysStatus() => isFinished
        ? Icon(Icons.verified, color: Colors.green, size: 72)
        : Stack(alignment: Alignment.center, children: [
            Text(
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                remainingDays == null
                    ? ''
                    : context.loc.plansPageCardRemainingDays(remainingDays)),
            SizedBox(
                width: 60,
                height: 60,
                child:
                    CircularProgressIndicator(strokeWidth: 6, value: progress)),
          ]);

    final card = Card(
      key: Key('plan-$planId'),
      child: Stack(
        children: [
          Positioned(left: 10, top: 10, child: buildNameTitle()),
          Positioned(right: 15, bottom: 15, child: buildRemainingDaysStatus()),
          Positioned(left: 20, bottom: 0, child: buildYearText()), // Updated to prevent overlap
        ],
      ),
    );

    return GestureDetector(
        onTap: () {
          Navigator.restorablePushNamed(context, SchedulePage.routeName,
              arguments: planId);
        },
        child: deviationDays == 0 || isFinished
            ? card
            : Badge(
                key: Key('badge-$planId'),
                label: Text('${deviationDays.abs()}'),
                backgroundColor: deviationDays > 0 ? Colors.green : Colors.red,
                child: card));
  }
}
