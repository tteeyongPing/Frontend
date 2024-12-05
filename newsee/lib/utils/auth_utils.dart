import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences에서 토큰과 userId 가져오기
Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}
