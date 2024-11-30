import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:newsee/models/Bookmark.dart';

class BookmarkService {
  final String baseUrl;
  final Logger _logger = Logger();

  BookmarkService(this.baseUrl);

  // 북마크 목록 가져오기
  Future<Bookmark> fetchBookmarks() async {
    final url = Uri.parse('$baseUrl/api/bookmarks');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('북마크 목록 가져오기 성공');
        return Bookmark.fromJson(responseData);
      } else {
        _logger.e('북마크 목록 가져오기 실패: ${responseData['message']}');
        throw Exception(
            'Failed to fetch bookmarks: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 북마크 추가
  Future<void> addBookmarks(List<int> newsIds) async {
    final url = Uri.parse('$baseUrl/api/bookmarks/add');
    final body = {
      'news': newsIds.map((id) => {'newsId': id}).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('북마크 추가 성공: ${responseData['message']}');
      } else {
        _logger.e('북마크 추가 실패: ${responseData['message']}');
        throw Exception('Failed to add bookmarks: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 북마크 삭제
  Future<void> deleteBookmarks(List<int> newsIds) async {
    final url = Uri.parse('$baseUrl/api/bookmarks/delete');
    final body = {
      'news': newsIds.map((id) => {'newsId': id}).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('북마크 삭제 성공: ${responseData['message']}');
      } else {
        _logger.e('북마크 삭제 실패: ${responseData['message']}');
        throw Exception(
            'Failed to delete bookmarks: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }
}
