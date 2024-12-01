import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:newsee/presentation/pages/PlaylistPage/playlistDetailPage/playlist_detail_page.dart';

late ScrollController _scrollController;

class PlaylistPage extends StatefulWidget {
  const PlaylistPage({super.key});

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  late List<Playlist> playlists = []; // 플레이리스트 목록
  late List<Playlist> subscribePlaylists = []; // 구독한 플레이리스트 목록
  bool isMyPlaylistSelected = true;

  @override
  void initState() {
    super.initState();
    loadDemoData(); // 데모 데이터 로드
  }

  // 데모 데이터를 로드하는 함수
  void loadDemoData() {}

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
          Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isMyPlaylistSelected = true;
                      });
                    },
                    child: Container(
                      width: screenWidth * 0.5,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
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
                    },
                    child: Container(
                      width: screenWidth * 0.5,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
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
              // 구분선
              Container(
                width: screenWidth,
                alignment: Alignment.centerLeft,
                child: isMyPlaylistSelected
                    ? Container(
                        width: screenWidth * 0.45,
                        alignment: Alignment.centerLeft,
                        child: Divider(
                          color: Colors.black,
                          height: 1.0,
                          thickness: 2.0,
                          indent: screenWidth * 0.05,
                          endIndent: 0.0,
                        ),
                      )
                    : Container(
                        width: screenWidth * 0.95,
                        alignment: Alignment.centerLeft,
                        child: Divider(
                          color: Colors.black,
                          height: 1.0,
                          thickness: 2.0,
                          indent: screenWidth * 0.55,
                          endIndent: 0.0,
                        ),
                      ),
              ),
            ],
          ),
          // 플레이리스트 목록
          Expanded(
            child: ListView.builder(
              itemCount: isMyPlaylistSelected
                  ? playlists.length
                  : subscribePlaylists.length,
              itemBuilder: (context, index) {
                final playlist = isMyPlaylistSelected
                    ? playlists[index]
                    : subscribePlaylists[index];
                return GestureDetector(
                  onTap: () => _navigateToPlaylistDetail(playlist),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 제목 및 카운트 + 버튼
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      playlist.playlistName,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8), // 제목과 카운트 간의 간격
                                  Text(
                                    "(${playlist.news.length})",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 20, // 버튼 크기

                              ),
                              onPressed: () {
                                // 점 세 개 버튼 클릭 시 실행
                                showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.edit),
                                          title: const Text('수정'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // 수정 동작 추가
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.delete),
                                          title: const Text('삭제'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // 삭제 동작 추가
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 설명
                        Text(
                          playlist.description.length > 60
                              ? '${playlist.description.substring(0, 60)}...'
                              : playlist.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // 게시자
                        Row(
                          children: [
                            Text(
                              "게시자: ${playlist.userId}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
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
