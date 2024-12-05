// lib/utils/my_page_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';

class MyPageService {
  // 토큰과 사용자 ID를 SharedPreferences에서 가져오는 함수

  // 서버에서 닉네임을 가져오는 함수
  Future<String?> fetchNickName() async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/nickname/get');
      var response = await http.patch(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        return data['data']; // 닉네임 반환
      } else {
        throw Exception('닉네임을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('닉네임을 불러오는 중 오류가 발생했습니다.');
    }
  }

  // loadName 함수도 이곳으로 옮김
  Future<String?> loadName() async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/nickname/get');
      var response = await http.patch(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        return data['data']; // 닉네임 반환
      } else {
        throw Exception('닉네임을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      throw Exception('닉네임을 불러오는 중 오류가 발생했습니다.');
    }
  }
}
