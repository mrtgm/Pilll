import 'dart:async';
import 'dart:math';

import 'package:pilll/database/batch.dart';
import 'package:pilll/domain/record/util/take.dart';
import 'package:pilll/entity/pill_mark_type.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/entity/user.codegen.dart';
import 'package:pilll/native/legacy.dart';
import 'package:pilll/provider/shared_preference.dart';
import 'package:pilll/service/auth.dart';
import 'package:pilll/database/pill_sheet.dart';
import 'package:pilll/domain/record/record_page_state.codegen.dart';
import 'package:pilll/database/pill_sheet_group.dart';
import 'package:pilll/database/pill_sheet_modified_history.dart';
import 'package:pilll/database/setting.dart';
import 'package:pilll/database/user.dart';
import 'package:pilll/provider/premium_and_trial.codegen.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final recordPageStoreProvider =
    StateNotifierProvider<RecordPageStore, RecordPageState>(
        (ref) => RecordPageStore(
              ref.watch(batchFactoryProvider),
              ref.watch(pillSheetDatastoreProvider),
              ref.watch(settingDatastoreProvider),
              ref.watch(userDatastoreProvider),
              ref.watch(authServiceProvider),
              ref.watch(pillSheetModifiedHistoryDatastoreProvider),
              ref.watch(pillSheetGroupDatastoreProvider),
              ref.watch(userEntityProvider),
            ));

class RecordPageStore extends StateNotifier<RecordPageState> {
  final BatchFactory _batchFactory;
  final PillSheetDatastore _pillSheetDatastore;
  final SettingDatastore _settingDatastore;
  final UserDatastore _userDatastore;
  final AuthService _authService;
  final PillSheetModifiedHistoryDatastore _pillSheetModifiedHistoryDatastore;
  final PillSheetGroupDatastore _pillSheetGroupDatastore;
  final Future<User> _user;
  RecordPageStore(
    this._batchFactory,
    this._pillSheetDatastore,
    this._settingDatastore,
    this._userDatastore,
    this._authService,
    this._pillSheetModifiedHistoryDatastore,
    this._pillSheetGroupDatastore,
    this._user,
  ) : super(const RecordPageState()) {
    reset();
  }

  void reset() async {
    try {
      state = state.copyWith(exception: null);
      await Future.wait([
        Future(() async {
          final pillSheetGroup = await _pillSheetGroupDatastore.fetchLatest();
          state = state.copyWith(pillSheetGroup: pillSheetGroup);
        }),
        Future(() async {
          final setting = await _settingDatastore.fetch();
          state = state.copyWith(setting: setting);
        }),
        Future(() async {
          final user = await _user;
          state = state.copyWith(
            isPremium: user.isPremium,
            isTrial: user.isTrial,
            hasDiscountEntitlement: user.hasDiscountEntitlement,
            discountEntitlementDeadlineDate:
                user.discountEntitlementDeadlineDate,
            beginTrialDate: user.beginTrialDate,
            trialDeadlineDate: user.trialDeadlineDate,
          );
        }),
        Future(() async {
          final sharedPreferences = await SharedPreferences.getInstance();
          final totalCountOfActionForTakenPill =
              sharedPreferences.getInt(IntKey.totalCountOfActionForTakenPill) ??
                  0;
          final _shouldShowMigrateInfo = await shouldShowMigrateInfo();
          final recommendedSignupNotificationIsAlreadyShow =
              sharedPreferences.getBool(
                      BoolKey.recommendedSignupNotificationIsAlreadyShow) ??
                  false;
          final premiumTrialGuideNotificationIsClosed = sharedPreferences
                  .getBool(BoolKey.premiumTrialGuideNotificationIsClosed) ??
              false;
          final premiumTrialBeginAnouncementIsClosed = sharedPreferences
                  .getBool(BoolKey.premiumTrialBeginAnouncementIsClosed) ??
              false;
          state = state.copyWith(
            totalCountOfActionForTakenPill: totalCountOfActionForTakenPill,
            shouldShowMigrateInfo: _shouldShowMigrateInfo,
            isAlreadyShowTiral: sharedPreferences
                    .getBool(BoolKey.isAlreadyShowPremiumTrialModal) ??
                false,
            isAlreadyShowPremiumSurvey:
                sharedPreferences.getBool(BoolKey.isAlreadyShowPremiumSurvey) ??
                    false,
            recommendedSignupNotificationIsAlreadyShow:
                recommendedSignupNotificationIsAlreadyShow,
            premiumTrialGuideNotificationIsClosed:
                premiumTrialGuideNotificationIsClosed,
            premiumTrialBeginAnouncementIsClosed:
                premiumTrialBeginAnouncementIsClosed,
          );
        }),
        Future(() async {
          state = state.copyWith(
            isLinkedLoginProvider:
                _authService.isLinkedApple() || _authService.isLinkedGoogle(),
          );
        }),
      ]);
      state = state.copyWith(
        firstLoadIsEnded: true,
      );
      _subscribe();
    } catch (exception) {
      state = state.copyWith(exception: exception);
    }
  }

