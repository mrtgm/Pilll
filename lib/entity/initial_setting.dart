import 'package:Pilll/entity/pill_mark_type.dart';
import 'package:Pilll/entity/pill_sheet.dart';
import 'package:Pilll/entity/pill_sheet_type.dart';
import 'package:Pilll/entity/setting.dart';
import 'package:Pilll/util/datetime/today.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'initial_setting.freezed.dart';

@freezed
abstract class InitialSettingModel implements _$InitialSettingModel {
  InitialSettingModel._();
  factory InitialSettingModel.initial({
    int fromMenstruation,
    int durationMenstruation,
    @Default(22) int reminderHour,
    @Default(0) int reminderMinute,
    @Default(false) bool isOnReminder,
    int todayPillNumber,
    PillSheetType pillSheetType,
  }) = _InitialSettingModel;

  Setting buildSetting() => Setting(
        fromMenstruation: fromMenstruation,
        durationMenstruation: durationMenstruation,
        pillSheetTypeRawPath: pillSheetType.rawPath,
        reminderTimes: [
          ReminderTime(hour: reminderHour, minute: reminderMinute)
        ],
        isOnReminder: isOnReminder,
      );
  PillSheetModel buildPillSheet() => PillSheetModel(
        beginingDate: _beginingDate(),
        lastTakenDate: _lastTakenDate(),
        typeInfo: _typeInfo(),
      );

  DateTime _beginingDate() {
    return today().subtract(Duration(days: todayPillNumber - 1));
  }

  DateTime _lastTakenDate() {
    return todayPillNumber == 1 ? null : today();
  }

  PillSheetTypeInfo _typeInfo() {
    return PillSheetTypeInfo(
      pillSheetTypeReferencePath: pillSheetType.rawPath,
      dosingPeriod: pillSheetType.dosingPeriod,
      totalCount: pillSheetType.totalCount,
    );
  }

  PillMarkType pillMarkTypeFor(int number) {
    assert(pillSheetType != null);
    if (todayPillNumber == number) {
      return PillMarkType.selected;
    }
    if (pillSheetType.beginingWithoutTakenPeriod <= number) {
      return PillMarkType.notTaken;
    }
    return PillMarkType.normal;
  }

  DateTime reminderDateTime() {
    var t = DateTime.now();
    return DateTime(t.year, t.month, t.day, reminderHour, reminderMinute,
        t.second, t.millisecond, t.microsecond);
  }
}
