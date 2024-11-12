import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:newsee/models/News.dart'; // News 모델
import 'package:newsee/presentation/pages/PlaylistPage/playlistDetailPage/playlistDetailPage.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool isNewsSelected = true;
  final TextEditingController _searchController = TextEditingController();
  List<Playlist> playlists = []; // 플레이리스트 목록
  List<Playlist> subscribePlaylists = []; // 구독한 플레이리스트 목록

  @override
  void initState() {
    super.initState();
    loadUserPlaylists();
  }

  // JSON 데이터 로드 함수 (나의 플레이리스트)
  Future<void> loadUserPlaylists() async {
    final String response =
        await rootBundle.loadString('assets/SampleMyPlayList.json');
    final data = json.decode(response);
    setState(() {
      playlists = (data['data'] as List)
          .map((playlistJson) => Playlist.fromJson(playlistJson))
          .toList();
    });
  }

  // JSON 데이터 로드 함수 (구독한 플레이리스트)
  Future<void> loadSubscribePlaylists() async {
    final String response =
        await rootBundle.loadString('assets/SampleSubscribePlayList.json');
    final data = json.decode(response);
    setState(() {
      subscribePlaylists = (data['data'] as List)
          .map((playlistJson) => Playlist.fromJson(playlistJson))
          .toList();
    });
  }

  // 플레이리스트 클릭 시 뉴스 페이지로 이동
  void _navigateToNewsPage(List<News> news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsListPage(news: news),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isNewsSelected = true; // 나의 플레이리스트 선택
                          });
                          loadUserPlaylists(); // 나의 플레이리스트 데이터 로드
                        },
                        child: Container(
                          width: screenWidth * 0.5,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              '나의 플레이리스트',
                              style: TextStyle(
                                fontWeight: isNewsSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                                color: isNewsSelected
                                    ? Colors.black
                                    : Color(0xFF707070),
                              ),
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isNewsSelected = false; // 구독한 플레이리스트 선택
                          });
                          loadSubscribePlaylists(); // 구독한 플레이리스트 데이터 로드
                        },
                        child: Container(
                          width: screenWidth * 0.5,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          color: Colors.white,
                          child: Center(
                            child: Text(
                              '구독한 플레이리스트',
                              style: TextStyle(
                                fontWeight: !isNewsSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 16,
                                color: !isNewsSelected
                                    ? Colors.black
                                    : Color(0xFF707070),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 플레이리스트 목록 표시 (나의 플레이리스트 or 구독한 플레이리스트)
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: isNewsSelected
                        ? playlists.length
                        : subscribePlaylists.length,
                    itemBuilder: (context, index) {
                      final playlist = isNewsSelected
                          ? playlists[index]
                          : subscribePlaylists[index];
                      return ListTile(
                        title: Text(playlist.playlistName),
                        subtitle: Text(playlist.description),
                        onTap: () => _navigateToNewsPage(playlist.news),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
