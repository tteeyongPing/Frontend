// News 모델 클래스에 factory 생성자 추가
class News {
  final int newsId;
  final String? categoryId;
  final String title;
  final String date;
  final String content;
  final String company;
  final String? reporter;
  final String? shorts;
  bool selected;

  News({
    required this.newsId,
    this.categoryId,
    required this.title,
    required this.date,
    required this.content,
    required this.company,
    this.reporter,
    this.shorts,
    this.selected = false,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['id'],
      categoryId: json['category'] ?? '',
      title: json['title'],
      date: json['date'],
      content: json['content'],
      company: json['company'],
      reporter: json['reporter'] ?? '',
      shorts: json['shorts'] ?? '',
      selected: false,
    );
  }
}
