import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/presentations/plan_edit_dialog.dart';
import 'package:nwt_reading/src/plans/stories/plan_edit_story.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';
import 'package:nwt_reading/src/schedules/presentations/day_card.dart';

class SchedulePage extends ConsumerStatefulWidget {
  const SchedulePage({super.key});

  static const routeName = '/schedule';

  @override
  ConsumerState<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends ConsumerState<SchedulePage> {
  int topDayIndex = 0;
  ScheduleKey? scheduleKey;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    final bookmark = ref.read(planEditFamilyNotifier(planId)).bookmark;
    resetTopDayIndex(bookmark);
  }

  void resetTopDayIndex(bookmark) => setState(() => topDayIndex = max(0,
      bookmark.sectionIndex < 0 ? bookmark.dayIndex - 1 : bookmark.dayIndex));

  @override
  Widget build(BuildContext context) {
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    final plan = ref.watch(planEditFamilyNotifier(planId));
    final scheduleProvider =
        ref.watch(scheduleFamily(plan.scheduleKey)).valueOrNull;
    final progress = scheduleProvider?.getProgress(plan.bookmark);
    final schedule = scheduleProvider?.schedule;
    const Key centerKey = ValueKey<String>('today');
    final controller = ScrollController();
    if (scheduleKey != plan.scheduleKey) {
      scheduleKey = plan.scheduleKey;
      resetTopDayIndex(plan.bookmark);
    }

    DayCard? scheduleListBuilder(index) {
      final day = schedule?.days[index];

      return day == null
          ? null
          : DayCard(
              key: Key('day-$index'),
              planId: planId,
              day: day,
              dayIndex: index);
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
                    child: CustomScrollView(
                      controller: controller,
                      center: centerKey,
                      slivers: <Widget>[
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                              (BuildContext context, int index) =>
                                  scheduleListBuilder(topDayIndex - 1 - index),
                              childCount: topDayIndex),
                        ),
                        SliverList(
                          key: centerKey,
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) =>
                                scheduleListBuilder(topDayIndex + index),
                            childCount: schedule.days.length - topDayIndex,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          tooltip: AppLocalizations.of(context)!.goToBookmarkTooltip,
          onPressed: () {
            resetTopDayIndex(plan.bookmark);
            controller.jumpTo(0.0);
          },
          child: const Icon(Icons.bookmark),
        ));
  }
}