  StreamSubscription? _pillSheetGroupCanceller;
  StreamSubscription? _settingCanceller;
  StreamSubscription? _userSubscribeCanceller;
  StreamSubscription? _authServiceCanceller;
  void _subscribe() {
    return;
    _pillSheetGroupCanceller?.cancel();
    _pillSheetGroupCanceller =
        _pillSheetGroupDatastore.latestPillSheetGroupStream().listen((event) {
      state = state.copyWith(pillSheetGroup: event);
    });
    _settingCanceller?.cancel();
    _settingCanceller = _settingDatastore.stream().listen((setting) {
      state = state.copyWith(setting: setting);
    });
    _userSubscribeCanceller?.cancel();
    _userSubscribeCanceller = _userDatastore.stream().listen((event) {
      state = state.copyWith(
        isPremium: event.isPremium,
        isTrial: event.isTrial,
        hasDiscountEntitlement: event.hasDiscountEntitlement,
        beginTrialDate: event.beginTrialDate,
        trialDeadlineDate: event.trialDeadlineDate,
        discountEntitlementDeadlineDate: event.discountEntitlementDeadlineDate,
      );
    });
    _authServiceCanceller?.cancel();
    _authServiceCanceller = _authService.stream().listen((event) {
      state = state.copyWith(
          isLinkedLoginProvider:
              _authService.isLinkedApple() || _authService.isLinkedGoogle());
    });
  }

  @override
  void dispose() {
    _pillSheetGroupCanceller?.cancel();
    _settingCanceller?.cancel();
    _userSubscribeCanceller?.cancel();
    _authServiceCanceller?.cancel();
    super.dispose();
  }

  Future<bool> _take(DateTime takenDate) async {
    final pillSheetGroup = state.pillSheetGroup;
    if (pillSheetGroup == null) {
      throw const FormatException("pill sheet group not found");
    }
    final activedPillSheet = pillSheetGroup.activedPillSheet;
    if (activedPillSheet == null) {
      throw const FormatException("active pill sheet not found");
    }
    if (activedPillSheet.todayPillIsAlreadyTaken) {
      return false;
    }
    final updatedPillSheetGroup = await take(
      takenDate: takenDate,
      pillSheetGroup: pillSheetGroup,
      activedPillSheet: activedPillSheet,
      batchFactory: _batchFactory,
      pillSheetDatastore: _pillSheetDatastore,
      pillSheetModifiedHistoryDatastore: _pillSheetModifiedHistoryDatastore,
      pillSheetGroupDatastore: _pillSheetGroupDatastore,
      isQuickRecord: false,
    );
    if (updatedPillSheetGroup == null) {
      return false;
    }
    state = state.copyWith(pillSheetGroup: updatedPillSheetGroup);
    return true;
  }

  Future<bool> taken() {
    return _take(now());
  }

