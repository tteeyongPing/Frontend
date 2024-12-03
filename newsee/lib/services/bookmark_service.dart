import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';

// 북마크 목록 불러오기
Future<List<Map<String, dynamic>>> fetchBookmarks() async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];
  final url = Uri.parse('${RootUrlProvider.baseURL}/bookmark/list');

  final response = await http.get(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(utf8.decode(response.bodyBytes));
    return List<Map<String, dynamic>>.from(data['data']);
  } else {
    throw Exception('Failed to fetch bookmarks');
  }
}

// 북마크 삭제
Future<bool> deleteBookmark(int newsId) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];

  final url = Uri.parse('${RootUrlProvider.baseURL}/bookmark/delete');

  final response = await http.delete(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: jsonEncode([
      {'newsId': newsId}
    ]),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    throw Exception('Failed to delete bookmark: ${response.body}');
  }
}
