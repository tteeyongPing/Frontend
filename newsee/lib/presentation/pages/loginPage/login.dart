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

// 모든 예약된 알림을 취소
Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

// 알림 예약
Future<void> scheduleNotification() async {
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  // 현재 시간 가져오기
  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

  // 현재 시간에 5초 추가
  final tz.TZDateTime scheduledDate = now.add(Duration(seconds: 3));

  // 알림 세부 사항 설정
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'repeating channel id',
    'repeating channel name',
    channelDescription: 'repeating description',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  // 알림을 5초 뒤에 예약
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, // 알림 ID
    '정해진 시간 알림', // 제목
    '이 알림은 3초 후에 표시됩니다!', // 내용
    scheduledDate, // 예약된 시간
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  print('알림 예약 완료: $scheduledDate');
}

// API 요청 함수
Future<void> sendData(String token, BuildContext context) async {
  var url =
      Uri.parse('${RootUrlProvider.baseURL}/kakao/token/login?token=$token');
  print('URL=$url');
  try {
    // 토큰을 URL에 쿼리 파라미터로 포함하여 POST 요청
    var response = await http.post(url);

    // 응답 처리
    if (response.statusCode == 200) {
      // 로그인 성공 시 응답 데이터 처리
      var responseData = json.decode(response.body);
      print('로그인 성공: ${responseData}');
      scheduleNotification(); // 알림 예약 추가
      // API 응답에서 token 추출
      String newToken = responseData['data']['token'];
      int userId = responseData['data']['userId'];
      // 토큰 저장
      saveToken(newToken, userId);
      loadAlert();
      // 로그인 성공 후 Main 페이지로 이동
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
    // 예외 처리 로직 추가
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
                //cancelAllNotifications();
                scheduleNotification();
              },
              child: Text("알림 버튼"),
            ),
          ],
        ),
      ),
    );
  }
}
