import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:newsee/presentation/pages/select_interests/select_interests_page.dart';
import 'package:newsee/services/login_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 앱 시작 시 알림 초기화
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    // 앱 시작 시 토큰 확인
    //_checkAndNavigate(context);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 화면 크기에 따라 폰트 크기나 여백 조정
    double logoWidth = screenWidth * 0.7;
    double textFontSize = screenWidth * 0.05;
    double subtitleFontSize = screenWidth * 0.04;
    double buttonWidth = screenWidth * 0.7;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 이미지 크기 조정
            Image.asset(
              'assets/logo.png',
              width: logoWidth,
            ),
            SizedBox(height: screenHeight * 0.04),
            Text(
              '당신만을 위한 뉴스',
              style: TextStyle(fontSize: textFontSize),
            ),
            Text(
              '뉴스로 세상과 대화를 시작해보세요',
              style: TextStyle(fontSize: subtitleFontSize),
            ),
            SizedBox(height: screenHeight * 0.15),

            // 카카오 로그인 버튼 크기 조정
            InkWell(
              onTap: () => _handleKakaoLogin(context),
              child: Image.asset(
                'assets/kakaoLoginButton.png',
                width: buttonWidth,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkAndNavigate(BuildContext context) async {
    if (await LoginService.hasValidToken()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const SelectInterests(visibilityFlag: 0),
        ),
      );
    }
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
      _logger.i('카카오계정으로 로그인 성공 ${token.accessToken}');

      bool success = await LoginService.loginWithKakaoToken(token.accessToken);
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SelectInterests(visibilityFlag: 0),
          ),
        );
      }
    } catch (error) {
      //_logger.e('카카오계정으로 로그인 실패', error: error);
    }
  }
}
