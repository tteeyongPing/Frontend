import 'package:newsee/models/News.dart';

class Bookmark {
  final List<News> newsList; // 여러 News 객체를 포함하는 리스트

  Bookmark({required this.newsList});

  // JSON 데이터를 Bookmark 객체로 변환하는 팩토리 메서드
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    // 'data' 키가 리스트 형태로 News 객체 데이터를 포함한다고 가정
    final List<dynamic> data = json['data'];
    final List<News> newsList =
        data.map((item) => News.fromJson(item)).toList();

    return Bookmark(newsList: newsList);
  }

  // Bookmark 객체를 JSON 형태로 변환
  Map<String, dynamic> toJson() {
    return {
      'data': newsList.map((news) => news.toJson()).toList(),
    };
  }
}
