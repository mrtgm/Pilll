import 'package:pilll/database/batch.dart';
import 'package:pilll/domain/initial_setting/initial_setting_state.dart';
import 'package:pilll/domain/initial_setting/initial_setting_store.dart';
import 'package:pilll/entity/initial_setting_pill_category_type.dart';
import 'package:pilll/entity/pill_sheet.dart';
import 'package:pilll/entity/pill_sheet_group.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pilll/entity/setting.dart';
import 'package:pilll/service/auth.dart';
import 'package:pilll/service/day.dart';
import 'package:pilll/service/pill_sheet.dart';
import 'package:pilll/service/pill_sheet_group.dart';
import 'package:pilll/service/pill_sheet_modified_history.dart';
import 'package:pilll/service/setting.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helper/mock.mocks.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });
  group("#selectedPillCategoryType", () {
    test("when first selected", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
      ]);
    });
    test("overwrite pill sheet type", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
      ]);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_jemina);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_21,
      ]);
    });

    test("reset todayPillNumber", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);
      // ignore: invalid_use_of_protected_member
      store.state = store.state.copyWith(
          todayPillNumber: const InitialSettingTodayPillNumber(
              pageIndex: 0, pillNumberIntoPillSheet: 28));
      expect(
          container.read(initialSettingStateProvider).todayPillNumber,
          const InitialSettingTodayPillNumber(
              pageIndex: 0, pillNumberIntoPillSheet: 28));

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_jemina);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_21,
      ]);
      expect(container.read(initialSettingStateProvider).todayPillNumber, null);
    });
  });
  group("#addPillSheetType", () {
    test("add new one", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      store.addPillSheetType(PillSheetType.pillsheet_28_0);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
      ]);
    });
  });
  group("#changePillSheetType", () {
    test("replace with index", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      store.addPillSheetType(PillSheetType.pillsheet_28_0);
      store.changePillSheetType(1, PillSheetType.pillsheet_24_0);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_24_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
      ]);
    });
  });
  group("#removePillSheetType", () {
    test("remove with index", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      store.addPillSheetType(PillSheetType.pillsheet_28_0);
      store.changePillSheetType(1, PillSheetType.pillsheet_24_0);
      store.removePillSheetType(0);
      expect(container.read(initialSettingStateProvider).pillSheetTypes, [
        PillSheetType.pillsheet_24_0,
        PillSheetType.pillsheet_28_0,
        PillSheetType.pillsheet_28_0,
      ]);
    });
  });
  group("#setReminderTime", () {
    test("replace default reminderTime", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.setReminderTime(index: 0, hour: 22, minute: 10);
      expect(container.read(initialSettingStateProvider).reminderTimes, [
        const ReminderTime(hour: 22, minute: 10),
        const ReminderTime(hour: 22, minute: 0)
      ]);
    });
    test("add reminderTime", () {
      final batchFactory = MockBatchFactory();
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());
      final settingService = MockSettingService();
      final pillSheetService = MockPillSheetService();
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      final pillSheetGroupService = MockPillSheetGroupService();

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.setReminderTime(index: 2, hour: 22, minute: 10);
      expect(container.read(initialSettingStateProvider).reminderTimes, [
        const ReminderTime(hour: 21, minute: 0),
        const ReminderTime(hour: 22, minute: 0),
        const ReminderTime(hour: 22, minute: 10)
      ]);
    });
  });
  group("#register", () {
    test("state.pillSheetTypes has one pillSheetType", () {
      var mockTodayRepository = MockTodayService();
      final _today = DateTime.parse("2020-09-19");
      todayRepository = mockTodayRepository;
      when(mockTodayRepository.today()).thenReturn(_today);
      when(mockTodayRepository.now()).thenReturn(_today);

      final batchFactory = MockBatchFactory();
      final batch = MockWriteBatch();
      when(batchFactory.batch()).thenReturn(batch);
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());

      final pillSheet = PillSheet(
          typeInfo: PillSheetType.pillsheet_21.typeInfo, beginingDate: _today);
      final pillSheetService = MockPillSheetService();
      when(pillSheetService.register(batch, [pillSheet]))
          .thenReturn([pillSheet.copyWith(id: "sheet_id")]);

      final pillSheetGroup = PillSheetGroup(
          pillSheetIDs: ["sheet_id"],
          pillSheets: [pillSheet.copyWith(id: "sheet_id")],
          createdAt: now());
      final pillSheetGroupService = MockPillSheetGroupService();
      when(pillSheetGroupService.register(batch, pillSheetGroup))
          .thenReturn(pillSheetGroup.copyWith(id: "group_id"));

      final history = PillSheetModifiedHistoryServiceActionFactory
          .createCreatedPillSheetAction(
              pillSheetGroupID: "group_id", pillSheetIDs: ["sheet_id"]);
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      when(pillSheetModifiedHistoryService.add(batch, history))
          .thenReturn(null);

      final setting = const Setting(
        pillNumberForFromMenstruation: 24,
        durationMenstruation: 4,
        isOnReminder: true,
        reminderTimes: [
          ReminderTime(hour: 21, minute: 20),
          ReminderTime(hour: 22, minute: 0)
        ],
        pillSheetTypes: [PillSheetType.pillsheet_21],
      );
      final settingService = MockSettingService();
      when(settingService.updateWithBatch(batch, setting)).thenReturn(null);

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_21_rest_7);
      store.removePillSheetType(1);
      store.removePillSheetType(1);
      store.setTodayPillNumber(pageIndex: 0, pillNumberIntoPillSheet: 1);
      store.setReminderTime(index: 0, hour: 21, minute: 20);

      store.register();
    });
    test("state.pillSheetTypes has two pillSheetType", () {
      var mockTodayRepository = MockTodayService();
      final _today = DateTime.parse("2020-09-19");
      todayRepository = mockTodayRepository;
      when(mockTodayRepository.today()).thenReturn(_today);
      when(mockTodayRepository.now()).thenReturn(_today);

      final batchFactory = MockBatchFactory();
      final batch = MockWriteBatch();
      when(batchFactory.batch()).thenReturn(batch);
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());

      final pillSheet = PillSheet(
        typeInfo: PillSheetType.pillsheet_28_0.typeInfo,
        beginingDate: _today.subtract(
          const Duration(days: 28),
        ),
        groupIndex: 0,
        lastTakenDate: DateTime.parse("2020-09-18"),
      );
      final pillSheet2 = PillSheet(
        typeInfo: PillSheetType.pillsheet_21.typeInfo,
        beginingDate: _today,
        lastTakenDate: _today.subtract(const Duration(days: 1)),
        groupIndex: 1,
      );
      final pillSheetService = MockPillSheetService();

      when(pillSheetService.register(batch, [pillSheet, pillSheet2]))
          .thenReturn([
        pillSheet.copyWith(id: "sheet_id"),
        pillSheet2.copyWith(id: "sheet_id2")
      ]);

      final pillSheetGroup = PillSheetGroup(
        pillSheetIDs: ["sheet_id", "sheet_id2"],
        pillSheets: [
          pillSheet.copyWith(id: "sheet_id"),
          pillSheet2.copyWith(id: "sheet_id2"),
        ],
        createdAt: now(),
      );
      final pillSheetGroupService = MockPillSheetGroupService();
      when(pillSheetGroupService.register(batch, pillSheetGroup))
          .thenReturn(pillSheetGroup.copyWith(id: "group_id"));

      final history = PillSheetModifiedHistoryServiceActionFactory
          .createCreatedPillSheetAction(
              pillSheetGroupID: "group_id",
              pillSheetIDs: ["sheet_id", "sheet_id2"]);
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      when(pillSheetModifiedHistoryService.add(batch, history))
          .thenReturn(null);

      final setting = const Setting(
        pillSheetAppearanceMode: PillSheetAppearanceMode.sequential,
        pillNumberForFromMenstruation: 52,
        durationMenstruation: 4,
        isOnReminder: true,
        reminderTimes: [
          ReminderTime(hour: 21, minute: 20),
          ReminderTime(hour: 22, minute: 0)
        ],
        pillSheetTypes: [
          PillSheetType.pillsheet_28_0,
          PillSheetType.pillsheet_21
        ],
      );
      final settingService = MockSettingService();
      when(settingService.updateWithBatch(batch, setting)).thenReturn(null);

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_yaz_flex);
      store.addPillSheetType(PillSheetType.pillsheet_21);
      store.removePillSheetType(1);
      store.removePillSheetType(1);
      store.setTodayPillNumber(pageIndex: 1, pillNumberIntoPillSheet: 1);
      store.setReminderTime(index: 0, hour: 21, minute: 20);

      store.register();
    });

    // ref: https://github.com/bannzai/Pilll/pull/534
    test("state.pillSheetTypes is [PillSheetType.pillsheet_24_rest_4]", () {
      var mockTodayRepository = MockTodayService();
      final _today = DateTime.parse("2020-09-19");
      todayRepository = mockTodayRepository;
      when(mockTodayRepository.today()).thenReturn(_today);
      when(mockTodayRepository.now()).thenReturn(_today);

      final batchFactory = MockBatchFactory();
      final batch = MockWriteBatch();
      when(batchFactory.batch()).thenReturn(batch);
      final authService = MockAuthService();
      when(authService.stream())
          .thenAnswer((realInvocation) => const Stream.empty());

      final pillSheet = PillSheet(
          typeInfo: PillSheetType.pillsheet_24_rest_4.typeInfo,
          beginingDate: _today);
      final pillSheetService = MockPillSheetService();
      when(pillSheetService.register(batch, [pillSheet]))
          .thenReturn([pillSheet.copyWith(id: "sheet_id")]);

      final pillSheetGroup = PillSheetGroup(
          pillSheetIDs: ["sheet_id"],
          pillSheets: [pillSheet.copyWith(id: "sheet_id")],
          createdAt: now());
      final pillSheetGroupService = MockPillSheetGroupService();
      when(pillSheetGroupService.register(batch, pillSheetGroup))
          .thenReturn(pillSheetGroup.copyWith(id: "group_id"));

      final history = PillSheetModifiedHistoryServiceActionFactory
          .createCreatedPillSheetAction(
              pillSheetGroupID: "group_id", pillSheetIDs: ["sheet_id"]);
      final pillSheetModifiedHistoryService =
          MockPillSheetModifiedHistoryService();
      when(pillSheetModifiedHistoryService.add(batch, history))
          .thenReturn(null);

      final setting = const Setting(
        pillNumberForFromMenstruation: 24,
        durationMenstruation: 4,
        isOnReminder: true,
        reminderTimes: [
          ReminderTime(hour: 21, minute: 20),
          ReminderTime(hour: 22, minute: 0)
        ],
        pillSheetTypes: [PillSheetType.pillsheet_24_rest_4],
      );
      final settingService = MockSettingService();
      when(settingService.updateWithBatch(batch, setting)).thenReturn(null);

      final container = ProviderContainer(
        overrides: [
          batchFactoryProvider.overrideWithValue(batchFactory),
          authServiceProvider.overrideWithValue(authService),
          settingServiceProvider.overrideWithValue(settingService),
          pillSheetServiceProvider.overrideWithValue(pillSheetService),
          pillSheetModifiedHistoryServiceProvider
              .overrideWithValue(pillSheetModifiedHistoryService),
          pillSheetGroupServiceProvider
              .overrideWithValue(pillSheetGroupService),
        ],
      );
      final store = container.read(initialSettingStoreProvider.notifier);

      store.selectedPillCategoryType(
          InitialSettingPillCategoryType.pill_category_type_24_rest_4);

      store.removePillSheetType(1);
      store.removePillSheetType(1);
      store.setTodayPillNumber(pageIndex: 0, pillNumberIntoPillSheet: 1);
      store.setReminderTime(index: 0, hour: 21, minute: 20);

      store.register();
    });
  });
}
