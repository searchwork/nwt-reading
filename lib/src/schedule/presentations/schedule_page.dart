import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedule/entities/schedules.dart';
import 'package:nwt_reading/src/schedule/presentations/day_card.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  static const routeName = '/schedule';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    final planProvider = ref.watch(plansFamilyProvider(planId)).valueOrNull;
    final plan = planProvider?.plan;
    final progress = planProvider?.progress;
    final schedule = planProvider?.schedule;
    final scheduleGrid =
        schedule == null ? [] : _buildScheduleGrid(planId, schedule);
    if (schedule == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Navigator.pop(context));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(plan?.name ?? 'Reading Schedule'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () =>
                  ref.read(plansProvider.notifier).removePlan(planId),
            ),
          ],
        ),
        body: schedule == null
            ? null
            : Column(
                children: [
                  if (progress != null)
                    LinearProgressIndicator(value: progress),
                  Flexible(
                    child: AlignedGridView.extent(
                      padding: const EdgeInsets.all(20),
                      restorationId: 'scheduleView',
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      maxCrossAxisExtent: 600,
                      itemCount: scheduleGrid.length,
                      itemBuilder: (context, index) => scheduleGrid[index],
                    ),
                  ),
                ],
              ));
  }
}

List<DayCard> _buildScheduleGrid(String planId, Schedule schedule) =>
    schedule.days
        .asMap()
        .entries
        .map((day) => DayCard(
            key: Key('day-${day.key}'),
            planId: planId,
            day: day.value,
            dayIndex: day.key))
        .toList();
