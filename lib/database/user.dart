import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;
import 'package:pilll/database/database.dart';
import 'package:pilll/domain/premium_function_survey/premium_function_survey_element_type.dart';
import 'package:pilll/entity/package.codegen.dart';
import 'package:pilll/entity/premium_function_survey.codegen.dart';
import 'package:pilll/entity/setting.codegen.dart';
import 'package:pilll/entity/user.codegen.dart';
import 'package:pilll/util/datetime/day.dart';
import 'package:pilll/util/shared_preference/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info/package_info.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final userDatastoreProvider =
    Provider((ref) => UserDatastore(ref.watch(databaseProvider)));

class UserDatastore {
  final DatabaseConnection _database;
  UserDatastore(this._database);

  Future<User> prepare(String uid) async {
    print("call prepare for $uid");
    final user = await fetch().catchError((error) {
      if (error is UserNotFound) {
        return _create(uid).then((_) => fetch());
      }
      throw FormatException(
          "cause exception when failed fetch and create user for $error, stackTrace: ${StackTrace.current.toString()}");
    });
    return user;
  }

  Future<User> fetch() {
    print("call fetch for ${_database.userID}");
    return _database.userReference().get().then((document) {
      if (!document.exists) {
        print("user does not exists ${_database.userID}");
        throw UserNotFound();
      }
      print("fetched user ${document.data()}, id: ${_database.userID}");
      return User.fromJson(document.data() as Map<String, dynamic>);
    });
  }

  Stream<User> stream() {
    return _database
        .userReference()
        .snapshots(includeMetadataChanges: true)
        .map((event) => User.fromJson(event.data() as Map<String, dynamic>));
  }

  Future<void> updatePurchaseInfo({
    required bool? isActivated,
    required String? entitlementIdentifier,
    required String? premiumPlanIdentifier,
    required String purchaseAppID,
    required List<String> activeSubscriptions,
    required String? originalPurchaseDate,
  }) async {
    await _database.userReference().set({
      if (isActivated != null) UserFirestoreFieldKeys.isPremium: isActivated,
      UserFirestoreFieldKeys.purchaseAppID: purchaseAppID
    }, SetOptions(merge: true));
    final privates = {
      if (premiumPlanIdentifier != null)
        UserPrivateFirestoreFieldKeys.latestPremiumPlanIdentifier:
            premiumPlanIdentifier,
      if (originalPurchaseDate != null)
        UserPrivateFirestoreFieldKeys.originalPurchaseDate:
            originalPurchaseDate,
      if (activeSubscriptions.isNotEmpty)
        UserPrivateFirestoreFieldKeys.activeSubscriptions: activeSubscriptions,
      if (entitlementIdentifier != null)
        UserPrivateFirestoreFieldKeys.entitlementIdentifier:
            entitlementIdentifier,
    };
    if (privates.isNotEmpty) {
      await _database
          .userPrivateReference()
          .set({...privates}, SetOptions(merge: true));
    }
  }

  Future<void> syncPurchaseInfo({
    required bool isActivated,
  }) async {
    await _database.userReference().set({
      UserFirestoreFieldKeys.isPremium: isActivated,
    }, SetOptions(merge: true));
  }

  Future<void> deleteSettings() {
    return _database
        .userReference()
        .update({UserFirestoreFieldKeys.settings: FieldValue.delete()});
  }

  Future<void> setFlutterMigrationFlag() {
    return _database.userReference().set(
      {UserFirestoreFieldKeys.migratedFlutter: true},
      SetOptions(merge: true),
    );
  }

