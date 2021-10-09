import 'package:flutter/material.dart';
import 'package:pilll/components/atoms/buttons.dart';
import 'package:pilll/components/organisms/pill_sheet/pill_sheet_view_layout.dart';
import 'package:pilll/domain/record/record_page_store.dart';
import 'package:pilll/entity/pill_sheet.dart';
import 'package:pilll/entity/pill_sheet_group.dart';
import 'package:pilll/util/datetime/day.dart';

class RecordPagePillOption extends StatelessWidget {
  final RecordPageStore store;
  final PillSheetGroup pillSheetGroup;
  final PillSheet activedPillSheet;

  const RecordPagePillOption({
    Key? key,
    required this.store,
    required this.pillSheetGroup,
    required this.activedPillSheet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final restDuration = activedPillSheet.restDuration;
    final isResting = restDuration != null &&
        restDuration.endDate == null &&
        restDuration.beginDate.isBefore(today());
    return Container(
      width: PillSheetViewLayout.width,
      child: Row(children: [
        Spacer(),
        SizedBox(
          width: 80,
          child: PrimaryOutlinedButton(
            text: isResting ? "休薬する" : "休薬終了",
            fontSize: 12,
            onPressed: () async {
              if (restDuration == null) {
                await store.beginResting(
                  pillSheetGroup: pillSheetGroup,
                  activedPillSheet: activedPillSheet,
                );
              } else {
                await store.endResting(
                  pillSheetGroup: pillSheetGroup,
                  activedPillSheet: activedPillSheet,
                  restDuration: restDuration,
                );
              }
            },
          ),
        ),
      ]),
    );
  }
}