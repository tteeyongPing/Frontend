import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/models/News.dart';

class NewsApi {
  final String baseUrl;

  NewsApi(this.baseUrl);

  Future<List<News>> fetchNews(int categoryId) async {
    final url = Uri.parse('$baseUrl/api/news?categoryId=$categoryId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        final List<dynamic> data = responseData['data'];
        return data.map((item) => News.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load news: ${responseData['message']}');
      }
    } else {
      throw Exception('Failed to connect to the backend');
    }
  }
}
