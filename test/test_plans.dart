import 'package:nwt_reading/src/plans/entities/plan.dart';
import 'package:nwt_reading/src/plans/entities/plans.dart';
import 'package:nwt_reading/src/schedules/entities/schedules.dart';

const plansPreferenceKey = 'plans';

final Plans testPlans = Plans(const [
  Plan(
      id: "5aa4de9e-036b-42cd-8bcb-a92cae46db27",
      name: "Chronological",
      scheduleKey: ScheduleKey(
          type: ScheduleType.chronological,
          duration: ScheduleDuration.y1,
          version: "1.0"),
      language: "E",
      bookmark: Bookmark(dayIndex: 0, sectionIndex: -1),
      withEndDate: true,
      showEvents: true,
      showLocations: true),
  Plan(
      id: "0da6b8a7-ccd4-4270-8058-9e30a3f55ceb",
      name: "Sequential",
      scheduleKey: ScheduleKey(
          type: ScheduleType.sequential,
          duration: ScheduleDuration.y1,
          version: "1.0"),
      language: "X",
      bookmark: Bookmark(dayIndex: 115, sectionIndex: 0),
      withEndDate: true,
      showEvents: true,
      showLocations: true),
  Plan(
      id: "2dab49f3-aecf-4aba-9e91-d75c297d4b7e",
      name: "Written",
      scheduleKey: ScheduleKey(
          type: ScheduleType.written,
          duration: ScheduleDuration.y1,
          version: "1.0"),
      language: "M",
      bookmark: Bookmark(dayIndex: 364, sectionIndex: 1),
      withEndDate: true,
      showEvents: true,
      showLocations: true)
]);

const List<String> testPlansSerialized = [
  '{"id":"5aa4de9e-036b-42cd-8bcb-a92cae46db27","name":"Chronological","scheduleKey":{"type":0,"duration":2,"version":"1.0"},"language":"E","bookmark":{"dayIndex":0,"sectionIndex":-1},"withEndDate":true,"showEvents":true,"showLocations":true}',
  '{"id":"0da6b8a7-ccd4-4270-8058-9e30a3f55ceb","name":"Sequential","scheduleKey":{"type":1,"duration":2,"version":"1.0"},"language":"X","bookmark":{"dayIndex":115,"sectionIndex":0},"withEndDate":true,"showEvents":true,"showLocations":true}',
  '{"id":"2dab49f3-aecf-4aba-9e91-d75c297d4b7e","name":"Written","scheduleKey":{"type":2,"duration":2,"version":"1.0"},"language":"M","bookmark":{"dayIndex":364,"sectionIndex":1},"withEndDate":true,"showEvents":true,"showLocations":true}'
];

final testPlansPreferences = {plansPreferenceKey: testPlansSerialized};
