import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nwt_reading/src/plans/presentations/plan_edit_dialog.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';

class SchedulePage extends ConsumerWidget {
  const SchedulePage({super.key});

  static const routeName = '/schedule';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    final plan = ref.watch(planFamilyEdit(planId));
    final scheduleProvider =
        ref.watch(scheduleFamily(plan.scheduleKey)).valueOrNull;
    final progress = scheduleProvider?.getProgress(plan.bookmark);
    final schedule = scheduleProvider?.schedule;
    final scheduleGrid =
        schedule == null ? [] : buildScheduleGrid(planId, schedule);
    if (schedule == null) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => Navigator.pop(context));
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(plan.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => PlanEditDialog(planId),
              ),
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

  static List<DayCard> buildScheduleGrid(String planId, Schedule schedule) =>
      schedule.days
          .asMap()
          .entries
          .map((day) => DayCard(
              key: Key('day-${day.key}'),
              planId: planId,
              day: day.value,
              dayIndex: day.key))
          .toList();
}