  Future<bool> takenWithPillNumber({
    required int pillNumberIntoPillSheet,
    required PillSheet pillSheet,
  }) async {
    if (pillNumberIntoPillSheet <= pillSheet.lastTakenPillNumber) {
      return false;
    }
    final activedPillSheet = state.pillSheetGroup?.activedPillSheet;
    if (activedPillSheet == null) {
      return false;
    }
    if (activedPillSheet.activeRestDuration != null) {
      return false;
    }
    if (activedPillSheet.groupIndex < pillSheet.groupIndex) {
      return false;
    }
    var diff = min(pillSheet.todayPillNumber, pillSheet.typeInfo.totalCount) -
        pillNumberIntoPillSheet;
    if (diff < 0) {
      // User tapped future pill number
      return false;
    }

    final takenDate = pillSheet.displayPillTakeDate(pillNumberIntoPillSheet);
    return _take(takenDate);
  }

  Future<void> cancelTaken() async {
    final pillSheetGroup = state.pillSheetGroup;
    if (pillSheetGroup == null) {
      throw const FormatException("現在有効なとなっているピルシートグループが見つかりませんでした");
    }
    final activedPillSheet = pillSheetGroup.activedPillSheet;
    if (activedPillSheet == null) {
      throw const FormatException("現在対象となっているピルシートが見つかりませんでした");
    }
    // キャンセルの場合は今日の服用のundo機能なので、服用済みじゃない場合はreturnする
    if (!activedPillSheet.todayPillIsAlreadyTaken ||
        activedPillSheet.lastTakenDate == null) {
      return;
    }

    await revertTaken(
        pillSheetGroup: pillSheetGroup,
        pageIndex: activedPillSheet.groupIndex,
        pillNumberIntoPillSheet: activedPillSheet.lastTakenPillNumber);
  }

  Future<void> revertTaken(
      {required PillSheetGroup pillSheetGroup,
      required int pageIndex,
      required int pillNumberIntoPillSheet}) async {
    final activedPillSheet = pillSheetGroup.activedPillSheet;
    if (activedPillSheet == null) {
      throw const FormatException("現在対象となっているピルシートが見つかりませんでした");
    }
    if (activedPillSheet.activeRestDuration != null) {
      throw const FormatException("ピルの服用の取り消し操作は休薬期間中は実行できません");
    }

    final targetPillSheet = pillSheetGroup.pillSheets[pageIndex];
    final takenDate = targetPillSheet
        .displayPillTakeDate(pillNumberIntoPillSheet)
        .subtract(const Duration(days: 1))
        .date();

    final updatedPillSheets = pillSheetGroup.pillSheets.map((pillSheet) {
      final lastTakenDate = pillSheet.lastTakenDate;
      if (lastTakenDate == null) {
        return pillSheet;
      }
      if (takenDate.isAfter(lastTakenDate)) {
        return pillSheet;
      }

      if (pillSheet.groupIndex > activedPillSheet.groupIndex) {
        return pillSheet;
      }
      if (pillSheet.groupIndex < pageIndex) {
        return pillSheet;
      }

      if (takenDate.isBefore(pillSheet.beginingDate)) {
        // reset pill sheet when back to one before pill sheet
        return pillSheet.copyWith(
            lastTakenDate:
                pillSheet.beginingDate.subtract(const Duration(days: 1)).date(),
            restDurations: []);
      } else {
        // Revert対象の日付よりも後ろにある休薬期間のデータは消す
        final remainingResetDurations = pillSheet.restDurations
            .where((restDuration) =>
                restDuration.beginDate.date().isBefore(takenDate))
            .toList();
        return pillSheet.copyWith(
            lastTakenDate: takenDate, restDurations: remainingResetDurations);
      }
    }).toList();

    final updatedPillSheetGroup =
        pillSheetGroup.copyWith(pillSheets: updatedPillSheets);
    final updatedIndexses = pillSheetGroup.pillSheets.asMap().keys.where(
          (index) =>
              pillSheetGroup.pillSheets[index] !=
              updatedPillSheetGroup.pillSheets[index],
        );

    if (updatedIndexses.isEmpty) {
      return null;
    }

    final batch = _batchFactory.batch();
    _pillSheetDatastore.update(
      batch,
      updatedPillSheets,
    );
    _pillSheetGroupDatastore.updateWithBatch(batch, updatedPillSheetGroup);

    final before = pillSheetGroup.pillSheets[updatedIndexses.last];
    final after = updatedPillSheetGroup.pillSheets[updatedIndexses.first];
    final history = PillSheetModifiedHistoryServiceActionFactory
        .createRevertTakenPillAction(
      pillSheetGroupID: pillSheetGroup.id,
      before: before,
      after: after,
    );
    _pillSheetModifiedHistoryDatastore.add(batch, history);

    await batch.commit();
  }

