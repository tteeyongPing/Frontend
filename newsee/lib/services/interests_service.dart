import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';

// 관심사 데이터 로드
Future<List<Map<String, dynamic>>> fetchInterests(String endpoint) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];

  var url = Uri.parse('${RootUrlProvider.baseURL}/category/$endpoint');
  var response = await http.get(
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
    throw Exception('Failed to load interests');
  }
}

// 관심사 데이터 저장
Future<bool> saveInterests(List<int> selectedInterests) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];
  int? userId = credentials['userId'];

  var url =
      Uri.parse('${RootUrlProvider.baseURL}/category/edit?userId=$userId');
  var response = await http.patch(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(selectedInterests),
  );

  return response.statusCode == 200;
}
