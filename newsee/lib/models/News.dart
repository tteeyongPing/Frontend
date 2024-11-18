// models/news.dart

class News {
  final int newsId;
  final int categoryId;
  final String title;
  final String date;
  final String content;
  final String company;
  final String shorts;
  final String reporter;

  News({
    required this.newsId,
    required this.categoryId,
    required this.title,
    required this.date,
    required this.content,
    required this.company,
    required this.shorts,
    required this.reporter,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['id'],
      categoryId: json['category'],
      title: json['title'],
      date: json['date'],
      content: json['content'],
      company: json['company'],
      shorts: json['shorts'],
      reporter: json['reporter'],
    );
  }
}
