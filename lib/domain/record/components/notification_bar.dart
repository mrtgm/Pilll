import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pilll/analytics.dart';
import 'package:pilll/components/atoms/color.dart';
import 'package:pilll/components/atoms/font.dart';
import 'package:pilll/components/atoms/text_color.dart';
import 'package:pilll/domain/demography/demography_page.dart';
import 'package:pilll/domain/premium_trial/premium_trial_complete_modal.dart';
import 'package:pilll/domain/premium_trial/premium_trial_modal.dart';
import 'package:pilll/domain/record/components/notification_bar_store.dart';
import 'package:pilll/domain/record/components/notification_bar_store_parameter.dart';
import 'package:pilll/signin/signin_sheet.dart';
import 'package:pilll/signin/signin_sheet_state.dart';

class NotificationBar extends HookWidget {
  final NotificationBarStoreParameter parameter;

  NotificationBar(this.parameter);
  @override
  Widget build(BuildContext context) {
    final body = _body(context);
    if (body != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        color: PilllColors.secondary,
        child: body,
      );
    }

    return Container();
  }

  Widget? _body(BuildContext context) {
    final store = useProvider(notificationBarStoreProvider(parameter));
    final state = useProvider(notificationBarStoreProvider(parameter).state);
    if (!state.isPremium) {
      final restDurationNotification = state.restDurationNotification;
      if (restDurationNotification != null) {
        return RestDurationNotificationBar(
            restDurationNotification: restDurationNotification);
      }

      final recommendedSignupNotification = state.recommendSignupNotification;
      if (recommendedSignupNotification != null) {
        return RecommendSignupNotificationBar(
            store: store,
            recommendedSignupNotification: recommendedSignupNotification);
      }
    } else {
      if (state.shownRecommendSignupNotificationForPremium) {
        return RecommendSignupForPremiumNotificationBar();
      }
    }

    final premiumTrialGuide = state.premiumTrialGuide;
    if (premiumTrialGuide != null) {
      return PremiumTrialGuideNotificationBar(
          store: store, premiumTrialGuide: premiumTrialGuide);
    }

    final premiumTrialLimit = state.premiumTrialLimit;
    if (premiumTrialLimit != null) {
      return Center(
        child: Text(premiumTrialLimit,
            style: FontType.assistingBold.merge(TextColorStyle.white)),
      );
    }
  }
}

class PremiumTrialGuideNotificationBar extends StatelessWidget {
  const PremiumTrialGuideNotificationBar({
    Key? key,
    required this.store,
    required this.premiumTrialGuide,
  }) : super(key: key);

  final NotificationBarStateStore store;
  final String premiumTrialGuide;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        analytics.logEvent(name: "premium_trial_from_notification_bar");
        showPremiumTrialModal(context, () {
          showPremiumTrialCompleteModalPreDialog(context);
        });
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            alignment: Alignment.topLeft,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              analytics.logEvent(name: "premium_trial_notification_closed");
              store.closePremiumTrialNotification();
            },
            iconSize: 24,
            padding: EdgeInsets.zero,
          ),
          Spacer(),
          Column(
            children: [
              Text(
                premiumTrialGuide,
                style: TextColorStyle.white.merge(FontType.descriptionBold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Spacer(),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "images/arrow_right.svg",
                  color: Colors.white,
                ),
                onPressed: () {},
                iconSize: 24,
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendSignupForPremiumNotificationBar extends StatelessWidget {
  const RecommendSignupForPremiumNotificationBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSigninSheet(context, SigninSheetStateContext.recordPage,
          (linkAccount) {
        analytics.logEvent(name: "tapped_premium_signup_notification_bar");
        showDemographyPageIfNeeded(context);
      }),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(flex: 2),
          Column(
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    "images/alert_24.svg",
                    width: 16,
                    height: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "アカウント登録をしてください",
                    style: TextColorStyle.white.merge(FontType.descriptionBold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                "機種変更やスマホ紛失時に、プレミアム機能を引き継げません",
                style: TextStyle(
                  color: TextColor.white,
                  fontFamily: FontFamily.japanese,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Spacer(flex: 1),
          IconButton(
            icon: SvgPicture.asset(
              "images/arrow_right.svg",
              color: Colors.white,
            ),
            onPressed: () {},
            iconSize: 24,
            padding: EdgeInsets.all(8),
            alignment: Alignment.centerRight,
          ),
        ],
      ),
    );
  }
}

class RecommendSignupNotificationBar extends StatelessWidget {
  const RecommendSignupNotificationBar({
    Key? key,
    required this.store,
    required this.recommendedSignupNotification,
  }) : super(key: key);

  final NotificationBarStateStore store;
  final String recommendedSignupNotification;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showSigninSheet(context, SigninSheetStateContext.recordPage,
          (linkAccount) {
        analytics.logEvent(name: "signined_account_from_notification_bar");
        showDemographyPageIfNeeded(context);
      }),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            alignment: Alignment.topLeft,
            icon: Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              analytics.logEvent(
                  name: "record_page_signing_notification_closed");
              store.closeRecommendedSignupNotification();
            },
            iconSize: 24,
            padding: EdgeInsets.zero,
          ),
          Spacer(),
          Column(
            children: [
              Text(
                recommendedSignupNotification,
                style: TextColorStyle.white.merge(FontType.descriptionBold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Spacer(),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset(
                  "images/arrow_right.svg",
                  color: Colors.white,
                ),
                onPressed: () {},
                iconSize: 24,
                padding: EdgeInsets.all(8),
                alignment: Alignment.centerRight,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RestDurationNotificationBar extends StatelessWidget {
  const RestDurationNotificationBar({
    Key? key,
    required this.restDurationNotification,
  }) : super(key: key);

  final String restDurationNotification;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(restDurationNotification,
          style: FontType.assistingBold.merge(TextColorStyle.white)),
    );
  }
}
