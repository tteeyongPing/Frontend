// models/news.dart

class News {
  final int newsId;
  final int categoryId;
  final String title;
  final String date;
  final String content;
  final String newspaper;
  final String summary;
  final String reporter;

  News({
    required this.newsId,
    required this.categoryId,
    required this.title,
    required this.date,
    required this.content,
    required this.newspaper,
    required this.summary,
    required this.reporter,
  });

  // JSON 데이터를 News 객체로 변환하는 factory 메서드
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['newsId'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      content: json['content'] ?? '',
      newspaper: json['newspaper'] ?? '',
      summary: json['summary'] ?? '',
      reporter: json['reporter'] ?? '',
    );
  }

  // News 객체를 JSON으로 변환하는 메서드 (필요 시)
  Map<String, dynamic> toJson() {
    return {
      'newsId': newsId,
      'categoryId': categoryId,
      'title': title,
      'date': date,
      'content': content,
      'newspaper': newspaper,
      'summary': summary,
      'reporter': reporter,
    };
  }
}
