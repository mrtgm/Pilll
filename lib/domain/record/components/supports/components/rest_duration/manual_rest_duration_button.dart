import 'package:flutter/material.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/atoms/buttons.dart';
import 'package:pilll/domain/record/components/pill_sheet/components/record_page_rest_duration_dialog.dart';
import 'package:pilll/domain/record/components/supports/components/rest_duration/invalid_already_taken_pill_dialog.dart';
import 'package:pilll/domain/record/record_page_store.dart';
import 'package:pilll/entity/pill_sheet.dart';
import 'package:pilll/entity/pill_sheet_group.dart';
import 'package:pilll/entity/setting.dart';

class BeginManualRestDurationButton extends StatelessWidget {
  final PillSheetAppearanceMode appearanceMode;
  final PillSheet activedPillSheet;
  final PillSheetGroup pillSheetGroup;
  final RecordPageStore store;

  const BeginManualRestDurationButton({
    Key? key,
    required this.appearanceMode,
    required this.activedPillSheet,
    required this.pillSheetGroup,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: SmallAppOutlinedButton(
        text: "休薬する",
        onPressed: () async {
          analytics.logEvent(
              name: "begin_manual_rest_duration_pressed",
              parameters: {"pill_sheet_id": activedPillSheet.id});

          if (activedPillSheet.todayPillIsAlreadyTaken) {
            showInvalidAlreadyTakenPillDialog(context);
          } else {
            showRecordPageRestDurationDialog(context,
                appearanceMode: appearanceMode,
                pillSheetGroup: pillSheetGroup,
                activedPillSheet: activedPillSheet, onDone: () async {
              analytics.logEvent(name: "done_rest_duration");
              Navigator.of(context).pop();
              await store.beginResting(
                pillSheetGroup: pillSheetGroup,
                activedPillSheet: activedPillSheet,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(
                    seconds: 2,
                  ),
                  content: Text("休薬期間が始まりました"),
                ),
              );
            });
          }
        },
      ),
    );
  }
}

class EndManualRestDurationButton extends StatelessWidget {
  final RestDuration restDuration;
  final PillSheet activedPillSheet;
  final PillSheetGroup pillSheetGroup;
  final RecordPageStore store;

  const EndManualRestDurationButton({
    Key? key,
    required this.restDuration,
    required this.activedPillSheet,
    required this.pillSheetGroup,
    required this.store,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      child: SmallAppOutlinedButton(
        text: "休薬終了",
        onPressed: () async {
          analytics.logEvent(
            name: "end_manual_rest_duration_pressed",
          );

          await store.endResting(
            pillSheetGroup: pillSheetGroup,
            activedPillSheet: activedPillSheet,
            restDuration: restDuration,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: Duration(
                seconds: 2,
              ),
              content: Text("休薬期間が終了しました"),
            ),
          );
        },
      ),
    );
  }
}
