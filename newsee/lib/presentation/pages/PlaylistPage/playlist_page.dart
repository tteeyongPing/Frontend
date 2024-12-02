import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:newsee/presentation/pages/PlaylistPage/playlistDetailPage/playlist_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;

late ScrollController _scrollController;

class PlaylistPage extends StatefulWidget {
  final bool isMine;
  const PlaylistPage({super.key, this.isMine = true});

  @override
  PlaylistPageState createState() => PlaylistPageState();
}

Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}

// 공용 ErrorDialog 유틸 함수
void showErrorDialog(BuildContext context, String message,
    {String? title, String confirmButtonText = '확인'}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title ?? '오류',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            confirmButtonText,
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
  );
}

class PlaylistPageState extends State<PlaylistPage> {
  late List<Playlist> playlists = []; // 플레이리스트 목록
  late List<Playlist> subscribePlaylists = []; // 구독한 플레이리스트 목록
  bool isMyPlaylistSelected = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    print(widget.isMine);
    isMyPlaylistSelected = widget.isMine;
    _loadMyPlaylist();
    _loadSubPlaylist(); // 플레이리스트 데이터 로드
  }

  Future<void> _loadSubPlaylist() async {
    setState(() => _isLoading = true);
    subscribePlaylists.clear();
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url =
          Uri.parse('${RootUrlProvider.baseURL}/playlist/subscribe/list');
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // 나의 플레이리스트 처리
        setState(() {
          subscribePlaylists = List<Playlist>.from(
            data['data'].map((item) => Playlist.fromJson(item)),
          );
        });
        print("Sub");
        print(playlists);
      } else if (response.statusCode == 404) {
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _makeNewPlaylist(BuildContext context) async {
    String _title = "";
    String _description = "";
    TextEditingController titleController = TextEditingController(text: "");
    TextEditingController descriptionController =
        TextEditingController(text: "");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('플레이리스트 생성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 제목 입력
              TextField(
                controller: titleController,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                ),
              ),
              const SizedBox(height: 8),
              // 설명 입력
              TextField(
                controller: descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: '새로운 설명을 입력하세요',
                ),
              ),
            ],
          ),
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
              child: const Text('취소'),
            ),
            // 생성 버튼
            TextButton(
              onPressed: () async {
                // 제목과 설명 업데이트
                _title = titleController.text;
                _description = descriptionController.text;

                // 비동기적으로 다른 함수 호출
                await _navigateToAddPlaylist(_title, _description);

                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('생성'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToAddPlaylist(String name, String desc) async {
    setState(() => _isLoading = true);

    try {
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
            {"playlistName": name, "description": desc, "newsIdList": []}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        _loadMyPlaylist();
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMyPlaylist() async {
    setState(() => _isLoading = true);
    playlists.clear();
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/list');
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // 나의 플레이리스트 처리
        setState(() {
          playlists = List<Playlist>.from(
            data['data'].map((item) => Playlist.fromJson(item)),
          );
        });
        print("My");
        print(playlists);
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _showDeleteMyDialog(int id) async {
    bool isDeleted = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              content: Container(
                width: 260,
                height: 80,
                child: Center(
                  child: Text(
                    "플레이리스트를 삭제하시겠습니까?",
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context, false); // Cancel action returns false
                          },
                          child:
                              Text("취소", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await deleteMyPlaylist(
                                id); // Perform delete operation
                            Navigator.pop(
                                context, true); // Delete action returns true
                          },
                          child:
                              Text("삭제", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false; // Default return value is false if user cancels

    return isDeleted; // Return whether the delete action was successful
  }

  Future<bool> _showDeleteSubDialog(int id) async {
    bool isDeleted = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              content: Container(
                width: 260,
                height: 80,
                child: Center(
                  child: Text(
                    "구독을 취소하시겠습니까?",
                    style: TextStyle(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            right: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(
                                context, false); // Cancel action returns false
                          },
                          child:
                              Text("취소", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: Colors.grey),
                            left: BorderSide(color: Colors.grey, width: 0.5),
                          ),
                        ),
                        child: TextButton(
                          onPressed: () async {
                            await deleteSubPlaylist(
                                id); // Perform delete operation
                            Navigator.pop(
                                context, true); // Delete action returns true
                          },
                          child:
                              Text("삭제", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ) ??
        false; // Default return value is false if user cancels

    return isDeleted; // Return whether the delete action was successful
  }

  Future<void> deleteSubPlaylist(int id) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/subscribe/cancel?playlistId=$id');
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );
      print(url);
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // 나의 플레이리스트 처리
        setState(() {
          subscribePlaylists
              .removeWhere((playlist) => playlist.playlistId == id);
        });
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteMyPlaylist(int id) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/playlist/remove?playlistId=$id');
      final response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));

        // 나의 플레이리스트 처리
        setState(() {
          playlists.removeWhere((playlist) => playlist.playlistId == id);
        });
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

// 플레이리스트 클릭 시 상세 페이지로 이동
  void _navigateToPlaylistDetail(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailPage(playlist: playlist),
      ),
    ).then((_) {
      // 상세 페이지에서 돌아온 후 _loadMyPlaylist() 호출
      _loadSubPlaylist();
    });
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
                ? Center(child: CircularProgressIndicator())
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
                                  // 제목 및 카운트 + 버튼
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
                                                overflow: TextOverflow.ellipsis,
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
                                        icon: const Icon(
                                          Icons.close,
                                          size: 20,
                                        ),
                                        onPressed: () async {
                                          if (isMyPlaylistSelected) {
                                            await _showDeleteMyDialog(
                                                playlist.playlistId);
                                            Navigator.pop(context);
                                          } else {
                                            await _showDeleteSubDialog(
                                                playlist.playlistId);
                                            Navigator.pop(context);
                                          }
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
                            ),
                          );
                        },
                      ),
                      if (isMyPlaylistSelected) // isMyPlaylistSelected일 때만 추가 버튼 표시
                        Align(
                          alignment: Alignment.bottomCenter, // 하단에 고정
                          child: Padding(
                            padding: const EdgeInsets.all(0),
                            child: Container(
                              height: 50,
                              width: double.infinity, // 버튼의 너비를 100%로 설정
                              child: ElevatedButton(
                                onPressed: () {
                                  // 플레이리스트 추가 동작
                                  _makeNewPlaylist(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color(0xFF4D71F6), // 배경색을 파란색으로 설정
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft:
                                          Radius.circular(20), // 위쪽 왼쪽 모서리 둥글게
                                      topRight:
                                          Radius.circular(20), // 위쪽 오른쪽 모서리 둥글게
                                    ),
                                  ),
                                ),
                                child: const Text(
                                  '플레이리스트 추가',
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
