import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  int? userId = prefs.getInt('userId');
  return {'token': token, 'userId': userId};
}