  Future<void> _create(String uid) async {
    print("call create for $uid");
    final sharedPreferences = await SharedPreferences.getInstance();
    final anonymousUserID =
        sharedPreferences.getString(StringKey.lastSignInAnonymousUID);
    return _database.userReference().set(
      {
        if (anonymousUserID != null)
          UserFirestoreFieldKeys.anonymousUserID: anonymousUserID,
        UserFirestoreFieldKeys.userIDWhenCreateUser: uid,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> registerRemoteNotificationToken(String? token) {
    print("token: $token");
    return _database.userPrivateReference().set(
      {UserPrivateFirestoreFieldKeys.fcmToken: token},
      SetOptions(merge: true),
    );
  }

  Future<void> linkApple(String? email) async {
    await _database.userReference().set({
      UserFirestoreFieldKeys.isAnonymous: false,
    }, SetOptions(merge: true));
    return _database.userPrivateReference().set({
      if (email != null) UserPrivateFirestoreFieldKeys.appleEmail: email,
      UserPrivateFirestoreFieldKeys.isLinkedApple: true,
    }, SetOptions(merge: true));
  }

  Future<void> linkGoogle(String? email) async {
    await _database.userReference().set({
      UserFirestoreFieldKeys.isAnonymous: false,
    }, SetOptions(merge: true));
    return _database.userPrivateReference().set({
      if (email != null) UserPrivateFirestoreFieldKeys.googleEmail: email,
      UserPrivateFirestoreFieldKeys.isLinkedGoogle: true,
    }, SetOptions(merge: true));
  }

  Future<void> trial(Setting setting) {
    final settingForTrial = setting.copyWith(
      pillSheetAppearanceMode: PillSheetAppearanceMode.date,
      isAutomaticallyCreatePillSheet: true,
    );

    return _database.userReference().set({
      UserFirestoreFieldKeys.isTrial: true,
      UserFirestoreFieldKeys.beginTrialDate: now(),
      UserFirestoreFieldKeys.trialDeadlineDate:
          now().add(const Duration(days: 30)),
      UserFirestoreFieldKeys.settings: settingForTrial.toJson(),
      UserFirestoreFieldKeys.hasDiscountEntitlement: true,
    }, SetOptions(merge: true));
  }

  Future<void> sendPremiumFunctionSurvey(
      List<PremiumFunctionSurveyElementType> elements, String message) async {
    final PremiumFunctionSurvey premiumFunctionSurvey = PremiumFunctionSurvey(
      elements: elements,
      message: message,
    );
    return _database.userPrivateReference().set({
      UserPrivateFirestoreFieldKeys.premiumFunctionSurvey:
          premiumFunctionSurvey.toJson()
    }, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> _fetchRawDocumentSnapshot() {
    return _database.userReference().get();
  }

  // NOTE: 下位互換のために一時的にhasDiscountEntitlementをtrueにしていくスクリプト。
  // サーバー側での制御が無駄になるけど、理屈ではこれで生合成が取れる
  Future<void> temporarySyncronizeDiscountEntitlement(User user) async {
    final discountEntitlementDeadlineDate =
        user.discountEntitlementDeadlineDate;
    final bool hasDiscountEntitlement;
    if (discountEntitlementDeadlineDate == null) {
      hasDiscountEntitlement = true;
    } else {
      hasDiscountEntitlement = !now().isAfter(discountEntitlementDeadlineDate);
    }
    return _database.userReference().set({
      UserFirestoreFieldKeys.hasDiscountEntitlement: hasDiscountEntitlement,
    }, SetOptions(merge: true));
  }
}

extension SaveUserLaunchInfo on UserDatastore {
  saveUserLaunchInfo() {
    unawaited(_recordUserIDs());
    unawaited(_saveLaunchInfo());
    unawaited(_saveStats());
  }

  Future<void> _recordUserIDs() async {
    try {
      final document = await _fetchRawDocumentSnapshot();
      final user = User.fromJson(document.data() as Map<String, dynamic>);
      final documentID = document.id;
      final sharedPreferences = await SharedPreferences.getInstance();

      List<String> userDocumentIDSets = user.userDocumentIDSets;
      if (!userDocumentIDSets.contains(documentID)) {
        userDocumentIDSets.add(documentID);
      }

      final lastSignInAnonymousUID =
          sharedPreferences.getString(StringKey.lastSignInAnonymousUID);
      List<String> anonymousUserIDSets = user.anonymousUserIDSets;
      if (lastSignInAnonymousUID != null &&
          !anonymousUserIDSets.contains(lastSignInAnonymousUID)) {
        anonymousUserIDSets.add(lastSignInAnonymousUID);
      }
      final firebaseCurrentUserID =
          firebaseAuth.FirebaseAuth.instance.currentUser?.uid;
      List<String> firebaseCurrentUserIDSets = user.firebaseCurrentUserIDSets;
      if (firebaseCurrentUserID != null &&
          !firebaseCurrentUserIDSets.contains(firebaseCurrentUserID)) {
        firebaseCurrentUserIDSets.add(firebaseCurrentUserID);
      }

      await _database.userReference().set(
        {
          UserFirestoreFieldKeys.userDocumentIDSets: userDocumentIDSets,
          UserFirestoreFieldKeys.firebaseCurrentUserIDSets:
              firebaseCurrentUserIDSets,
          UserFirestoreFieldKeys.anonymousUserIDSets: anonymousUserIDSets,
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      print(error);
    }
  }

  Future<void> _saveLaunchInfo() {
    final os = Platform.operatingSystem;
    return PackageInfo.fromPlatform().then((info) {
      final packageInfo = Package(
          latestOS: os,
          appName: info.appName,
          buildNumber: info.buildNumber,
          appVersion: info.version);
      return _database.userReference().set(
          {UserFirestoreFieldKeys.packageInfo: packageInfo.toJson()},
          SetOptions(merge: true));
    });
  }

  Future<void> _saveStats() async {
    final store = await SharedPreferences.getInstance();

    final lastLoginVersion =
        await PackageInfo.fromPlatform().then((value) => value.version);
    String? beginingVersion = store.getString(StringKey.beginingVersionKey);
    if (beginingVersion == null) {
      final v = lastLoginVersion;
      await store.setString(StringKey.beginingVersionKey, v);
      beginingVersion = v;
    }

    final now = DateTime.now().toLocal();
    final timeZoneName = now.timeZoneName;
    final timeZoneOffset = now.timeZoneOffset;

    return _database.userReference().set({
      "stats": {
        "lastLoginAt": now,
        "beginingVersion": beginingVersion,
        "lastLoginVersion": lastLoginVersion,
        "timeZoneName": timeZoneName,
        "timeZoneIsNegative": timeZoneOffset.isNegative,
        "timeZoneOffsetInHours": timeZoneOffset.inHours,
        "timeZoneOffsetInMinutes": timeZoneOffset.inMinutes,
        // Deprecated
        "timeZoneOffset":
            "${timeZoneOffset.isNegative ? "-" : "+"}${timeZoneOffset.inHours}",
      }
    }, SetOptions(merge: true));
  }
}