import 'package:flutter/material.dart';
import 'package:pilll/components/organisms/calendar/band/calendar_band_model.dart';
import 'package:pilll/domain/calendar/date_range.dart';
import 'package:pilll/components/organisms/calendar/week/week_calendar_state.dart';
import 'package:pilll/entity/diary.codegen.dart';

class MenstruationSinglelineWeekCalendarState extends WeekCalendarState {
  final DateRange dateRange;
  final List<Diary> diariesForMonth;
  final List<CalendarBandModel> allBandModels;
  MenstruationSinglelineWeekCalendarState({
    required this.dateRange,
    required this.diariesForMonth,
    required this.allBandModels,
  });

  bool isGrayoutTile(DateTime date) => false;
  bool hasDiaryMark(List<Diary> diaries, DateTime date) =>
      isExistsPostedDiary(diaries, date);
  bool hasMenstruationMark(DateTime date) => false;
  Alignment get contentAlignment => Alignment.center;
}
