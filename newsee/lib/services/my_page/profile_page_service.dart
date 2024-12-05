import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';

class UserService {
  static Future<void> removeUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('userName');
    } catch (e) {
      // print("오류 발생");
    }
  }

  static Future<String?> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? ' '; // 기본값 ' ' 반환
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<bool> logout(String? token) async {
    var url = Uri.parse('${RootUrlProvider.baseURL}/user/logout');
    var response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  static Future<bool> deleteAccount(String? token) async {
    var url = Uri.parse('${RootUrlProvider.baseURL}/user/leave');
    var response = await http.delete(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }
}
