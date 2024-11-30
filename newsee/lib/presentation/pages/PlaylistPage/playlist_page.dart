import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:newsee/presentation/pages/PlaylistPage/playlistDetailPage/playlist_detail_page.dart';

late ScrollController _scrollController;

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool isLoading = false;
  late List<Playlist> playlists = []; // 플레이리스트 목록
  late List<Playlist> subscribePlaylists = []; // 구독한 플레이리스트 목록
  bool isMyPlaylistSelected = true;

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

  // 플레이리스트 클릭 시 상세 페이지로 이동
  void _navigateToPlaylistDetail(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(playlist: playlist),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 탭 UI
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMyPlaylistSelected = true;
                  });
                  loadUserPlaylists();
                },
                child: Container(
                  width: screenWidth * 0.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '나의 플레이리스트',
                      style: TextStyle(
                        fontWeight: isMyPlaylistSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                        color: isMyPlaylistSelected
                            ? Colors.black
                            : const Color(0xFF707070),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isMyPlaylistSelected = false;
                  });
                  loadSubscribePlaylists();
                },
                child: Container(
                  width: screenWidth * 0.5,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  color: Colors.white,
                  child: Center(
                    child: Text(
                      '구독한 플레이리스트',
                      style: TextStyle(
                        fontWeight: !isMyPlaylistSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 16,
                        color: !isMyPlaylistSelected
                            ? Colors.black
                            : const Color(0xFF707070),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: isMyPlaylistSelected
                  ? playlists.length
                  : subscribePlaylists.length,
              itemBuilder: (context, index) {
                final playlist = isMyPlaylistSelected
                    ? playlists[index]
                    : subscribePlaylists[index];
                return GestureDetector(
                  onTap: () =>
                      _navigateToPlaylistDetail(playlist), // 클릭 시 상세 페이지로 이동
                  child: Container(
                    margin: const EdgeInsets.only(
                        top: 10, left: 24, right: 24, bottom: 10),
                    padding: const EdgeInsets.only(
                        top: 12, left: 17, right: 17, bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      height: 113, // 원하는 고정 높이를 설정
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.playlistName,
                            style: const TextStyle(fontSize: 20),
                          ),
                          Text(
                            playlist.description.length > 43
                                ? '${playlist.description.substring(0, 43)}...'
                                : playlist.description,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "게시자: ${playlist.userId}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
