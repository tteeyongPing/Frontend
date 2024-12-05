import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:flutter/material.dart';

class ApiService {
  static Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'userId': prefs.getInt('userId'),
    };
  }

  static Future<List<Map<String, dynamic>>> getBannerList() async {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];

    var url = Uri.parse('${RootUrlProvider.baseURL}/banner/list');
    var response = await http.get(url, headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data['data'].map((item) => {
            'imageUrl': item['imageUrl'],
            'title': item['title'],
            'shorts': item['shorts'],
          }));
    }
    throw Exception('배너 데이터를 불러오는데 실패했습니다');
  }

  static Future<List<Map<String, dynamic>>> getMyInterests(
      List<IconData> icons) async {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];

    var url = Uri.parse('${RootUrlProvider.baseURL}/category/my');
    var response = await http.get(url, headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      return List<Map<String, dynamic>>.from(data['data'].map((item) => {
            'categoryId': item['categoryId'],
            'icon': icons[(item['categoryId'] % icons.length)],
            'text': item['categoryName'],
          }));
    }
    throw Exception('관심사를 불러오는데 실패했습니다');
  }
}
