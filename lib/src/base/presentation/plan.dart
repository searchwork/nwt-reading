import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nwt_reading/src/localization/app_localizations_getter.dart';
import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';

String getPlanName(BuildContext context, Plan plan) =>
    plan.name ??
    '${toBeginningOfSentenceCase(
      switch (plan.scheduleKey.type) {
        ScheduleType.chronological =>
          context.loc.planEditPageChronologicalLabel,
        ScheduleType.canonical => context.loc.planEditPageCanonicalLabel,
        ScheduleType.written => context.loc.planEditPageAsWrittenLabel,
      },
    )} ${switch (plan.scheduleKey.duration) {
      ScheduleDuration.m3 => context.loc.planEditPageMonthsLabel(3),
      ScheduleDuration.m6 => context.loc.planEditPageMonthsLabel(6),
      ScheduleDuration.y1 => context.loc.planEditPageYearsLabel(1),
      ScheduleDuration.y2 => context.loc.planEditPageYearsLabel(2),
      ScheduleDuration.y4 => context.loc.planEditPageYearsLabel(4),
    }}';
