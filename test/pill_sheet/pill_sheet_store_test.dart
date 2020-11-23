import 'package:Pilll/entity/pill_sheet.dart';
import 'package:Pilll/entity/pill_sheet_type.dart';
import 'package:Pilll/service/today.dart';
import 'package:Pilll/state/pill_sheet.dart';
import 'package:Pilll/store/pill_sheet.dart';
import 'package:Pilll/util/datetime/date_compare.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../helper/mock.dart';

void main() {
  group("#calcBeginingDateFromNextTodayPillNumber", () {
    test("pill number changed to future", () async {
      final mockTodayRepository = MockTodayRepository();
      todayRepository = mockTodayRepository;
      when(todayRepository.today()).thenReturn(DateTime.parse("2020-11-22"));

      final pillSheetEntity =
          PillSheetModel.create(PillSheetType.pillsheet_21).copyWith(
        beginingDate: DateTime.parse("2020-11-22"),
        createdAt: DateTime.parse("2020-11-22"),
      );
      final state = PillSheetState(entity: pillSheetEntity);

      final service = MockPillSheetService();
      when(service.fetchLast())
          .thenAnswer((realInvocation) => Future.value(state.entity));
      when(service.subscribeForLatestPillSheet())
          .thenAnswer((realInvocation) => Stream.empty());

      final store = PillSheetStateStore(service);
      await Future.delayed(Duration(milliseconds: 100));
      expect(state.entity.todayPillNumber, equals(1));

      final expected = DateTime.parse("2020-11-13");
      final actual = store.calcBeginingDateFromNextTodayPillNumber(10);
      expect(isSameDay(expected, actual), isTrue);
    });
  });
  test("pill number changed to past", () async {
    final mockTodayRepository = MockTodayRepository();
    todayRepository = mockTodayRepository;
    when(todayRepository.today()).thenReturn(DateTime.parse("2020-11-23"));

    final pillSheetEntity =
        PillSheetModel.create(PillSheetType.pillsheet_21).copyWith(
      beginingDate: DateTime.parse("2020-11-21"),
      createdAt: DateTime.parse("2020-11-21"),
    );
    final state = PillSheetState(entity: pillSheetEntity);

    final service = MockPillSheetService();
    when(service.fetchLast())
        .thenAnswer((realInvocation) => Future.value(state.entity));
    when(service.subscribeForLatestPillSheet())
        .thenAnswer((realInvocation) => Stream.empty());

    final store = PillSheetStateStore(service);
    await Future.delayed(Duration(milliseconds: 100));
    expect(state.entity.todayPillNumber, equals(3));

    final expected = DateTime.parse("2020-11-22");
    final actual = store.calcBeginingDateFromNextTodayPillNumber(2);
    expect(isSameDay(expected, actual), isTrue);
  });
}