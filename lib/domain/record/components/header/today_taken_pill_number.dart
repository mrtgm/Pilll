import 'package:flutter/cupertino.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/entity/pill_sheet_group.codegen.dart';
import 'package:pilll/entity/pill_sheet_type.dart';
import 'package:flutter/material.dart';
import 'package:pilll/entity/setting.codegen.dart';

class TodayTakenPillNumber extends StatelessWidget {
  final PillSheetGroup? pillSheetGroup;
  final VoidCallback onPressed;
  final Setting setting;

  const TodayTakenPillNumber({
    Key? key,
    required this.pillSheetGroup,
    required this.onPressed,
    required this.setting,
  }) : super(key: key);

  PillSheetAppearanceMode get _appearanceMode =>
      setting.pillSheetAppearanceMode;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_appearanceMode == PillSheetAppearanceMode.sequential)
            Text(
              "💊 今日は服用",
              style: FontType.assisting.merge(TextColorStyle.noshime),
            ),
          if (_appearanceMode != PillSheetAppearanceMode.sequential)
            Text(
              "💊 今日飲むピル",
              style: FontType.assisting.merge(TextColorStyle.noshime),
            ),
          _content(),
        ],
      ),
      onTap: () {
        analytics.logEvent(name: "tapped_record_page_today_pill");
        if (pillSheetGroup?.activedPillSheet == null) {
          return;
        }
        this.onPressed();
      },
    );
  }

  Widget _content() {
    final pillSheetGroup = this.pillSheetGroup;
    final activedPillSheet = this.pillSheetGroup?.activedPillSheet;
    if (pillSheetGroup == null ||
        activedPillSheet == null ||
        pillSheetGroup.isDeactived ||
        activedPillSheet.activeRestDuration != null) {
      return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text("-",
              style: FontType.assisting.merge(TextColorStyle.noshime)));
    }
    if (activedPillSheet.inNotTakenDuration) {
      return Text(
        "${activedPillSheet.pillSheetType.notTakenWord}${activedPillSheet.todayPillNumber - activedPillSheet.typeInfo.dosingPeriod}日目",
        style: FontType.assistingBold.merge(TextColorStyle.main),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.ideographic,
      children: <Widget>[
        if (_appearanceMode == PillSheetAppearanceMode.number) ...[
          Text("${activedPillSheet.todayPillNumber}",
              style: FontType.xHugeNumber.merge(TextColorStyle.main)),
          Text("番",
              style: FontType.assistingBold.merge(TextColorStyle.noshime)),
        ],
        if (_appearanceMode == PillSheetAppearanceMode.date) ...[
          Text("${activedPillSheet.todayPillNumber}",
              style: FontType.xHugeNumber.merge(TextColorStyle.main)),
          Text("番",
              style: FontType.assistingBold.merge(TextColorStyle.noshime)),
        ],
        if (_appearanceMode == PillSheetAppearanceMode.sequential) ...[
          Text("${pillSheetGroup.sequentialTodayPillNumber}",
              style: FontType.xHugeNumber.merge(TextColorStyle.main)),
          Text("番",
              style: FontType.assistingBold.merge(TextColorStyle.noshime)),
        ],
      ],
    );
  }
}
