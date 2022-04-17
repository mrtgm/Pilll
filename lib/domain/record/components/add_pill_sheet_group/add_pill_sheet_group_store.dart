import 'dart:async';

import 'package:pilll/database/batch.dart';
import 'package:pilll/domain/record/components/add_pill_sheet_group/add_pill_sheet_group_state.codegen.dart';
import 'package:pilll/domain/record/record_page_store.dart';
import 'package:pilll/entity/pill_sheet.codegen.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/service/pill_sheet.dart';
import 'package:pilll/service/pill_sheet_group.dart';
import 'package:pilll/service/pill_sheet_modified_history.dart';
import 'package:pilll/service/setting.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:riverpod/riverpod.dart';

final addPillSheetGroupStateStoreProvider = StateNotifierProvider.autoDispose<
    AddPillSheetGroupStateStore, AddPillSheetGroupState>(
  (ref) {
    return AddPillSheetGroupStateStore(
      ref.watch(recordPageStoreProvider).pillSheetGroup,
      ref.watch(recordPageStoreProvider).appearanceMode,
      ref.watch(recordPageStoreProvider).setting,
      ref.watch(pillSheetServiceProvider),
      ref.watch(pillSheetGroupServiceProvider),
      ref.watch(settingServiceProvider),
      ref.watch(pillSheetModifiedHistoryServiceProvider),
      ref.watch(batchFactoryProvider),
    );
  },
);

class AddPillSheetGroupStateStore
    extends StateNotifier<AddPillSheetGroupState> {
  final PillSheetService _pillSheetService;
  final PillSheetGroupService _pillSheetGroupService;
  final SettingService _settingService;
  final PillSheetModifiedHistoryService _pillSheetModifiedHistoryService;
  final BatchFactory _batchFactory;
  AddPillSheetGroupStateStore(
    PillSheetGroup? pillSheetGroup,
    PillSheetAppearanceMode pillSheetAppearanceMode,
    Setting? setting,
    this._pillSheetService,
    this._pillSheetGroupService,
    this._settingService,
    this._pillSheetModifiedHistoryService,
    this._batchFactory,
  ) : super(AddPillSheetGroupState(
          pillSheetGroup: pillSheetGroup?.copyWith(),
          pillSheetAppearanceMode: pillSheetAppearanceMode,
          setting: setting?.copyWith(),
        ));

  addPillSheetType(PillSheetType pillSheetType, Setting setting) {
    final updatedSetting = setting.copyWith(
        pillSheetTypes: setting.pillSheetTypes..add(pillSheetType));
    state = state.copyWith(setting: updatedSetting);
  }

  changePillSheetType(int index, PillSheetType pillSheetType, Setting setting) {
    final copied = [...setting.pillSheetTypes];
    copied[index] = pillSheetType;

    final updatedSetting = setting.copyWith(pillSheetTypes: copied);
    state = state.copyWith(setting: updatedSetting);
  }

  removePillSheetType(int index, Setting setting) {
    final copied = [...setting.pillSheetEnumTypes];
    copied.removeAt(index);

    final updatedSetting = setting.copyWith(pillSheetTypes: copied);
    state = state.copyWith(setting: updatedSetting);
  }

  Future<void> register(Setting setting) async {
    final batch = _batchFactory.batch();

    final n = now();
    final createdPillSheets = _pillSheetService.register(
      batch,
      setting.pillSheetTypes.asMap().keys.map((pageIndex) {
        final pillSheetType = setting.pillSheetEnumTypes[pageIndex];
        final offset = summarizedPillCountWithPillSheetTypesToEndIndex(
            pillSheetTypes: setting.pillSheetEnumTypes, endIndex: pageIndex);
        return PillSheet(
          typeInfo: pillSheetType.typeInfo,
          beginingDate: n.add(
            Duration(days: offset),
          ),
          groupIndex: pageIndex,
        );
      }).toList(),
    );

    final pillSheetIDs = createdPillSheets.map((e) => e.id!).toList();
    final createdPillSheetGroup = _pillSheetGroupService.register(
      batch,
      PillSheetGroup(
        pillSheetIDs: pillSheetIDs,
        pillSheets: createdPillSheets,
        createdAt: now(),
      ),
    );

    final history = PillSheetModifiedHistoryServiceActionFactory
        .createCreatedPillSheetAction(
      pillSheetIDs: pillSheetIDs,
      pillSheetGroupID: createdPillSheetGroup.id,
    );
    _pillSheetModifiedHistoryService.add(batch, history);

    _settingService.updateWithBatch(batch, setting);

    return batch.commit();
  }
}
