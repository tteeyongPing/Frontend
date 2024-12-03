import 'package:flutter/material.dart';
import 'package:newsee/models/Playlist.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/presentation/pages/news_page/news_shorts_page.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK

bool _isEditing = false; // 편집 상태를 추적
final newsList = [];
bool isMine = false;

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late String _description = "";
  late String _playlistName = "";
  bool _isLoading = false;
  bool isFavorite = false;
  // Keep track of selected news items
  List<News> selectedNews = [];

  @override
  void initState() {
    super.initState(); // print(widget.isMine);
    _initializeData();
    isSubscribe();
  }

  Future<void> _initializeData() async {
    final credentials = await getTokenAndUserId();
    int? userId = credentials['userId'];
    print('확인준');
    print(widget.playlist.userId);
    print(userId);
    if (widget.playlist.userId == userId) {
      setState(() {
        isMine = true; // Update the state once the userId check is complete
      });
    } else {
      setState(() {
        isMine = false; // Update the state once the userId check is complete
      });
    }
    setState(() {
      _isEditing = false;
      _description = widget.playlist.description;
      _playlistName = widget.playlist.playlistName;
    });
  }

  Future<void> editMyPlaylist(String name, String description) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/edit');
      final response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "playlistId": widget.playlist.playlistId,
          "playlistName": name,
          "description": description
        }),
      );
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _playlistName = name;
          _description = description;
          selectedNews.clear(); // Clear selected items when editing
        });
      } else {
        //showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      // showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> isSubscribe() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/playlist/subscribe/status?playlistId=${widget.playlist.playlistId}');
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        print(data['data']);
        setState(() {
          isFavorite = !data['data'];
        });
      } else {
        //showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      // showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
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

  Future<void> share() async {
    setState(() => _isLoading = true);
    playlists.clear();
    try {
      // 카카오톡 실행 가능 여부 확인
      bool isKakaoTalkSharingAvailable =
          await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isKakaoTalkSharingAvailable) {
        try {
          Uri uri = await ShareClient.instance.shareDefault(
              template: TextTemplate(
                  text: 'Newsee\n친구가 플레이 리스트를 공유했어요!\n$_playlistName',
                  link: Link(),
                  buttonTitle: "플레이 리스트 보러가기"));
          await ShareClient.instance.launchKakaoTalk(uri);
          print('카카오톡 공유 완료');
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      } else {
        try {
          Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
              template: TextTemplate(
                  text: 'Newsee\n친구가 플레이 리스트를 공유했어요!\n$_playlistName',
                  link: Link(),
                  buttonTitle: "플레이 리스트 보러가기"));
          await launchBrowserTab(shareUrl, popupOpen: true);
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      //showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sharePlaylist() {
    final String shareContent = '''
플레이리스트: ${widget.playlist.playlistName}
설명: $_description
작성자: ${widget.playlist.userName}
뉴스 개수: ${widget.playlist.newsList?.length ?? 0}
    
뉴스 목록:
${widget.playlist.newsList?.map((news) => '- ${news.title}').join('\n') ?? '뉴스가 없습니다.'}
    ''';
    Share.share(shareContent, subject: '플레이리스트 공유');
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
          content: Container(
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
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.grey, width: 0.5),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("취소", style: TextStyle(color: Colors.black)),
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
                      onPressed: () {
                        for (var news in selectedNews) {
                          deleteNews(news.id);
                        }
                        Navigator.pop(context);
                      },
                      child: Text("삭제", style: TextStyle(color: Colors.red)),
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

  Future<void> changeFavorite(bool now, int id) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      Uri url;
      // now에 따라 URL을 다르게 설정
      if (!now) {
        url = Uri.parse(
            '${RootUrlProvider.baseURL}/playlist/subscribe/cancel?playlistId=$id');
      } else {
        url = Uri.parse(
            '${RootUrlProvider.baseURL}/playlist/subscribe?playlistId=$id');
      }
      //print(url);
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      // 응답 상태 코드에 따른 처리
      if (response.statusCode == 200) {
        setState(() {
          isFavorite = !isFavorite;
        }); // 서버로부터 받은 데이터를 기반으로 필요한 작업 수행
        // 예: 상태 업데이트 등
      } else {
        // 서버 응답이 200이 아닐 경우 처리
        debugPrint('Failed to change favorite: ${response.statusCode}');
        //showErrorDialog(context, '오류 발생: ${response.statusCode}');
      }
    } catch (e) {
      // 예외 발생 시 처리
      debugPrint('Error loading bookmarks: $e');
      //showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      // 로딩 상태 해제
      setState(() => _isLoading = false);
    }
  }

  Future<void> deleteNews(int id) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/news/remove');
      final response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'playlistId': widget.playlist.playlistId,
          "newsIdList": [id]
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        print(newsList);
        setState(() {
          widget.playlist.newsList.removeWhere((news) => news.id == id);

          selectedNews.clear(); // Clear selected items when editing
        });
      } else {
        print(response.statusCode);
        //showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      //showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

// 이 함수는 selected를 false로 전부 초기화합니다.
  void resetSelected() {
    setState(() {
      // 모든 news의 selected 값을 false로 설정
      for (var news in widget.playlist.newsList) {
        news.selected = false;
      }
      // selectedNews 리스트 비우기
      selectedNews.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsList = widget.playlist.newsList ?? [];

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
                        bottom: BorderSide(color: Color(0xFFD4D4D4), width: 1),
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
                              ? Container(
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
                              ? Container(
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
                                '팔로워: ${widget.playlist.subscribers}명',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '작성자: ${widget.playlist.userName}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '뉴스: ${newsList.length}개',
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

                                        editMyPlaylist(
                                            _playlistName, _description);
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
                                        changeFavorite(isFavorite,
                                            widget.playlist.playlistId);
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
                  if (newsList.isNotEmpty)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // News list items
                            ...newsList
                                .map((news) => NewsCard(
                                      news: news,
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
                                    ))
                                .toList(),
                          ],
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
                  child: Container(
                    height: 50,
                    width: double.infinity, // 버튼의 너비를 100%로 설정
                    child: ElevatedButton(
                      onPressed: _deleteSelectedNews,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4D71F6), // 배경색을 파란색으로 설정
                        shape: RoundedRectangleBorder(
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

class NewsCard extends StatelessWidget {
  final News news;
  final ValueChanged<bool> onSelected;

  const NewsCard({required this.news, required this.onSelected, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsShortsPage(newsId: news.id),
          ),
        );
      },
      child: Container(
        height: 150,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  news.company ?? 'Unknown',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.black54),
                ),
                if (_isEditing) // Show checkbox when editing
                  GestureDetector(
                    onTap: () {
                      // Toggle checkbox state
                      onSelected(!news.selected);
                    },
                    child: Icon(
                      news.selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: news.selected ? Color(0xFF4D71F6) : Colors.grey,
                    ),
                  )
                else
                  Text(
                    "${news.category ?? 'N/A'}",
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0038FF)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              news.title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              news.content,
              style: const TextStyle(
                  fontSize: 16, color: Colors.grey, height: 1.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
