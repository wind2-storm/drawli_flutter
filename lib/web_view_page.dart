import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:drawli_flutter/push_service.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tosspayments_sdk_flutter/model/tosspayments_url.dart';
import 'package:url_launcher/url_launcher.dart';

import 'main.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final GlobalKey webViewKey = GlobalKey();

  // webview settings
  late InAppWebViewController webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    useOnDownloadStart: true, // file download use
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    // iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
    userAgent: "userAgent flutter",
  );

  PullToRefreshController? pullToRefreshController;
  String url = "https://drawli.ai";
  final urlController = TextEditingController();

  final ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();

    // backgound file downloader
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    // callback event
    _port.listen((dynamic data) {
      // String id = data[0];
      // int status = data[1];
      // int progress = data[2];
      // setState((){ });
    });

    FlutterDownloader.registerCallback(downloadCallback);

    // push init
    PushService();

    // scroll refresh
    pullToRefreshController = kIsWeb
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(
              color: Colors.blue,
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS) {
                webViewController.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController.getUrl(),
                  ),
                );
              }
            },
          );
  }
  
  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  /// web_view 하단 리모컨
  /// 뒤로가기, 앞으로가기, 새로고침, 창닫기 처리
  Widget _navigationBar() {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child : Container(
        // color: Colors.lightBlue,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _make_image,
              child: const SizedBox(
                height: 60,
                child: Icon(Icons.portrait),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _coloring_paint,
              child: const SizedBox(
                height: 60,
                child: Icon(Icons.color_lens),
              ),
            ),
          ),
          // [뒤로가기]
          Expanded(
            child: GestureDetector(
              onTap: _back,
              child: const SizedBox(
                height: 60,
                child: Icon(Icons.arrow_back),
              ),
            ),
          ),
          // [뒤로가기]

          // [앞으로가기]
          Expanded(
            child: GestureDetector(
              onTap: _forward,
              child: const SizedBox(
                height: 60,
                child: Icon(Icons.arrow_forward),
              ),
            ),
          ),
          // [앞으로가기]

          // [새로고침]
          Expanded(
            child: GestureDetector(
              onTap: _refresh,
              child: const SizedBox(
                height: 60,
                child: Icon(Icons.refresh),
              ),
            ),
          ),
          // [새로고침]

          // [닫기]
          // Expanded(
          //   child: GestureDetector(
          //     onTap: _close,
          //     child: const SizedBox(
          //       height: 60,
          //       child: Icon(Icons.close),
          //     ),
          //   ),
          // ),
          // [닫기]
        ],
      ),
      ),
    );
  }

  /// 뒤로가기
  void _back() async {
    if (await webViewController.canGoBack()) {
      // 뒤로갈 페이지가 있다면 뒤로가기
      webViewController.goBack();
    } else {
      // 뒤로갈 페이지가 더 이상 없다면 앱 종료하기
      if (mounted) {
        _close();
      }
    }
  }

  /// 앞으로가기
  void _forward() async {
    // 앞으로갈 페이지가 있다면 앞으로가기
    if (await webViewController.canGoForward()) {
      webViewController.goForward();
    }
  }

  /// 새로고침
  void _refresh() => webViewController.reload();

  /// 창닫기
  void _close() {
    // FIXME : url 새로 로드하는법
    // webViewController.loadUrl(urlRequest: Uri.parse("https://"));
    if (Platform.isAndroid) {
      // android
      SystemNavigator.pop();
    } else {
      // ios
      exit(0);
    }
  }
  void _make_image() {
    // FIXME : url 새로 로드하는법
    webViewController.loadUrl(
      urlRequest: URLRequest(
          url: WebUri('https://drawli.ai/draw')
    ),
    );
  }
  void _coloring_paint() {
    // FIXME : url 새로 로드하는법
    webViewController.loadUrl(
      urlRequest: URLRequest(
          url: WebUri('https://drawli.ai/paint')
      ),
    );
  }
  /// toss payments scheme
  tossPaymentsWebview(url) {
    final appScheme = ConvertUrl(url); // Intent URL을 앱 스킴 URL로 변환

    if (appScheme.isAppLink()) {
      // 앱 스킴 URL인지 확인
      appScheme.launchApp(); // 앱 설치 상태에 따라 앱 실행 또는 마켓으로 이동
      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) => _back(),
      child: Scaffold(
        body: SafeArea(
          child: InAppWebView(
            key: webViewKey,
            initialUrlRequest: URLRequest(url: WebUri("https://drawli.ai")),//https://112.169.48.197:15321/
            // initialUrlRequest: URLRequest(url: WebUri("https://112.169.48.197:15321/")),
            initialSettings: settings,
            pullToRefreshController: pullToRefreshController,
            onWebViewCreated: (controller) {
              webViewController = controller;

              // web view file download !!
              // ex) window.flutter_inappwebview.callHandler('fileDownload', url);
              // url = pdf file url
              controller.addJavaScriptHandler(
                handlerName: "fileDownload",
                callback: (data) async {
                  print("download log----");
                  print(data);
                  print("--------------");
                  if (data.isNotEmpty) {
                    final String url = data[0];

                    // 파일 다운로드 경로 가져오기
                    final directory = await getApplicationDocumentsDirectory();
                    var savedDirPath = directory.path;
                    print('download:$savedDirPath');
                    // 파일 다운로드
                    await FlutterDownloader.enqueue(
                      url: url,
                      headers: {},
                      savedDir: savedDirPath,
                      saveInPublicStorage: true,
                      showNotification: true, // notification
                      openFileFromNotification: true, // notification
                    );
                    print('download:2,$url');
                  }
                },
              );

              // ex) window.flutter_inappwebview.callHandler('openBrowser', url);
              controller.addJavaScriptHandler(
                handlerName: "openBrowser",
                callback: (data) async {
                  if (data.isNotEmpty) {
                    final String url = data[0];
                    final Uri uri = Uri.parse(url);

                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onPermissionRequest: (controller, request) async {
              return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT);
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              var uri = navigationAction.request.url!;

              if (![
                "http",
                "https",
                "file",
                "chrome",
                "data",
                "javascript",
                "about"
              ].contains(uri.scheme)) {
                if ("intent".contains(uri.scheme)) {
                  return await tossPaymentsWebview(uri);
                } else if (await canLaunchUrl(uri)) {
                  // Launch the App
                  // ex - tel:+0211111111
                  await launchUrl(uri);

                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                }
              }

              return NavigationActionPolicy.ALLOW;
            },
            onLoadStop: (controller, url) async {
              pullToRefreshController?.endRefreshing();
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onReceivedError: (controller, request, error) {
              pullToRefreshController?.endRefreshing();
            },
            onProgressChanged: (controller, progress) {
              if (progress == 100) {
                pullToRefreshController?.endRefreshing();
              }
              setState(() {
                urlController.text = url;
              });
            },
            onUpdateVisitedHistory: (controller, url, androidIsReload) {
              setState(() {
                this.url = url.toString();
                urlController.text = this.url;
              });
            },
            onConsoleMessage: (controller, consoleMessage) {
              // logger
              // if (kDebugMode) {
              //   print(consoleMessage);
              // }
            },
            onDownloadStartRequest: (InAppWebViewController controller, DownloadStartRequest downloadStartRequest) async {
              // blob
            }
          ),
        ),
        bottomNavigationBar: _navigationBar(
        ),
      ),
    );
  }
}

// privacy page 외부 창에서 띄우기
// window.flutter_inappwebview.callHandler('fileDownload', url);