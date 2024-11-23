import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트

class LoginPage extends StatelessWidget {
  // 토큰 저장 함수
  Future<void> saveToken(String token, int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);

    print('토큰 저장 완료: $token');
    print('userId 저장 완료: $userId');
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

        // API 응답에서 token 추출
        String newToken = responseData['data']['token'];
        int userId = responseData['data']['userId'];
        // 토큰 저장
        saveToken(newToken, userId);

        // 로그인 성공 후 Main 페이지로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SelectInterests()),
        );
      } else {
        print('로그인 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생: $e');
      // 예외 처리 로직 추가
    }
  }

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
                child: Text("임시 이동 버튼"))
          ],
        ),
      ),
    );
  }
}
