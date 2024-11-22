import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:newsee/models/Playlist.dart';

class PlaylistService {
  final String baseUrl;
  final Logger _logger = Logger();

  PlaylistService(this.baseUrl);

  // 플레이리스트 목록 가져오기
  Future<List<Playlist>> fetchPlaylists() async {
    final url = Uri.parse('$baseUrl/api/playlist/list');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('플레이리스트 가져오기 성공: ${responseData['message']}');

        final List<dynamic> data = responseData['data'];
        return data.map((item) => Playlist.fromJson(item)).toList();
      } else {
        _logger.e('플레이리스트 가져오기 실패: ${responseData['message']}');
        throw Exception(
            'Failed to fetch playlists: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 내 플레이리스트에 뉴스 추가하기
  Future<void> addNewsToPlaylist(int playlistId, List<int> newsIds) async {
    final url = Uri.parse('$baseUrl/api/playlist/news/add');
    final body = {
      'playlistId': playlistId,
      'newsIdList': newsIds.map((id) => {'newsId': id}).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('뉴스 추가 성공: ${responseData['message']}');
      } else {
        _logger.e('뉴스 추가 실패: ${responseData['message']}');
        throw Exception(
            'Failed to add news to playlist: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 플레이리스트에서 뉴스 삭제
  Future<void> removeNewsFromPlaylist(int playlistId, List<int> newsIds) async {
    final url = Uri.parse('$baseUrl/api/playlist/news/remove');

    // 요청 헤더와 본문
    final request = http.Request("DELETE", url)
      ..headers.addAll({'Content-Type': 'application/json'})
      ..body = jsonEncode({
        'playlistId': playlistId,
        'newsIdList': newsIds.map((id) => {'newsId': id}).toList(),
      });

    final response = await http.Client().send(request);

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final Map<String, dynamic> responseData = jsonDecode(responseBody);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('뉴스 삭제 성공: ${responseData['message']}');
      } else {
        _logger.e('뉴스 삭제 실패: ${responseData['message']}');
        throw Exception(
            'Failed to remove news from playlist: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 플레이리스트 생성하기
  Future<void> createPlaylist(
      String playlistName, String description, List<int> newsIds) async {
    final url = Uri.parse('$baseUrl/api/playlist/create');
    final body = {
      'playlistName': playlistName,
      'description': description,
      'newsIdList': newsIds.map((id) => {'newsId': id}).toList(),
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('플레이리스트 생성 성공: ${responseData['message']}');
      } else {
        _logger.e('플레이리스트 생성 실패: ${responseData['message']}');
        throw Exception(
            'Failed to create playlist: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }

  // 플레이리스트 이름 / 설명 수정하기
  Future<void> editPlaylist(
      int playlistId, String playlistName, String description) async {
    final url = Uri.parse('$baseUrl/api/playlist/edit');
    final body = {
      'playlistId': playlistId,
      'playlistName': playlistName,
      'description': description,
    };

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (responseData['result'] == "SUCCESS") {
        _logger.i('플레이리스트 수정 성공: ${responseData['message']}');
      } else {
        _logger.e('플레이리스트 수정 실패: ${responseData['message']}');
        throw Exception('Failed to edit playlist: ${responseData['message']}');
      }
    } else {
      _logger.e('백엔드 연결 실패 (상태 코드: ${response.statusCode})');
      throw Exception('Failed to connect to the backend');
    }
  }
}
