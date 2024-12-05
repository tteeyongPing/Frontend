import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newsee/models/playlist.dart';
import 'package:newsee/models/news.dart';
import 'package:newsee/presentation/pages/news/news_shorts_page.dart';
import 'package:newsee/presentation/widgets/news_card.dart';
import 'package:newsee/services/playlist_service.dart';
import 'package:newsee/services/share_service.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK
import 'package:url_launcher/url_launcher.dart';

Playlist playlist = Playlist(
  playlistId: 0,
  playlistName: ' ',
  userId: 0,
  userName: ' ',
  subscribers: 0,
);

class PlaylistDetailPage extends StatefulWidget {
  final int playlistId;

  const PlaylistDetailPage({super.key, required this.playlistId});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  String _description = "";
  String _playlistName = "";
  bool _isEditing = false;
  bool isMine = false;
  bool isFavorite = false;
  List<News> selectedNews = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkSubscriptionStatus();
    _loadPlaylistPage();
  }

  Future<void> _loadPlaylistPage() async {
    setState(() {
      isLoading = true; // 데이터 로딩 시작
    });

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url =
          Uri.parse('${RootUrlProvider.baseURL}/playlist/${widget.playlistId}');
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
        print(data);
        setState(() {
          playlist = Playlist.fromJson(data);
          isLoading = false; // 데이터 로딩 완료
        });
      } else {
        setState(() {
          isLoading = false; // 실패 시에도 로딩 종료
        });
        debugPrint('Failed to load playlist data');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // 오류 발생 시에도 로딩 종료
      });
      debugPrint('Error loading news data: $e');
    }
  }

  Future<void> _initializeData() async {
    final credentials = await getTokenAndUserId();
    int? userId = credentials['userId'];

    setState(() {
      isMine = playlist.userId == userId;
      _description = playlist.description!;
      _playlistName = playlist.playlistName;
    });
  }

  Future<void> _editPlaylist() async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      final response = await editPlaylist(
          token!, playlist.playlistId, _playlistName, _description);

      if (response.statusCode == 200) {
        setState(() {
          selectedNews.clear();
        });
      } else {
        debugPrint('Failed to edit playlist: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error editing playlist: $e');
    } finally {}
  }

  Future<void> _checkSubscriptionStatus() async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      final response = await getSubscriptionStatus(token!, playlist.playlistId);

      if (response.statusCode == 200) {
        var data = json.decode(response.body)['data'];
        setState(() {
          isFavorite = !data;
        });
      } else {
        debugPrint(
            'Failed to fetch subscription status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching subscription status: $e');
    } finally {}
  }

  void resetSelected() {
    setState(() {
      if (playlist.newsList != null) {
        for (var news in playlist.newsList!) {
          news.selected = false;
        }
      }
      selectedNews.clear();
    });
  }

  void _toggleEdit() {
    resetSelected();
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // Reset all selected news items when exiting edit mode
        selectedNews.clear();
      }
    });
  }

  // 로그아웃 팝업을 표시하는 메서드
  void _deleteSelectedNews() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          content: const SizedBox(
            width: 260,
            height: 80,
            child: Center(
              child: Text(
                "선택한 뉴스 항목을 삭제하시겠습니까??",
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
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("취소",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                        left: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        for (var news in selectedNews) {
                          deleteNews(news.newsId);
                        }
                        Navigator.pop(context);
                      },
                      child:
                          const Text("삭제", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> changeFavorite(bool subscribe) async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      final response = await changeSubscription(
        token!,
        playlist.playlistId,
        subscribe,
      );

      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !subscribe;
        });
      } else {
        debugPrint('Failed to change favorite: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error changing subscription status: $e');
    } finally {}
  }

  Future<void> deleteNews(int id) async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      final response = await deleteNewsItem(token!, playlist.playlistId, id);

      if (response.statusCode == 200) {
        setState(() {
          playlist.newsList?.removeWhere((news) => news.newsId == id);
          selectedNews.clear();
        });
      } else {
        debugPrint('Failed to delete news: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error deleting news: $e');
    } finally {}
  }

  Future<void> share() async {
    playlists.clear();
    try {
      // 카카오톡 실행 가능 여부 확인
      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        try {
          Uri uri = await ShareClient.instance.shareDefault(
              template: TextTemplate(
                  text: 'Newsee\n친구가 플레이리스트를 공유했어요!\n${playlist.playlistName}',
                  link: Link(),
                  buttons: [
                    Button(
                      title: '플레이리스트 보러가기',
                      link: Link(
                        androidExecutionParams: {
                          'key1': 'playlist',
                          'key2': widget.playlistId.toString()
                        },
                      ),
                    ),
                  ],
                  buttonTitle: "플레이리스트 보러가기"));
          await ShareClient.instance.launchKakaoTalk(uri);
          print('카카오톡 공유 완료');
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      } else {
        try {
          Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
              template: TextTemplate(
                  text: 'Newsee\n친구가 플레이리스트를 공유했어요!\n$title',
                  link: Link(),
                  buttonTitle: "플레이리스트 보러가기"));
          await launchBrowserTab(shareUrl, popupOpen: true);
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      }
    } catch (e) {
      debugPrint('Error loading share: $e');
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    final newsList = playlist.newsList;

    return Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        appBar: AppBar(
          title: Text(
            isMine ? '나의 플레이리스트' : '플레이리스트',
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              color: const Color(0xFFD4D4D4),
              height: 1.0,
            ),
          ),
        ),
        body: Stack(
          children: [
            // Main content
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Description Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      border: Border(
                          //bottom: BorderSide(color: Color(0xFFD4D4D4), width: 1),
                          ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom:
                              BorderSide(color: Color(0xFFD4D4D4), width: 1),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _isEditing
                              ? SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height: 40,
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: _playlistName),
                                    onChanged: (value) {
                                      _playlistName = value;
                                    },
                                    decoration: const InputDecoration(
                                      hintText: '새로운 이름을 입력하세요',
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height: 40,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _playlistName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          const SizedBox(height: 8),
                          _isEditing
                              ? SizedBox(
                                  height: 30,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: TextField(
                                    controller: TextEditingController(
                                        text: _description),
                                    onChanged: (value) {
                                      _description = value;
                                    },
                                    maxLines: 2,
                                    decoration: const InputDecoration(
                                      hintText: '새로운 설명을 입력하세요',
                                      contentPadding:
                                          EdgeInsets.symmetric(vertical: 0),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Container(
                                  height: 30,
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '팔로워: ${playlist.subscribers}명',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '작성자: ${playlist.userName}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '뉴스: ${newsList?.length}개',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  share();
                                },
                                icon: const Icon(Icons.share,
                                    size: 18, color: Colors.white),
                                label: const Text(
                                  '공유하기',
                                  style: TextStyle(
                                      fontSize: 10, color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4D71F6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              isMine
                                  ? ElevatedButton.icon(
                                      onPressed: () {
                                        _toggleEdit();
                                        _editPlaylist();
                                      },
                                      icon: Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: _isEditing
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                      label: Text(
                                        '수정하기',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _isEditing
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isEditing
                                            ? const Color(0xFF4D71F6)
                                            : const Color(0xFFD6D6D6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton.icon(
                                      onPressed: () {
                                        changeFavorite(isFavorite);
                                      },
                                      icon: Icon(
                                        Icons.favorite,
                                        size: 18,
                                        color: isFavorite
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      label: Text(
                                        '구독하기',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isFavorite
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isFavorite
                                            ? const Color(0xFFD6D6D6)
                                            : const Color(0xFF4D71F6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // News List Section
                  if (newsList != null && newsList.isNotEmpty)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: SingleChildScrollView(
                        child: Column(
                          children: newsList.map((news) {
                            return NewsCard(
                              news: news,
                              isEditing: _isEditing,
                              onSelected: (selected) {
                                setState(() {
                                  news.selected = selected;
                                  if (selected) {
                                    selectedNews.add(news);
                                  } else {
                                    selectedNews.remove(news);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (_isEditing && selectedNews.isNotEmpty)
              Align(
                alignment: Alignment.bottomCenter, // 하단에 고정
                child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity, // 버튼의 너비를 100%로 설정
                    child: ElevatedButton(
                      onPressed: _deleteSelectedNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF4D71F6), // 배경색을 파란색으로 설정
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20), // 위쪽 왼쪽 모서리 둥글게
                            topRight: Radius.circular(20), // 위쪽 오른쪽 모서리 둥글게
                          ),
                        ),
                      ),
                      child: const Text(
                        '선택된 뉴스 삭제',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
