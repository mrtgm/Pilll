import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/molecules/indicator.dart';
import 'package:pilll/domain/calendar/calendar_page_state.dart';
import 'package:pilll/domain/calendar/components/calendar_card.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/domain/calendar/components/pill_sheet_modified_history/pill_sheet_modified_history_card.dart';
import 'package:pilll/domain/home/home_page.dart';
import 'package:pilll/domain/calendar/calendar_page_store.dart';
import 'package:flutter/material.dart';
import 'package:pilll/error/universal_error_page.dart';
import 'package:pilll/hooks/automatic_keep_alive_client_mixin.dart';

class CalendarPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(calendarPageStateStoreProvider.notifier);
    final state = ref.watch(calendarPageStateStoreProvider);
    homeKey.currentState?.diaries = state.diariesForMonth;

    useAutomaticKeepAlive(wantKeepAlive: true);

    final exception = state.exception;
    if (exception != null) {
      return UniversalErrorPage(
        error: exception,
        child: null,
        reload: () => store.reset(),
      );
    }

    if (state.shouldShowIndicator) {
      return ScaffoldIndicator();
    }

    final pageController =
        usePageController(initialPage: state.currentCalendarIndex);
    pageController.addListener(() {
      final index = (pageController.page ?? pageController.initialPage).round();
      store.updateCurrentCalendarIndex(index);
    });

    return Scaffold(
      backgroundColor: PilllColors.background,
      appBar: AppBar(
        title: CalendarModifyMonth(
          state: state,
          pageController: pageController,
          store: store,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: PilllColors.white,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 444,
              child: PageView(
                controller: pageController,
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                children:
                    List.generate(state.calendarDataSource.length, (index) {
                  return CalendarContainer(store: store, state: state);
                }),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: CalendarPillSheetModifiedHistoryCard(
                store: store,
                state: CalendarPillSheetModifiedHistoryCardState(
                  state.allPillSheetModifiedHistories,
                  isPremium: state.isPremium,
                  isTrial: state.isTrial,
                  trialDeadlineDate: state.trialDeadlineDate,
                ),
              ),
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}

class CalendarContainer extends StatelessWidget {
  const CalendarContainer({
    Key? key,
    required this.store,
    required this.state,
  }) : super(key: key);

  final CalendarPageStateStore store;
  final CalendarPageState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 444,
      width: MediaQuery.of(context).size.width,
      child: CalendarCard(
        state: store.cardState(state.displayMonth),
        diariesForMonth: state.diariesForMonth,
        allBands: state.allBands,
      ),
    );
  }
}

class CalendarModifyMonth extends StatelessWidget {
  const CalendarModifyMonth({
    Key? key,
    required this.state,
    required this.pageController,
    required this.store,
  }) : super(key: key);

  final CalendarPageState state;
  final PageController pageController;
  final CalendarPageStateStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: SvgPicture.asset("images/arrow_left.svg"),
          onPressed: () {
            final previousMonthIndex = state.currentCalendarIndex - 1;
            pageController.jumpToPage(previousMonthIndex);
            store.updateCurrentCalendarIndex(previousMonthIndex);
            analytics.logEvent(name: "pressed_previous_month", parameters: {
              "current_index": state.currentCalendarIndex,
              "previous_index": previousMonthIndex
            });
          },
        ),
        Text(
          state.displayMonthString,
          style: TextColorStyle.main.merge(FontType.subTitle),
        ),
        IconButton(
          icon: SvgPicture.asset("images/arrow_right.svg"),
          onPressed: () {
            final nextMonthIndex = state.currentCalendarIndex + 1;
            pageController.jumpToPage(nextMonthIndex);
            store.updateCurrentCalendarIndex(nextMonthIndex);
            analytics.logEvent(name: "pressed_next_month", parameters: {
              "current_index": state.currentCalendarIndex,
              "next_index": nextMonthIndex
            });
          },
        ),
      ],
    );
  }
}
