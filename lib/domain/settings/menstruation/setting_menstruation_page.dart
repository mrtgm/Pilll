import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/template/setting_menstruation/setting_menstruation_dynamic_description.dart';
import 'package:pilll/components/template/setting_menstruation/setting_menstruation_page_template.dart';
import 'package:pilll/components/template/setting_menstruation/setting_menstruation_pill_sheet_list.dart';
import 'package:pilll/domain/settings/menstruation/setting_menstruation_store.dart';
import 'package:pilll/entity/setting.codegen.dart';

class SettingMenstruationPage extends HookConsumerWidget {
  final Setting setting;

  SettingMenstruationPage({
    Key? key,
    required this.setting,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(settingMenstruationStoreProvider.notifier);

    return SettingMenstruationPageTemplate(
      title: "生理について",
      pillSheetList: SettingMenstruationPillSheetList(
        pillSheetTypes: setting.pillSheetEnumTypes,
        appearanceMode: PillSheetAppearanceMode.sequential,
        selectedPillNumber: (pageIndex) =>
            store.retrieveMenstruationSelectedPillNumber(setting, pageIndex),
        markSelected: (pageIndex, number) {
          analytics.logEvent(name: "from_menstruation_setting", parameters: {
            "number": number,
            "page": pageIndex,
          });
          store.modifyFromMenstruation(
            setting: setting,
            pageIndex: pageIndex,
            fromMenstruation: number,
          );
        },
      ),
      dynamicDescription: SettingMenstruationDynamicDescription(
        pillSheetTypes: setting.pillSheetEnumTypes,
        fromMenstruation: setting.pillNumberForFromMenstruation,
        fromMenstructionDidDecide: (number) {
          analytics.logEvent(
              name: "from_menstruation_initial_setting",
              parameters: {"number": number});
          store.modifyFromMenstruationFromPicker(
            setting: setting,
            serializedPillNumberIntoGroup: number,
          );
        },
        durationMenstruation: setting.durationMenstruation,
        durationMenstructionDidDecide: (number) {
          analytics.logEvent(
              name: "duration_menstruation_initial_setting",
              parameters: {"number": number});
          store.modifyDurationMenstruation(
            setting: setting,
            durationMenstruation: number,
          );
        },
      ),
      doneButton: null,
    );
  }
}

extension SettingMenstruationPageRoute on SettingMenstruationPage {
  static Route<dynamic> route({required Setting setting}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: "SettingMenstruationPage"),
      builder: (_) => SettingMenstruationPage(setting: setting),
    );
  }
}
