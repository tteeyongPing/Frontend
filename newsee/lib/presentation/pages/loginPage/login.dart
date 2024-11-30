import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:newsee/services/alert/LoadAlert.dart';
import 'package:newsee/services/alert/ScheduleAlert.dart';

// 토큰 저장 함수
Future<void> saveToken(String token, int userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token);
  await prefs.setInt('userId', userId);

  print('토큰 저장 완료: $token');
  print('userId 저장 완료: $userId');
}

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 앱 시작 시 알림 초기화
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> sendData(String token, BuildContext context) async {
  var url =
      Uri.parse('${RootUrlProvider.baseURL}/kakao/token/login?token=$token');
  print('URL=$url');
  try {
    var response = await http.post(url);

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      print('로그인 성공: ${responseData}');

      String newToken = responseData['data']['token'];
      int userId = responseData['data']['userId'];
      saveToken(newToken, userId); // 토큰 저장
      await cancelAllNotifications(); //알림 취소
      await LoadAlert(); // 알림 로드
      await scheduleNotifications(); // 알림 예약
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SelectInterests(visibilityFlag: 0)),
      );
    } else {
      print('로그인 실패: ${response.statusCode}');
    }
  } catch (e) {
    print('오류 발생: $e');
  }
}

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: screenWidth * 0.7,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text('당신만을 위한 뉴스', style: TextStyle(fontSize: screenWidth * 0.04)),
            Text('뉴스로 세상과 대화를 시작해보세요',
                style: TextStyle(fontSize: screenWidth * 0.03)),
            SizedBox(height: screenWidth * 0.15),
            InkWell(
              onTap: () async {
                try {
                  // 카카오 로그인
                  OAuthToken token =
                      await UserApi.instance.loginWithKakaoAccount();
                  print('카카오계정으로 로그인 성공 ${token.accessToken}');

                  // 로그인 후 sendData 호출
                  sendData(token.accessToken, context);
                } catch (error) {
                  print('카카오계정으로 로그인 실패 $error');
                }
              },
              child: Image.asset(
                'assets/kakaoLoginButton.png',
                width: screenWidth * 0.7,
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              child: Text("임시 이동 버튼"),
            ),
            InkWell(
              onTap: () {
                cancelAllNotifications();
                scheduleNotifications();
              },
              child: Text("알림 버튼"),
            ),
          ],
        ),
      ),
    );
  }
}
