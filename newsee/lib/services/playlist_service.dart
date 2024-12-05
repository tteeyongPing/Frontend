import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/utils/auth_utils.dart';
import 'package:newsee/models/playlist.dart';

// Playlist Page
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
  print(url);
  if (response.statusCode == 200) {
    var data = json.decode(utf8.decode(response.bodyBytes))['data'];

    return List<Playlist>.from(data.map((item) => Playlist.fromJson(item)));
  } else if (response.statusCode == 404) {
    return [];
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
  print("Authorization : 'Bearer $token',");
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

// Playlist Detail Page
// 플레이리스트 편집
Future<http.Response> editPlaylist(
    String token, int playlistId, String name, String description) async {
  final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/edit');
  return await http.patch(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      "playlistId": playlistId,
      "playlistName": name,
      "description": description,
    }),
  );
}

// 플레이리스트 구독자
Future<http.Response> getSubscriptionStatus(
    String token, int playlistId) async {
  final url = Uri.parse(
      '${RootUrlProvider.baseURL}/playlist/subscribe/status?playlistId=$playlistId');
  return await http.get(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
}

//플레이리스트 구독 변경
Future<http.Response> changeSubscription(
    String token, int playlistId, bool subscribe) async {
  final endpoint =
      subscribe ? '/playlist/subscribe' : '/playlist/subscribe/cancel';
  final url =
      Uri.parse('${RootUrlProvider.baseURL}$endpoint?playlistId=$playlistId');

  return await http.post(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    },
  );
}

//플레이리스트 뉴스 삭제
Future<http.Response> deleteNewsItem(
    String token, int playlistId, int newsId) async {
  final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/news/remove');
  return await http.delete(
    url,
    headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'playlistId': playlistId,
      "newsIdList": [newsId],
    }),
  );
}

// playlistId로 플레이리스트 가져오기
Future<Map<String, dynamic>> fetchPlaylistDetails(
    String token, int playlistId) async {
  // Construct the endpoint URL
  final url =
      Uri.parse('${RootUrlProvider.baseURL}/playlist/detail/$playlistId');

  // Make the GET request
  final response = await http.get(
    url,
    headers: {
      'Authorization': 'Bearer $token', // Add the Bearer token
      'accept': '*/*', // Accept any media type
    },
  );

  // Check the response status
  if (response.statusCode == 200) {
    // Decode the JSON response
    final Map<String, dynamic> responseData = json.decode(response.body);
    return responseData;
  } else {
    // Handle errors
    throw Exception('Failed to fetch playlist details: ${response.statusCode}');
  }
}
