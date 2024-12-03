import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';
import 'package:newsee/models/Playlist.dart';

// 플레이리스트 목록 불러오기
Future<List<Playlist>> fetchPlaylists(bool isMine) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];
  final endpoint = isMine ? '/playlist/list' : '/playlist/subscribe/list';
  final url = Uri.parse('${RootUrlProvider.baseURL}$endpoint');

  final response = await http.get(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    var data = json.decode(utf8.decode(response.bodyBytes));
    return List<Playlist>.from(
        data['data'].map((item) => Playlist.fromJson(item)));
  } else {
    throw Exception('Failed to load playlists');
  }
}

// 플레이리스트 생성
Future<void> createPlaylist(String name, String desc) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];
  final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/create');

  final response = await http.post(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json'
    },
    body: jsonEncode(
      {"playlistName": name, "description": desc, "newsIdList": []},
    ),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to create playlist');
  }
}

// 플레이리스트 삭제
Future<void> deletePlaylist(int id, bool isMine) async {
  final credentials = await getTokenAndUserId();
  String? token = credentials['token'];
  final endpoint = isMine
      ? '/playlist/remove?playlistId=$id'
      : '/playlist/subscribe/cancel?playlistId=$id';
  final url = Uri.parse('${RootUrlProvider.baseURL}$endpoint');

  final response = await (isMine
      ? http.delete(url, headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        })
      : http.post(url, headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        }));

  if (response.statusCode != 200) {
    throw Exception('Failed to delete playlist');
  }
}
