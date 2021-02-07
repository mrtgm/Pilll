import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> requestNotificationPermissions() async {
  return FirebaseMessaging()
    ..requestNotificationPermissions()
    ..onIosSettingsRegistered.listen((IosNotificationSettings settings) {});
}

Future<void> listenNotificationEvents() async {
  return FirebaseMessaging()
    ..configure(
      onMessage: (Map<String, dynamic> message) async {
        print('onMessage: $message');
      },
      onBackgroundMessage: Platform.isAndroid ? onBackgroundMessage : null,
      onLaunch: (Map<String, dynamic> message) async {
        print('onLaunch: $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('onResume: $message');
      },
    );
}

Future<dynamic> onBackgroundMessage(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // データメッセージをハンドリング
    final data = message['data'];
    print("data: $data");
  }

  if (message.containsKey('notification')) {
    // 通知メッセージをハンドリング
    final notification = message['notification'];
    print("notification: $notification");
  }
  print('onBackground: $message');
}
