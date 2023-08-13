import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/schedule_page.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard(this.planId, {super.key});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planProvider = ref.watch(planFamilyProvider(planId)).valueOrNull;
    final plan = planProvider?.plan;
    final deviationDays = planProvider?.deviationDays ?? 0;
    final remainingDays = planProvider?.remainingDays ?? 0;
    final progress = planProvider?.getProgress();
    const planTypeIcons = {
      ScheduleType.chronological: Icons.hourglass_empty,
      ScheduleType.sequential: Icons.menu_book,
      ScheduleType.written: Icons.edit_note,
    };

    final card = Card(
        key: Key('plan-$planId'),
        child: Stack(
          children: [
            if (plan != null)
              Positioned(
                  left: 10,
                  top: 10,
                  child: Row(children: [
                    Icon(
                      planTypeIcons[plan.scheduleKey.type],
                      color: Colors.black54,
                      size: 56,
                      shadows: const [
                        Shadow(
                            offset: Offset(-1, -1),
                            color: Colors.black26,
                            blurRadius: 2),
                        Shadow(
                            offset: Offset(1, 1),
                            color: Colors.white,
                            blurRadius: 2)
                      ],
                    ),
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.headlineMedium,
                    )
                  ])),
            Positioned(
                right: 15,
                bottom: 15,
                child: Stack(alignment: Alignment.center, children: [
                  Text('${remainingDays}d'),
                  if (progress != null)
                    SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          value: progress,
                        ))
                ])),
          ],
        ));
    return GestureDetector(
        onTap: () {
          Navigator.restorablePushNamed(context, SchedulePage.routeName,
              arguments: planId);
        },
        child: deviationDays == 0
            ? card
            : Badge(
                key: Key('badge-$planId'),
                label: Text('${deviationDays.abs()}'),
                backgroundColor: deviationDays > 0 ? Colors.green : Colors.red,
                child: card));
  }
}
