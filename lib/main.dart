import 'dart:isolate';
import 'dart:ui';

import 'package:drawli_flutter/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import 'web_view_page.dart';

// background notification push event!!
@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse notificationResponse) async {
  // handle action
}

// background notification push event!!
@pragma('vm:entry-point')
Future<void> firebaseBackgroundNotification(RemoteMessage notificationResponse) async {
  // handle action
}

// background file downloader evnet!!
@pragma('vm:entry-point')
void downloadCallback(String id, int status, int downloadProgress) {
  final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
  send.send([id, status, downloadProgress]);
}

void main() async {
  // web_view debug
  WidgetsFlutterBinding.ensureInitialized();

  // Plugin must be initialized before using
  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );

  await Permission.storage.request(); // 저장공간 권한 요청 추가

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // android web debug
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    // FIXME : 뒤로가기 버튼 누르면 뒤로가기 처리 완료.
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []); //하단 상태바 제거, 뒤로가기 누르면 앱 종료돼서

    return const MaterialApp(
      title: 'Flutter App',
      debugShowCheckedModeBanner: false,
      home: WebViewPage(),
    );
  }
}

// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext? context) {
//     return super.createHttpClient(context)
//       ..userAgent =
//           'user-userAgent';
//   }
// }