import 'dart:io';

import 'package:drawli_flutter/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static final PushService instance = PushService._internal();

  factory PushService() => instance;

  PushService._internal() {
    if (Platform.isIOS) _requestIOSPermission();

    setPushToken();

    // ANDROID
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    // IOS
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: _onDidRecieveLocalNotification);

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {},
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    // event!!
    // 포그라운드 상태
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        showMessage(message);
      },
    );

    // 앱이 완전 종료되어있을 경우 + 백그라운드 상태
    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {},
    );

    // 백그라운드 상테
    FirebaseMessaging.instance.getInitialMessage().then(
          (RemoteMessage? message) async {},
        );
  }

  void showMessage(RemoteMessage message) {
    var androidDetails = const AndroidNotificationDetails(
      'drawli_ai',
      'drawli_ai',
      priority: Priority.high,
      importance: Importance.max,
      color: Color(0xFF4D64F3),
    );

    var iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    _flutterLocalNotificationsPlugin.show(
      message.notification!.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }

  // pushToken 세팅 !
  void setPushToken() async {
    final String? pushToken;
    pushToken = await FirebaseMessaging.instance.getToken();
    print("---------------------------------------------");
    print(pushToken);
    print("---------------------------------------------");

    // TODO : 푸시 토큰 셋팅

    // login -> 해당 플랫폼에 acces_token -> api를 통해서 서버에 저장할때 (pushToken)
    // {
    //   "acces_token" : "aaa",
    //   "refresh_token" : "aaa",
    //   "push_token": "aaa",
    // }
    // 만약 앱이 완전하게 꺼저있는 경우에는
  }

  // IOS 권한
  void _requestIOSPermission() => _firebaseMessaging.requestPermission(
        sound: true,
        badge: false,
        alert: true,
      );

  Future<dynamic> _onDidRecieveLocalNotification(
      int id, String? title, String? body, String? payload) async {}
}
