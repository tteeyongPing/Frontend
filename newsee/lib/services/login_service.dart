import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/services/alert/load_alert.dart';
import 'package:newsee/services/alert/schedule_alert.dart';
import 'package:logger/logger.dart';

class LoginService {
  static final Logger _logger = Logger();

  // 토큰 저장
  static Future<void> saveToken(String token, int userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setInt('userId', userId);

    _logger.i('토큰 저장 완료: $token');
    _logger.i('userId 저장 완료: $userId');
  }

  // 토큰 확인
  static Future<bool> hasValidToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  // 카카오 토큰으로 서버 로그인
  static Future<bool> loginWithKakaoToken(String token) async {
    var url =
        Uri.parse('${RootUrlProvider.baseURL}/kakao/token/login?token=$token');
    _logger.d('URL=$url');

    try {
      var response = await http.post(url);

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        _logger.i('로그인 성공: $responseData');

        String newToken = responseData['data']['token'];
        int userId = responseData['data']['userId'];

        await saveToken(newToken, userId);
        await cancelAllNotifications();
        await LoadAlert();
        await scheduleNotifications();

        return true;
      } else {
        _logger.e('로그인 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      //_logger.e('오류 발생', error: e);
      return false;
    }
  }
}
