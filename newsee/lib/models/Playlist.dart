import 'news.dart';

class Playlist {
  final int playlistId;
  final String playlistName;
  final String? description;
  final int userId;
  final String userName;
  final int subscribers;
  final List<News>? newsList;

  // 기본 생성자 추가
  Playlist({
    this.playlistId = 0,
    this.playlistName = '',
    this.description = " ",
    this.userId = 0,
    this.userName = '',
    this.newsList,
    this.subscribers = 0,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      playlistId: json['playlistId'] as int,
      playlistName: json['playlistName'] as String,
      description: json['description'] as String?,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      subscribers: json['subscribers'] as int,
      newsList: (json['newsList'] as List?)
          ?.map((newsJson) => News.fromJson(newsJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
