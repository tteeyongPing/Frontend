import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:newsee/models/Interests.dart';

Future<List<Interest>> fetchInterests() async {
  const String apiUrl = "YOUR_API_URL";

  final logger = Logger();

  // 기본 관심 분야 데이터
  const List<Map<String, dynamic>> defaultInterests = [
    {"categoryId": 1, "categoryName": "정치"},
    {"categoryId": 2, "categoryName": "경제"},
    {"categoryId": 3, "categoryName": "사회"},
    {"categoryId": 4, "categoryName": "국제"},
    {"categoryId": 5, "categoryName": "스포츠"},
    {"categoryId": 6, "categoryName": "문화/예술"},
    {"categoryId": 7, "categoryName": "과학/기술"},
    {"categoryId": 8, "categoryName": "건강/의료"},
    {"categoryId": 9, "categoryName": "연예/오락"},
    {"categoryId": 10, "categoryName": "환경"},
  ];

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return (result["data"] as List)
          .map((item) => Interest.fromJson(item))
          .toList();
    } else {
      throw Exception("Failed to load from server");
    }
  } catch (e) {
    // 서버 연결 실패 시 기본 데이터 반환
    logger.e("Error fetching interests: $e");
    return defaultInterests.map((item) => Interest.fromJson(item)).toList();
  }
}
