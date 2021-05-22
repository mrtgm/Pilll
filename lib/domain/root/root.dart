import 'package:pilll/analytics.dart';
import 'package:pilll/service/auth.dart';
import 'package:pilll/database/database.dart';
import 'package:pilll/domain/home/home_page.dart';
import 'package:pilll/domain/initial_setting/initial_setting_1_page.dart';
import 'package:pilll/entity/user_error.dart';
import 'package:pilll/components/molecules/indicator.dart';
import 'package:pilll/error/template.dart';
import 'package:pilll/error/universal_error_page.dart';
import 'package:pilll/error_log.dart';
import 'package:pilll/service/user.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

GlobalKey<RootState> rootKey = GlobalKey();

class Root extends StatefulWidget {
  Root({Key? key}) : super(key: key);

  @override
  RootState createState() => RootState();
}

enum ScreenType { home, initialSetting }
enum IndicatorType { shown, hidden }

class RootState extends State<Root> {
  dynamic? error;
  onError(dynamic error) {
    setState(() {
      this.error = error;
    });
  }

  ScreenType? screenType;
  showHome() {
    setState(() {
      screenType = ScreenType.home;
    });
  }

  showInitialSetting() {
    setState(() {
      screenType = ScreenType.initialSetting;
    });
  }

  reloadRoot() {
    setState(() {
      screenType = null;
      error = null;
      _auth();
    });
  }

  List<IndicatorType> _indicatorTypes = [];
  showIndicator() {
    _indicatorTypes.add(IndicatorType.shown);
    Future.delayed(Duration(milliseconds: 200)).then((value) {
      if (_indicatorTypes.isEmpty) {
        return;
      }
      if (_indicatorTypes.last == IndicatorType.hidden) {
        return;
      }
      showDialog(
          barrierColor: Colors.transparent,
          context: context,
          builder: (BuildContext context) {
            return DialogIndicator();
          });
    });
  }

  hideIndicator() {
    if (_indicatorTypes.isEmpty) {
      return;
    }
    if (_indicatorTypes.last != IndicatorType.shown) {
      return;
    }
    _indicatorTypes.add(IndicatorType.hidden);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    _auth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return UniversalErrorPage(error: error.toString());
    }
    if (screenType == null) {
      return ScaffoldIndicator();
    }
    return Consumer(builder: (context, watch, child) {
      return watch(authStateProvider).when(data: (snapshot) {
        switch (screenType) {
          case ScreenType.home:
            return HomePage(key: homeKey);
          case ScreenType.initialSetting:
            return InitialSetting1PageRoute.screen();
          default:
            return ScaffoldIndicator();
        }
      }, loading: () {
        return ScaffoldIndicator();
      }, error: (error, stacktrace) {
        print(error);
        print(stacktrace);
        errorLogger.recordError(error, stacktrace);
        final displayedError = ErrorMessages.connection +
            "\n" +
            "errorType: ${error.runtimeType.toString()}\n" +
            error.toString() +
            "error: ${error.toString()}\n" +
            stacktrace.toString();
        return UniversalErrorPage(error: displayedError);
      });
    });
  }

  _auth() {
    cacheOrAuth().then((authInfo) {
      final userService = UserService(DatabaseConnection(authInfo.uid));
      errorLogger.setUserIdentifier(authInfo.uid);
      firebaseAnalytics.setUserId(authInfo.uid);
      return userService.prepare(authInfo.uid).then((_) async {
        userService.saveLaunchInfo();
        userService.saveStats();
        final user = await userService.fetch();
        if (!user.migratedFlutter) {
          await userService.deleteSettings();
          await userService.setFlutterMigrationFlag();
          return ScreenType.initialSetting;
        }
        if (user.setting == null) {
          return ScreenType.initialSetting;
        }
        final storage = await SharedPreferences.getInstance();
        if (!storage.getKeys().contains(StringKey.firebaseAnonymousUserID)) {
          storage.setString(StringKey.firebaseAnonymousUserID, authInfo.uid);
        }
        bool? didEndInitialSetting =
            storage.getBool(BoolKey.didEndInitialSetting);
        if (didEndInitialSetting == null) {
          return ScreenType.initialSetting;
        }
        if (!didEndInitialSetting) {
          return ScreenType.initialSetting;
        }
        return ScreenType.home;
      });
    }).then((screenType) {
      setState(() {
        this.screenType = screenType;
      });
    }).catchError((error) {
      errorLogger.recordError(error, StackTrace.current);
      onError(UserDisplayedError(ErrorMessages.connection +
          "\n" +
          "errorType: ${error.runtimeType.toString()}\n" +
          "error: ${error.toString()}\n" +
          StackTrace.current.toString()));
    });
  }
}
