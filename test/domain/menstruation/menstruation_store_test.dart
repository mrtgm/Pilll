import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:pilll/components/organisms/calendar/band/calendar_band_function.dart';
import 'package:pilll/components/organisms/calendar/band/calendar_band_model.dart';
import 'package:pilll/domain/menstruation/menstruation_card_state.codegen.dart';
import 'package:pilll/domain/menstruation/menstruation_state.codegen.dart';
import 'package:pilll/entity/menstruation.codegen.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/service/day.dart';
import 'package:pilll/domain/menstruation/menstruation_page_state_notifier.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/delay.dart';
import '../../helper/mock.mocks.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group("#cardState", () {
    test(
      "if latestMenstruation is into today, when return card state of begining about menstruation ",
      () async {
        final originalTodayRepository = todayRepository;
        final mockTodayRepository = MockTodayService();
        todayRepository = mockTodayRepository;
        final today = DateTime(2021, 04, 29);
        when(mockTodayRepository.now()).thenReturn(today);
        when(mockTodayRepository.now()).thenReturn(today);
        addTearDown(() {
          todayRepository = originalTodayRepository;
        });

        final pillSheetGroup =
            PillSheetGroup(pillSheetIDs: [], pillSheets: [], createdAt: now());
        final setting = const Setting(
          pillSheetTypes: [PillSheetType.pillsheet_21],
          pillNumberForFromMenstruation: 22,
          durationMenstruation: 3,
          reminderTimes: [],
          isOnReminder: true,
        );
        final menstruations = [
          Menstruation(
            beginDate: DateTime(2021, 04, 28),
            endDate: DateTime(2021, 04, 30),
            createdAt: DateTime(2021, 04, 28),
          ),
          Menstruation(
            beginDate: DateTime(2021, 03, 28),
            endDate: DateTime(2021, 03, 30),
            createdAt: DateTime(2021, 03, 28),
          ),
        ];
        final calendarScheduledMenstruationBandModels =
            scheduledOrInTheMiddleMenstruationDateRanges(
                    pillSheetGroup, setting, menstruations, 12)
                .map((e) =>
                    CalendarScheduledMenstruationBandModel(e.begin, e.end))
                .toList();
        final calendarMenstruationBandModels =
            menstruations.map((e) => CalendarMenstruationBandModel(e)).toList();
        final calendarNextPillSheetBandModels =
            nextPillSheetDateRanges(pillSheetGroup, 12)
                .map((e) => CalendarNextPillSheetBandModel(e.begin, e.end))
                .toList();
        final store = MenstruationPageStateNotifier(
          asyncAction: MockMenstruationPageAsyncAction(),
          initialState: AsyncValue.data(
            MenstruationState(
              currentCalendarPageIndex: todayCalendarPageIndex,
              todayCalendarPageIndex: todayCalendarPageIndex,
              diariesForAround90Days: [],
              menstruations: menstruations,
              premiumAndTrial: MockPremiumAndTrial(),
              setting: setting,
              latestPillSheetGroup: pillSheetGroup,
              calendarMenstruationBandModels: calendarMenstruationBandModels,
              calendarScheduledMenstruationBandModels:
                  calendarScheduledMenstruationBandModels,
              calendarNextPillSheetBandModels: calendarNextPillSheetBandModels,
            ),
          ),
        );

        await waitForResetStoreState();
        final actual = store.cardState();

        expect(
            actual,
            MenstruationCardState(
                title: "生理開始日",
                scheduleDate: DateTime(2021, 04, 28),
                countdownString: "2日目"));
      },
    );
    test(
      "if latestMenstruation is out of duration and latest pill sheet is null",
      () async {
        final originalTodayRepository = todayRepository;
        final mockTodayRepository = MockTodayService();
        todayRepository = mockTodayRepository;
        final today = DateTime(2021, 04, 29);
        when(mockTodayRepository.now()).thenReturn(today);
        when(mockTodayRepository.now()).thenReturn(today);
        addTearDown(() {
          todayRepository = originalTodayRepository;
        });

        final pillSheetGroup =
            PillSheetGroup(pillSheetIDs: [], pillSheets: [], createdAt: now());
        final setting = const Setting(
          pillSheetTypes: [PillSheetType.pillsheet_21],
          pillNumberForFromMenstruation: 22,
          durationMenstruation: 3,
          reminderTimes: [],
          isOnReminder: true,
        );
        final menstruations = [
          Menstruation(
            beginDate: DateTime(2021, 03, 28),
            endDate: DateTime(2021, 03, 30),
            createdAt: DateTime(2021, 03, 28),
          ),
        ];
        final calendarScheduledMenstruationBandModels =
            scheduledOrInTheMiddleMenstruationDateRanges(
                    pillSheetGroup, setting, menstruations, 12)
                .map((e) =>
                    CalendarScheduledMenstruationBandModel(e.begin, e.end))
                .toList();
        final calendarMenstruationBandModels =
            menstruations.map((e) => CalendarMenstruationBandModel(e)).toList();
        final calendarNextPillSheetBandModels =
            nextPillSheetDateRanges(pillSheetGroup, 12)
                .map((e) => CalendarNextPillSheetBandModel(e.begin, e.end))
                .toList();
        final store = MenstruationPageStateNotifier(
          asyncAction: MockMenstruationPageAsyncAction(),
          initialState: AsyncValue.data(
            MenstruationState(
              currentCalendarPageIndex: todayCalendarPageIndex,
              todayCalendarPageIndex: todayCalendarPageIndex,
              diariesForAround90Days: [],
              menstruations: menstruations,
              premiumAndTrial: MockPremiumAndTrial(),
              setting: setting,
              latestPillSheetGroup: pillSheetGroup,
              calendarMenstruationBandModels: calendarMenstruationBandModels,
              calendarScheduledMenstruationBandModels:
                  calendarScheduledMenstruationBandModels,
              calendarNextPillSheetBandModels: calendarNextPillSheetBandModels,
            ),
          ),
        );

        await waitForResetStoreState();
        final actual = store.cardState();

        expect(actual, null);
      },
    );

    test(
      "if latest pillsheet.beginingDate + totalCount < today, when return schedueld card state",
      () async {
        final originalTodayRepository = todayRepository;
        final mockTodayRepository = MockTodayService();
        todayRepository = mockTodayRepository;
        final today = DateTime(2021, 04, 29);
        when(mockTodayRepository.now()).thenReturn(today);
        when(mockTodayRepository.now()).thenReturn(today);
        addTearDown(() {
          todayRepository = originalTodayRepository;
        });

        final pillSheetGroup = PillSheetGroup(
          pillSheetIDs: ["1"],
          pillSheets: [
            PillSheet(
              typeInfo: PillSheetType.pillsheet_21.typeInfo,
              beginingDate: DateTime(2021, 04, 22),
            ),
          ],
          createdAt: now(),
        );
        final setting = const Setting(
          pillSheetTypes: [PillSheetType.pillsheet_21],
          pillNumberForFromMenstruation: 22,
          durationMenstruation: 3,
          reminderTimes: [],
          isOnReminder: true,
        );
        final calendarScheduledMenstruationBandModels =
            scheduledOrInTheMiddleMenstruationDateRanges(
                    pillSheetGroup, setting, [], 12)
                .map((e) =>
                    CalendarScheduledMenstruationBandModel(e.begin, e.end))
                .toList();
        final calendarNextPillSheetBandModels =
            nextPillSheetDateRanges(pillSheetGroup, 12)
                .map((e) => CalendarNextPillSheetBandModel(e.begin, e.end))
                .toList();
        final store = MenstruationPageStateNotifier(
          asyncAction: MockMenstruationPageAsyncAction(),
          initialState: AsyncValue.data(
            MenstruationState(
              currentCalendarPageIndex: todayCalendarPageIndex,
              todayCalendarPageIndex: todayCalendarPageIndex,
              diariesForAround90Days: [],
              menstruations: [],
              premiumAndTrial: MockPremiumAndTrial(),
              setting: setting,
              latestPillSheetGroup: pillSheetGroup,
              calendarMenstruationBandModels: [],
              calendarScheduledMenstruationBandModels:
                  calendarScheduledMenstruationBandModels,
              calendarNextPillSheetBandModels: calendarNextPillSheetBandModels,
            ),
          ),
        );

        await waitForResetStoreState();
        final actual = store.cardState();

        expect(
            actual,
            MenstruationCardState(
                title: "生理予定日",
                scheduleDate: DateTime(2021, 05, 13),
                countdownString: "あと14日"));
      },
    );
    test(
      "if todayPillNumber > setting.pillNumberForFromMenstruation, when return card state of into duration for schedueld menstruation",
      () async {
        final originalTodayRepository = todayRepository;
        final mockTodayRepository = MockTodayService();
        todayRepository = mockTodayRepository;
        final today = DateTime(2021, 04, 29);
        when(mockTodayRepository.now()).thenReturn(today);
        when(mockTodayRepository.now()).thenReturn(today);
        addTearDown(() {
          todayRepository = originalTodayRepository;
        });

        final pillSheetGroup = PillSheetGroup(
          pillSheetIDs: ["1"],
          pillSheets: [
            PillSheet(
              typeInfo: PillSheetType.pillsheet_21.typeInfo,
              beginingDate: DateTime(2021, 04, 07),
            ),
          ],
          createdAt: now(),
        );
        final setting = const Setting(
          pillSheetTypes: [PillSheetType.pillsheet_21],
          pillNumberForFromMenstruation: 22,
          durationMenstruation: 3,
          reminderTimes: [],
          isOnReminder: true,
        );
        final menstruations = [
          Menstruation(
            beginDate: DateTime(2021, 03, 28),
            endDate: DateTime(2021, 03, 30),
            createdAt: DateTime(2021, 03, 28),
          ),
        ];
        final calendarScheduledMenstruationBandModels =
            scheduledOrInTheMiddleMenstruationDateRanges(
                    pillSheetGroup, setting, menstruations, 12)
                .map((e) =>
                    CalendarScheduledMenstruationBandModel(e.begin, e.end))
                .toList();
        final calendarMenstruationBandModels =
            menstruations.map((e) => CalendarMenstruationBandModel(e)).toList();
        final calendarNextPillSheetBandModels =
            nextPillSheetDateRanges(pillSheetGroup, 12)
                .map((e) => CalendarNextPillSheetBandModel(e.begin, e.end))
                .toList();
        final store = MenstruationPageStateNotifier(
          asyncAction: MockMenstruationPageAsyncAction(),
          initialState: AsyncValue.data(
            MenstruationState(
              currentCalendarPageIndex: todayCalendarPageIndex,
              todayCalendarPageIndex: todayCalendarPageIndex,
              diariesForAround90Days: [],
              menstruations: menstruations,
              premiumAndTrial: MockPremiumAndTrial(),
              setting: setting,
              latestPillSheetGroup: pillSheetGroup,
              calendarMenstruationBandModels: calendarMenstruationBandModels,
              calendarScheduledMenstruationBandModels:
                  calendarScheduledMenstruationBandModels,
              calendarNextPillSheetBandModels: calendarNextPillSheetBandModels,
            ),
          ),
        );

        await waitForResetStoreState();
        final actual = store.cardState();

        expect(
          actual,
          MenstruationCardState(
              title: "生理予定日",
              scheduleDate: DateTime(2021, 04, 28),
              countdownString: "生理予定：2日目"),
        );
      },
    );
  });
}
