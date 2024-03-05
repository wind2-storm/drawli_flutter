import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'web_view_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  // _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(Duration(seconds: 1), () {}); // 5초간 대기
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WebViewPage())); // 여기서 HomePage()는 메인 화면 위젯
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset('assets/lottie/splash_fast.json'), // Lottie 애니메이션 로드
      ),
    );
  }
}
