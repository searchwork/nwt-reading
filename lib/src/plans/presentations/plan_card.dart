import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/schedule/presentations/schedule_page.dart';

class PlanCard extends ConsumerWidget {
  const PlanCard({super.key, required this.plan});
  final Plan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(schedulesProvider);
    final planProvider = ref.watch(plansFamilyProvider(plan.id)).valueOrNull;
    final remainingDays = planProvider?.remainingDays;
    final progress = planProvider?.progress;

    return GestureDetector(
        onTap: () {
          Navigator.restorablePushNamed(context, SchedulePage.routeName,
              arguments: plan.id);
        },
        child: Card(
            color: const Color(0xFFD6D8DA),
            child: Stack(
              children: [
                Positioned(
                    left: 10,
                    top: 10,
                    child: Row(children: [
                      const Icon(
                        Icons.hourglass_empty,
                        color: Colors.black54,
                        size: 56,
                        shadows: [
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
                              backgroundColor: Colors.black12,
                              value: progress,
                            ))
                    ])),
              ],
            )));
  }
}