  bool isDone({
    required int pillNumberIntoPillSheet,
    required PillSheet pillSheet,
  }) {
    final activedPillSheet = state.pillSheetGroup?.activedPillSheet;
    if (activedPillSheet == null) {
      throw const FormatException("pill sheet not found");
    }
    if (activedPillSheet.groupIndex < pillSheet.groupIndex) {
      return false;
    }
    if (activedPillSheet.id != pillSheet.id) {
      if (pillSheet.isBegan) {
        if (pillNumberIntoPillSheet > pillSheet.lastTakenPillNumber) {
          return false;
        }
      }
      return true;
    }

    return pillNumberIntoPillSheet <= activedPillSheet.lastTakenPillNumber;
  }

  PillMarkType markFor({
    required int pillNumberIntoPillSheet,
    required PillSheet pillSheet,
  }) {
    if (pillNumberIntoPillSheet > pillSheet.typeInfo.dosingPeriod) {
      return (pillSheet.pillSheetType == PillSheetType.pillsheet_21 ||
              pillSheet.pillSheetType == PillSheetType.pillsheet_24_rest_4)
          ? PillMarkType.rest
          : PillMarkType.fake;
    }
    if (pillNumberIntoPillSheet <= pillSheet.lastTakenPillNumber) {
      return PillMarkType.done;
    }
    if (pillNumberIntoPillSheet < pillSheet.todayPillNumber) {
      return PillMarkType.normal;
    }
    return PillMarkType.normal;
  }

  bool shouldPillMarkAnimation({
    required int pillNumberIntoPillSheet,
    required PillSheet pillSheet,
  }) {
    if (state.pillSheetGroup?.activedPillSheet?.activeRestDuration != null) {
      return false;
    }
    final activedPillSheet = state.pillSheetGroup?.activedPillSheet;
    if (activedPillSheet == null) {
      throw const FormatException("pill sheet not found");
    }
    if (activedPillSheet.groupIndex < pillSheet.groupIndex) {
      return false;
    }
    if (activedPillSheet.id != pillSheet.id) {
      if (pillSheet.isBegan) {
        if (pillNumberIntoPillSheet > pillSheet.lastTakenPillNumber) {
          return true;
        }
      }
      return false;
    }

    return pillNumberIntoPillSheet > activedPillSheet.lastTakenPillNumber &&
        pillNumberIntoPillSheet <= activedPillSheet.todayPillNumber;
  }

  handleException(Object exception) {
    state = state.copyWith(exception: exception);
  }

