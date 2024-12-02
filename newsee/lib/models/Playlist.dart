import './News.dart';

class Playlist {
  final int playlistId;
  final String playlistName;
  final String description;
  final int userId;
  final String userName;
  final int subscribers;
  final List<News> newsList;

  Playlist({
    required this.playlistId,
    required this.playlistName,
    required this.description,
    required this.userId,
    required this.userName,
    required this.newsList,
    required this.subscribers,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlistId'] as int,
      playlistName: json['playlistName'] as String,
      description: json['description'] as String,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      subscribers: json['subscribers'] as int,
      newsList: (json['newsList'] as List?)
              ?.map(
                  (newsJson) => News.fromJson(newsJson as Map<String, dynamic>))
              .toList() ??
          [], // null인 경우 빈 리스트로 대체
    );
  }
}

class News {
  final int id;
  final String title;
  final String date;
  final String company;
  final String? category;
  final String content;
  bool selected; // Make selected mutable

  News({
    required this.id,
    required this.title,
    required this.date,
    required this.company,
    this.category,
    required this.content,
    this.selected = false, // Default value set to false
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      title: json['title'] as String,
      date: json['date'] as String,
      company: json['company'] as String,
      category: json['category'] as String,
      content: json['content'] as String,
      selected: json['selected'] ??
          false, // Handle existing value or default to false
    );
  }
}
