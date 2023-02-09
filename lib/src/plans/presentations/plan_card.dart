import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/schedule/presentations/schedule_page.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard(this.plan, {super.key});

  final Plan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleProvider =
        ref.watch(scheduleFamily(plan.scheduleKey)).valueOrNull;
    // final plansProvider = ref.watch(plansNotifierProvider.select((plans) => plans.valueOrNull;
    final remainingDays = scheduleProvider?.getRemainingDays(plan.bookmark);
    final progress = scheduleProvider?.getProgress(plan.bookmark);
    const planTypeIcons = {
      ScheduleType.chronological: Icons.hourglass_empty,
      ScheduleType.sequential: Icons.menu_book,
      ScheduleType.written: Icons.edit_note,
    };

    return GestureDetector(
        onTap: () {
          Navigator.restorablePushNamed(context, SchedulePage.routeName,
              arguments: plan.id);
        },
        child: Card(
            key: Key('plan-${plan.id}'),
            child: Stack(
              children: [
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
                      if (remainingDays != null) Text('${remainingDays}d'),
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
            )));
  }
}
