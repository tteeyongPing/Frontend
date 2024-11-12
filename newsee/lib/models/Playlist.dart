import './News.dart'; // News 모델을 import

class Playlist {
  final int playlistId;
  final String playlistName;
  final String description;
  final List<News> news; // News 객체 리스트 추가

  Playlist({
    required this.playlistId,
    required this.playlistName,
    required this.description,
    required this.news, // News 리스트 받음
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
      news: newsList, // 변환된 News 리스트
    );
  }
}
