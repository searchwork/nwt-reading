import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/test_data.dart';
import 'base/entities_initialized.dart';
import 'plans/add.dart';
import 'plans/cancel_edit.dart';
import 'plans/cancel_new.dart';
import 'plans/change_plan_duration.dart';
import 'plans/change_plan_events.dart';
import 'plans/change_plan_language.dart';
import 'plans/change_plan_locations.dart';
import 'plans/change_plan_name.dart';
import 'plans/change_plan_with_target_date.dart';
import 'plans/delete.dart';
import 'plans/finished_plans.dart';
import 'plans/no_plans.dart';
import 'schedule/bookmark_button.dart';
import 'schedule/check_day.dart';
import 'schedule/continue_notice.dart';
import 'schedule/return_to_plans.dart';
import 'schedule/show.dart';
import 'schedule/show_deviations.dart';
import 'schedule/starts_at_bookmark.dart';
import 'schedule/uncheck_day.dart';
import 'settings/settings.dart';
import 'settled_tester.dart';
import 'whats_new/got_it.dart';
import 'whats_new/later.dart';

Future<ProviderContainer> getDefaultProviderContainer(
        WidgetTester tester) async =>
    SettledTester(tester, sharedPreferences: {
      ...testPlansPreferences,
      ...await getWhatsNewSeenPreference()
    }).providerContainer;

void main() async {
  WidgetController.hitTestWarningShouldBeFatal = true;

  group('Base', () {
    testEntitiesInitialized();
  });

  group('Plans', () {
    testNoPlans();
    testAddPlans();
    testCancelNew();
    testFinishedPlans();
    testChangePlanName();
    testChangePlanDuration();
    testChangePlanLanguage();
    testChangePlanWithTargetDate();
    testChangePlanEvents();
    testChangePlanLocations();
    testCancelEdit();
    testDelete();
  });

  group('Whats New', () {
    testLaterOnWhatsNew();
    testGotItOnWhatsNew();
  });

  group('Schedules', () {
    testShowSchedule();
    testContinueNotice();
    testReturnToPlans();
    testStartsAtBookmark();
    testCheckDay();
    testUncheckDay();
    testShowDeviations();
    testBookmarkButton();
  });

  group('Settings', () {
    testSettings();
  });
}
