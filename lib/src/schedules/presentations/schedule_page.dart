import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/presentations/plan_edit_dialog.dart';
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

  void resetTopDayIndex(Bookmark? bookmark) =>
      setState(() => topDayIndex = bookmark == null
          ? 0
          : max(
              0,
              bookmark.sectionIndex < 0
                  ? bookmark.dayIndex - 1
                  : bookmark.dayIndex));

  @override
  Widget build(BuildContext context) {
    final planId = ModalRoute.of(context)!.settings.arguments as String;
    final plan = ref.watch(planProviderFamily(planId));
    final planNotifier = ref.read(planProviderFamily(planId).notifier);
    final schedule =
        ref.watch(scheduleProviderFamily(plan.scheduleKey)).valueOrNull;
    final progress = planNotifier.getProgress();
    const Key centerKey = ValueKey<String>('today');
    final controller = ScrollController();
    final deviationDays = planNotifier.getDeviationDays();
    final todayTargetIndex = planNotifier.todayTargetIndex();
    final badgeColor = deviationDays >= 0 ? Colors.green : Colors.red;
    if (scheduleKey != plan.scheduleKey) {
      scheduleKey = plan.scheduleKey;
      resetTopDayIndex(plan.bookmark);
    }

    Widget? scheduleListBuilder(int index) {
      final day = schedule?.days[index];
      final isCurrentDay = plan.bookmark.dayIndex == index;
      final isTargetDay = todayTargetIndex == index;
      final dividerColor = isCurrentDay ? Colors.blue : badgeColor;
      final dayCard = day == null
          ? null
          : DayCard(
              key: Key('day-$index'),
              planId: planId,
              day: day,
              dayIndex: index);

      return dayCard != null && (isCurrentDay || isTargetDay)
          ? Column(
              children: [
                Container(
                    padding: const EdgeInsets.only(left: 2, right: 10),
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: dividerColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                          child: Divider(
                        key: Key(isCurrentDay ? 'current-day' : 'target-day'),
                        color: dividerColor,
                        thickness: 3,
                      ))
                    ])),
                dayCard,
              ],
            )
          : dayCard;
    }

    return Scaffold(
        appBar: AppBar(
          title: deviationDays == 0
              ? Text(plan.name)
              : Badge(
                  label: Text('${deviationDays.abs()}'),
                  backgroundColor: badgeColor,
                  offset: Offset(23, -5),
                  child: Text(plan.name),
                ),
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
          tooltip:
              AppLocalizations.of(context).schedulePageJumpToBookmarkTooltip,
          onPressed: () {
            resetTopDayIndex(plan.bookmark);
            controller.jumpTo(0.0);
          },
          child: const Icon(Icons.bookmark),
        ));
  }
}
