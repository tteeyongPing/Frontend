import 'news.dart';

class Playlist {
  final int playlistId;
  final String playlistName;
  final String? description;
  final int userId;
  final String userName;
  final int subscribers;
  final List<News>? newsList;

  Playlist({
    required this.playlistId,
    required this.playlistName,
    this.description,
    required this.userId,
    required this.userName,
    this.newsList,
    required this.subscribers,
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
