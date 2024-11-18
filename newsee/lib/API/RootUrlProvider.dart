import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

class RootUrlProvider {
  static String get baseURL {
    // 네이티브 환경에서는 실제 API 서버 URL을 반환하고, 웹 환경에서는 assets 폴더 사용
    if (kIsWeb) {
      return 'assets/'; // 웹 환경에서는 assets 폴더
    } else {
      return 'https://your-api-server.com/api/'; // 네이티브 환경에서는 실제 API 서버 URL
    }
  }

  // 웹 환경에서 JSON 파일을 로드하는 함수
  static Future<Map<String, dynamic>> loadJsonData(String path) async {
    if (kIsWeb) {
      // 웹에서 assets 폴더의 JSON 파일을 읽어오기
      String jsonString = await rootBundle.loadString(path);
      return json.decode(jsonString);
    } else {
      // 네이티브 환경에서는 실제 API 요청을 보내기
      var response = await http.get(Uri.parse('${baseURL}$path'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    }
  }
}
