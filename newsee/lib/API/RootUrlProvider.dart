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
      return 'https://newsee.xyz/api'; // 네이티브 환경에서는 실제 API 서버 URL
    }
  }
}
