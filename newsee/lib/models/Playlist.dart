import './News.dart';

class Playlist {
  final int playlistId;
  final String playlistName;
  final String description;
  final String userId;
  final List<News> news;

  Playlist({
    required this.playlistId,
    required this.playlistName,
    required this.description,
    required this.userId,
    required this.news,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var newsList = <News>[]; // 빈 리스트로 초기화

    if (json['news'] is List) {
      newsList = (json['news'] as List).map((newsJson) {
        return News.fromJson(newsJson);
      }).toList();
    }

    return Playlist(
      playlistId: json['playlistId'],
      playlistName: json['playlistName'],
      description: json['description'],
      userId: json['userId'],
      news: newsList,
    );
  }
}
