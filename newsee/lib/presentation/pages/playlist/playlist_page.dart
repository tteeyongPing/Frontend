import 'package:flutter/material.dart';
import 'package:newsee/models/playlist.dart';
import 'package:newsee/presentation/pages/playlist/playlist_detail/playlist_detail_page.dart';
import 'package:newsee/services/playlist_service.dart';
import 'package:newsee/presentation/pages/playlist/playlist_dialog.dart';
import 'package:newsee/utils/dialog_utils.dart';

class PlaylistPage extends StatefulWidget {
  final bool isMine;
  const PlaylistPage({super.key, this.isMine = true});

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

class PlaylistPageState extends State<PlaylistPage> {
  late List<Playlist> playlists = []; // 플레이리스트 목록
  late List<Playlist> subscribePlaylists = []; // 구독한 플레이리스트 목록
  bool isMyPlaylistSelected = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    isMyPlaylistSelected = widget.isMine;
    _loadPlaylists();
  }

  Future<void> _loadPlaylists() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      playlists = (await fetchPlaylists(true)).cast<Playlist>();

      subscribePlaylists = (await fetchPlaylists(false)).cast<Playlist>();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, '플레이리스트를 불러오는 중 문제가 발생했습니다: $e');
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  Future<void> _createPlaylist(String name, String desc) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await createPlaylist(name, desc);
      await _loadPlaylists();
      if (!mounted) return;
      showErrorDialog(context, '플레이리스트가 생성되었습니다!', title: '성공');
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, '플레이리스트 생성에 실패했습니다: $e');
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _navigateToPlaylistDetail(Playlist playlist) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute<bool>(
        builder: (context) =>
            PlaylistDetailPage(playlistId: playlist.playlistId),
      ),
    );

    if (result == true) {
      await _loadPlaylists(); // 단일화된 함수 호출
    }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      ListView.builder(
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "(${playlist.newsList?.length})",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.close, size: 20),
                                          onPressed: () async {
                                            bool isDeleted =
                                                await showDeleteDialog(
                                              context: context,
                                              message: isMyPlaylistSelected
                                                  ? "플레이리스트를 삭제하시겠습니까?"
                                                  : "구독을 취소하시겠습니까?",
                                              onDelete: () async {
                                                if (isMyPlaylistSelected) {
                                                  await deletePlaylist(
                                                      playlist.playlistId,
                                                      true);
                                                } else {
                                                  await deletePlaylist(
                                                      playlist.playlistId,
                                                      false);
                                                }
                                              },
                                            );

                                            if (isDeleted) {
                                              await _loadPlaylists(); // 삭제 후 목록 갱신
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      playlist.description ?? ' ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Text(
                                          "게시자: ${playlist.userName}",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ));
                        },
                      ),
                      if (isMyPlaylistSelected) // isMyPlaylistSelected일 때만 생성 버튼 표시
                        Align(
                          alignment: Alignment.bottomCenter, // 하단에 고정
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity, // 버튼의 너비를 100%로 설정
                              child: ElevatedButton(
                                onPressed: () {
                                  showPlaylistDialog(context,
                                      (title, description) async {
                                    await _createPlaylist(
                                        title, description); // 입력값 전달
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF4D71F6), // 배경색을 파란색으로 설정
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(20), // 위쪽 왼쪽 모서리 둥글게
                                      topRight:
                                          Radius.circular(20), // 위쪽 오른쪽 모서리 둥글게
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  '플레이리스트 생성',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
