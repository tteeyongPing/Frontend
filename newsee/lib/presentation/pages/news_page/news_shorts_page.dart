import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'news_origin_page.dart';
import 'package:newsee/models/news_counter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK

String title = "";
String content = "";

class PlaylistDialog extends StatefulWidget {
  final List<Playlist> playlists;
  final int newsId;
  PlaylistDialog({Key? key, required this.playlists, required this.newsId})
      : super(key: key);

  @override
  _PlaylistDialogState createState() => _PlaylistDialogState();
}

Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}

class _PlaylistDialogState extends State<PlaylistDialog> {
  bool _isLoading = false;
  int selectedIndex = -1; // 선택된 항목 인덱스 초기화
  Future<void> _addNews(int PlaylisyId, int NewsId) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/playlist/news/add');
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          "playlistId": PlaylisyId,
          "newsIdList": [NewsId]
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
      } else {
        //showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      //showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero, // 팝업 외부 패딩 제거
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // 테두리 둥글게
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 팝업 테두리 둥글게
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        width: 300, // 원하는 너비
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16), // 위쪽 테두리 둥글게
                ),
              ),
              child: const Text(
                '뉴스를 추가하고자 하는\n플레이리스트를 선택해주세요.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            // 내용 영역
            Container(
              width: double.infinity,
              height: 400, // 원하는 높이
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: widget.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = widget.playlists[index];
                        bool isSelected = selectedIndex == playlist.playlistId;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(playlist.playlistName),
                            subtitle: Text(playlist.description),
                            onTap: () {
                              setState(() {
                                selectedIndex = playlist.playlistId;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            // 하단 버튼 영역
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey), // 위쪽 테두리
                        right: BorderSide(color: Colors.grey), // 오른쪽 테두리
                      ),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20), // 왼쪽 위 둥글게
                          ),
                        ),
                        padding: EdgeInsets.zero,
                      ),
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
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey), // 위쪽 테두리
                        left: BorderSide(color: Colors.grey), // 왼쪽 테두리
                      ),
                    ),
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(20), // 오른쪽 위 둥글게
                          ),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        _addNews(selectedIndex, widget.newsId);
                        Navigator.pop(context);
                      },
                      child: const Text("뉴스 추가",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

late List<Playlist> playlists = []; // 플레이리스트 목록
bool isBookmark = false;

class NewsShortsPage extends StatefulWidget {
  final int newsId;

  const NewsShortsPage({super.key, required this.newsId});

  @override
  _NewsShortsPageState createState() => _NewsShortsPageState();
}

class _NewsShortsPageState extends State<NewsShortsPage> {
  late Map<String, dynamic>? news = null; // news를 nullable로 설정
  bool _isLoading = false;

  // View count recording
  Future<void> _recordViewCount() async {
    await NewsCounter.recordNewsCount(widget.newsId);
  }

  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'userId': prefs.getInt('userId'),
    };
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
        print(playlists.toString());
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
                //await _navigateToAddPlaylist(_title, _description);

                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('생성'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _isBookmark() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/bookmark/status?newsId=${widget.newsId}');
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
          isBookmark = data['data'];
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

// Fetch news data
  Future<void> changeBookmark() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      final String? token = credentials['token'];
      final String url = isBookmark
          ? '${RootUrlProvider.baseURL}/bookmark/delete'
          : '${RootUrlProvider.baseURL}/bookmark/add';

      final response = await (isBookmark ? http.delete : http.post)(
        Uri.parse(url),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode([
          {'newsId': widget.newsId}
        ]),
      );

      if (response.statusCode == 200) {
        final successMessage = isBookmark ? '북마크 삭제 성공.' : '북마크 등록 성공.';
        showErrorDialog(
          context,
          successMessage,
        );
        isBookmark = !isBookmark;
      } else {
        final errorMessage = isBookmark ? '북마크 삭제 실패.' : '북마크 등록 실패.';
        showErrorDialog(context, errorMessage);
      }
    } catch (e) {
      debugPrint('Error updating bookmark: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

/*돌아와 */
  void _addPlaylist(BuildContext context) async {
    await _loadMyPlaylist();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlaylistDialog(
          playlists: playlists,
          newsId: widget.newsId,
        );
      },
    );
  }

// Fetch news data
  Future<void> addBookmark() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/bookmark/add');
      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode([
          {
            'newsId': widget.newsId,
          }
        ]),
      );

      if (response.statusCode == 200) {
        showErrorDialog(context, '북마크 등록 성공.');
      } else {
        showErrorDialog(context, '북마크 등록 실패.');
      }
    } catch (e) {
      debugPrint('Error loading news data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Fetch news data
  Future<void> _loadShortsPage() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/news/shorts?newsId=${widget.newsId}');
      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          news = {
            'category': data['data']['category'],
            'title': data['data']['title'],
            'date': data['data']['date'],
            'content': data['data']['content'],
            'company': data['data']['company'],
            'shorts': data['data']['shorts'],
            'reporter': data['data']['reporter'],
          };
          title = data['data']['title'];
          content = data['data']['content'];
        });
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading news data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      print(title);
      print(content);
      setState(() => _isLoading = false);
    }
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
                  text: 'Newsee\n친구가 뉴스를 공유했어요!\n$title',
                  link: Link(),
                  buttonTitle: "뉴스 보러가기"));
          await ShareClient.instance.launchKakaoTalk(uri);
          print('카카오톡 공유 완료');
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      } else {
        try {
          Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
              template: TextTemplate(
                  text: 'Newsee\n친구가 뉴스를 공유했어요!\n$title',
                  link: Link(),
                  buttonTitle: "뉴스 보러가기"));
          await launchBrowserTab(shareUrl, popupOpen: true);
        } catch (error) {
          print('카카오톡 공유 실패 $error');
        }
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  final TextTemplate defaultText = TextTemplate(
    text: '$title\n$content',
    link: Link(),
  );
  // 로그아웃 팝업을 표시하는 메서드
  void showErrorDialog(BuildContext context, String message) {
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
                message,
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
                      child: Text("확인", style: TextStyle(color: Colors.black)),
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

  @override
  void initState() {
    super.initState();
    _loadShortsPage(); // Load the news data when the page is initialized
    _recordViewCount(); // Record the view count when the page is initialized
    _isBookmark();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘
          onPressed: () => Navigator.of(context).pop(), // 뒤로가기 처리
        ),
        title: Text(
          '뉴스 요약',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),

        centerTitle: true, // 제목을 정확히 가운데 정렬
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator()) // 로딩 중 표시
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // If news is null, show an error message
                          if (news == null)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                '뉴스를 불러오는 중 오류가 발생했습니다.',
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          else ...[
                            // Newspaper, Title, and Info Section
                            Container(
                              width: screenWidth,
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, bottom: 4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Newspaper
                                  Text(
                                    news!['company'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.black,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),

                                  // Title
                                  Text(
                                    news!['title'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Date, Reporter, and Buttons Row with Full-Width Bottom Border
                            Container(
                              width: screenWidth,
                              padding: const EdgeInsets.only(
                                  left: 24, right: 24, top: 4, bottom: 16),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey, // Color of the border
                                    width: 1.0, // Thickness of the border
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Date and Reporter Text
                                  Flexible(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date
                                        Text(
                                          news!['date'],
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.black,
                                          ),
                                        ),
                                        // Reporter Name
                                        Text(
                                          news!['reporter'],
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.035,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Buttons Row
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.share),
                                        onPressed: () {
                                          // 공유 기능
                                          share();
                                          /*Share.share(
                                            'Check out this news: ${news!['title']}\n\n${news!['content']}',
                                            subject: news!['company'],
                                          );*/
                                        },
                                      ),
                                      IconButton(
                                        icon: isBookmark
                                            ? const Icon(Icons.bookmark)
                                            : const Icon(Icons.bookmark_border),
                                        onPressed: () {
                                          // 즐겨찾기 기능 추가
                                          changeBookmark();
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.playlist_add),
                                        onPressed: () {
                                          _addPlaylist(context);
                                          // Add more options functionality here
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // News Content
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                news!['shorts'],
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: screenWidth * 0.04,
                                  height: 1.5,
                                ),
                              ),
                            ),

                            // Increased spacing between the news Shorts and the button
                            SizedBox(
                                height: screenWidth *
                                    0.08), // Adjusted for tighter spacing

                            // Button to navigate to News Origin Page
                            Center(
                              child: Container(
                                width: screenWidth * 0.84,
                                height: screenWidth * 0.14,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(
                                          0.25), // 25% opacity for #000000
                                      offset: const Offset(0, 4), // x: 0, y: 4
                                      blurRadius: 4, // blur radius of 4
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NewsOriginPage(
                                            newsId: widget
                                                .newsId), // 123은 예시로 전달한 뉴스 ID입니다.
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    backgroundColor: Color(0xFF333333),
                                  ),
                                  child: const Text(
                                    '원본 기사로 이동',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            )
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
