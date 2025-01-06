import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedule.dart';
import 'package:package_info_plus/package_info_plus.dart';

const seenWhatsNewVersionPreferenceKey = 'seenWhatsNewVersionSetting';
const themeModePreferenceKey = 'themeModeSetting';
const legacyExportPreferenceKey = 'legacyExport';
const plansPreferenceKey = 'plans';

Future<Map<String, String>> getWhatsNewSeenPreference() async => {
      seenWhatsNewVersionPreferenceKey:
          (await PackageInfo.fromPlatform()).version
    };

final Plans testPlans = Plans([
  Plan(
      id: '5aa4de9e-036b-42cd-8bcb-a92cae46db27',
      scheduleKey: ScheduleKey(
          type: ScheduleType.chronological,
          duration: ScheduleDuration.y1,
          version: '1.0'),
      language: 'en',
      bookmark: Bookmark(dayIndex: 75, sectionIndex: 0),
      withTargetDate: true,
      showEvents: true,
      showLocations: true),
  Plan(
      id: '0da6b8a7-ccd4-4270-8058-9e30a3f55ceb',
      name: 'Written',
      scheduleKey: ScheduleKey(
          type: ScheduleType.written,
          duration: ScheduleDuration.y1,
          version: '1.0'),
      language: 'de',
      bookmark: Bookmark(dayIndex: 0, sectionIndex: -1),
      withTargetDate: false,
      showEvents: false,
      showLocations: false),
  Plan(
      id: '2dab49f3-aecf-4aba-9e91-d75c297d4b7e',
      name: 'Canonical',
      scheduleKey: ScheduleKey(
          type: ScheduleType.canonical,
          duration: ScheduleDuration.y1,
          version: '1.0'),
      language: 'ro',
      bookmark: Bookmark(dayIndex: 364, sectionIndex: 1),
      lastDate: DateTime(2024, 11, 21),
      withTargetDate: true,
      showEvents: true,
      showLocations: true),
  Plan(
      id: 'e37bf9df-077a-49db-adcb-d56384906103',
      name: 'Chronological',
      scheduleKey: ScheduleKey(
          type: ScheduleType.chronological,
          duration: ScheduleDuration.m6,
          version: '1.0'),
      language: 'en',
      bookmark: Bookmark(dayIndex: 182, sectionIndex: 1),
      withTargetDate: true,
      showEvents: true,
      showLocations: true)
]);

const List<String> testPlansSerialized = [
  '{"id":"5aa4de9e-036b-42cd-8bcb-a92cae46db27","scheduleKey":{"type":0,"duration":2,"version":"1.0"},"language":"en","bookmark":{"dayIndex":75,"sectionIndex":0},"withTargetDate":true,"showEvents":true,"showLocations":true}',
  '{"id":"0da6b8a7-ccd4-4270-8058-9e30a3f55ceb","name":"Written","scheduleKey":{"type":2,"duration":2,"version":"1.0"},"language":"de","bookmark":{"dayIndex":0,"sectionIndex":-1},"withTargetDate":false,"showEvents":false,"showLocations":false}',
  '{"id":"2dab49f3-aecf-4aba-9e91-d75c297d4b7e","name":"Canonical","scheduleKey":{"type":1,"duration":2,"version":"1.0"},"language":"ro","bookmark":{"dayIndex":364,"sectionIndex":1},"lastDate":"2024-11-21T00:00:00.000","withTargetDate":true,"showEvents":true,"showLocations":true}',
  '{"id":"e37bf9df-077a-49db-adcb-d56384906103","name":"Chronological","scheduleKey":{"type":0,"duration":1,"version":"1.0"},"language":"en","bookmark":{"dayIndex":182,"sectionIndex":1},"withTargetDate":true,"showEvents":true,"showLocations":true}'
];

final testPlansPreferences = {
  plansPreferenceKey: testPlansSerialized,
  legacyExportPreferenceKey:
      '{ "version": 7, "schedules": { "sequential": {}, "written": {}, "chronological": {} }, "currentSchedule": "sequential" }'
};

class LegacyExport {
  const LegacyExport({
    required this.preferences,
    required this.plans,
  });

  final Map<String, String> preferences;
  final Plans plans;
}

final List<LegacyExport> testLegacyExports = [
  LegacyExport(
      preferences: {legacyExportPreferenceKey: 'this is not JSON'},
      plans: Plans(const [])),
  LegacyExport(
      preferences: {
        legacyExportPreferenceKey:
            '{ "version": 7, "schedules": { "sequential": {}, "written": {}, "chronological": {} }, "currentSchedule": "sequential" }'
      },
      plans: Plans(const [
        Plan(
            id: '',
            scheduleKey: ScheduleKey(
                type: ScheduleType.canonical,
                duration: ScheduleDuration.y1,
                version: '1.0'),
            language: 'en',
            bookmark: Bookmark(dayIndex: 0, sectionIndex: -1),
            withTargetDate: true,
            showEvents: true,
            showLocations: false),
      ])),
  LegacyExport(
      preferences: {
        legacyExportPreferenceKey:
            '{ "version": 7, "schedules": { "sequential": {}, "written": {}, "chronological": { "readIndex": "104", "endDate": "2024-01-27T00:00:00.000Z" } }, "currentSchedule": "chronological" }'
      },
      plans: Plans([
        Plan(
            id: '',
            scheduleKey: const ScheduleKey(
                type: ScheduleType.chronological,
                duration: ScheduleDuration.y1,
                version: '1.0'),
            language: 'en',
            bookmark: const Bookmark(dayIndex: 104, sectionIndex: -1),
            targetDate: DateTime.utc(2024, 1, 27),
            withTargetDate: true,
            showEvents: true,
            showLocations: false),
      ])),
  LegacyExport(
      preferences: {
        legacyExportPreferenceKey:
            '{ "version": 7, "schedules": { "sequential": {}, "written": {}, "chronological": { "duration": "1y", "readIndex": "26", "endDate": "2025-04-16T00:00:00.000Z" } }, "currentSchedule": "chronological", "language": "ro", "readingLanguage": "de", "withEndDate": true, "showEvents": true, "showLocations": true }'
      },
      plans: Plans([
        Plan(
            id: '3266e6fd-ce74-48f0-a491-da086a7704c7',
            scheduleKey: const ScheduleKey(
                type: ScheduleType.chronological,
                duration: ScheduleDuration.y1,
                version: '1.0'),
            language: 'de',
            bookmark: const Bookmark(dayIndex: 26, sectionIndex: -1),
            targetDate: DateTime.utc(2025, 4, 16),
            withTargetDate: true,
            showEvents: true,
            showLocations: true),
      ])),
];