  shownMigrateInfo() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(BoolKey.migrateFrom132IsShown, true);
    state = state.copyWith(shouldShowMigrateInfo: false);
  }

  Future<void> beginRestDuration({
    required PillSheetGroup pillSheetGroup,
    required PillSheet activedPillSheet,
  }) async {
    final restDuration = RestDuration(
      beginDate: now(),
      createdDate: now(),
    );
    final updatedPillSheet = activedPillSheet.copyWith(
      restDurations: activedPillSheet.restDurations..add(restDuration),
    );
    final updatedPillSheetGroup = pillSheetGroup.replaced(updatedPillSheet);

    final batch = _batchFactory.batch();
    _pillSheetDatastore.update(batch, updatedPillSheetGroup.pillSheets);
    _pillSheetGroupDatastore.updateWithBatch(batch, updatedPillSheetGroup);
    _pillSheetModifiedHistoryDatastore.add(
      batch,
      PillSheetModifiedHistoryServiceActionFactory
          .createBeganRestDurationAction(
        pillSheetGroupID: pillSheetGroup.id,
        before: activedPillSheet,
        after: updatedPillSheet,
        restDuration: restDuration,
      ),
    );

    await batch.commit();
  }

  Future<void> endRestDuration({
    required PillSheetGroup pillSheetGroup,
    required PillSheet activedPillSheet,
    required RestDuration restDuration,
  }) async {
    final updatedRestDuration = restDuration.copyWith(endDate: now());
    final updatedPillSheet = activedPillSheet.copyWith(
      restDurations: activedPillSheet.restDurations
        ..replaceRange(
          activedPillSheet.restDurations.length - 1,
          activedPillSheet.restDurations.length,
          [updatedRestDuration],
        ),
    );
    final updatedPillSheetGroup = pillSheetGroup.replaced(updatedPillSheet);

    final batch = _batchFactory.batch();
    _pillSheetDatastore.update(batch, updatedPillSheetGroup.pillSheets);
    _pillSheetGroupDatastore.updateWithBatch(batch, updatedPillSheetGroup);
    _pillSheetModifiedHistoryDatastore.add(
      batch,
      PillSheetModifiedHistoryServiceActionFactory
          .createEndedRestDurationAction(
        pillSheetGroupID: pillSheetGroup.id,
        before: activedPillSheet,
        after: updatedPillSheet,
        restDuration: updatedRestDuration,
      ),
    );
    await batch.commit();
  }

  void setDisplayNumberSettingBeginNumber(int begin) {
    final pillSheetGroup = state.pillSheetGroup;
    if (pillSheetGroup == null) {
      return;
    }

    final offsetPillNumber = pillSheetGroup.displayNumberSetting;
    final PillSheetGroup updatedPillSheetGroup;
    if (offsetPillNumber == null) {
      final newDisplayNumberSetting =
          DisplayNumberSetting(beginPillNumber: begin);
      updatedPillSheetGroup = pillSheetGroup.copyWith(
          displayNumberSetting: newDisplayNumberSetting);
      state = state.copyWith(pillSheetGroup: updatedPillSheetGroup);
    } else {
      final newDisplayNumberSetting =
          offsetPillNumber.copyWith(beginPillNumber: begin);
      updatedPillSheetGroup = pillSheetGroup.copyWith(
          displayNumberSetting: newDisplayNumberSetting);
      state = state.copyWith(pillSheetGroup: updatedPillSheetGroup);
    }

    _pillSheetGroupDatastore.update(updatedPillSheetGroup);
  }

  Future<void> setDisplayNumberSettingEndNumber(int end) async {
    final pillSheetGroup = state.pillSheetGroup;
    if (pillSheetGroup == null) {
      return;
    }

    final offsetPillNumber = pillSheetGroup.displayNumberSetting;
    final PillSheetGroup updatedPillSheetGroup;
    if (offsetPillNumber == null) {
      final newDisplayNumberSetting = DisplayNumberSetting(endPillNumber: end);
      updatedPillSheetGroup = pillSheetGroup.copyWith(
          displayNumberSetting: newDisplayNumberSetting);
      state = state.copyWith(pillSheetGroup: updatedPillSheetGroup);
    } else {
      final newDisplayNumberSetting =
          offsetPillNumber.copyWith(endPillNumber: end);
      updatedPillSheetGroup = pillSheetGroup.copyWith(
          displayNumberSetting: newDisplayNumberSetting);
      state = state.copyWith(pillSheetGroup: updatedPillSheetGroup);
    }

    _pillSheetGroupDatastore.update(updatedPillSheetGroup);
  }

  void switchingAppearanceMode(PillSheetAppearanceMode mode) {
    final setting = state.setting;
    if (setting == null) {
      throw const FormatException("setting entity not found");
    }
    final updated = setting.copyWith(pillSheetAppearanceMode: mode);
    _settingDatastore
        .update(updated)
        .then((value) => state = state.copyWith(setting: value));
  }

  setTrueIsAlreadyShowPremiumFunctionSurvey() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(BoolKey.isAlreadyShowPremiumSurvey, true);
    state = state.copyWith(isAlreadyShowPremiumSurvey: true);
  }
}
