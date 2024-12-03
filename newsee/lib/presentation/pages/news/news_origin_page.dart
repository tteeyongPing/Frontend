import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'package:newsee/presentation/pages/news/news_list_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'package:newsee/models/Playlist.dart'; // Playlist 모델
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK

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

        // 나의 플레이리스트 처리
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

class NewsOriginPage extends StatefulWidget {
  final int newsId;

  const NewsOriginPage({super.key, required this.newsId});

  @override
  State<NewsOriginPage> createState() => _NewsOriginPageState();
}

class _NewsOriginPageState extends State<NewsOriginPage> {
  String _note = ''; // 메모 내용을 저장할 변수
  bool _isLoading = false; // Loading state
  Map<String, dynamic> news = {};

  // Fetch token and userId
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

  // Fetch news data
  Future<void> _loadNewsData() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/news/contents?newsId=${widget.newsId}');
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
          news = data['data'];
        });
      } else {
        showErrorDialog(context, '뉴스 검색 결과가 없습니다.');
      }
    } catch (e) {
      debugPrint('Error loading news data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
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
                  text: 'Newsee\n친구가 뉴스를 공유했어요!\n${news['title']}',
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
                  text: 'Newsee\n친구가 뉴스를 공유했어요!\n${news['title']}',
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
        showErrorDialog(context, successMessage);
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

  // Error dialog
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

// Fetch news data
  Future<void> _loadMemo() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse(
          '${RootUrlProvider.baseURL}/memo/read?newsId=${widget.newsId}');
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
          _note = data['data'];
        });
      } else {}
    } catch (e) {
      debugPrint('Error loading news data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editMemo(String text) async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/memo/edit');
      final response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'newsId': widget.newsId,
          'memo': text,
        }),
      );
      print(url);
      print(jsonEncode({
        'newsId': widget.newsId,
        'memo': text,
      }));
      if (response.statusCode == 200) {
        setState(() {
          _note = text;
        });
      } else {
        showErrorDialog(context, '메모를 저장하는데 실패했습니다.');
      }
    } catch (e) {
      debugPrint('Error loading memo data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeMemo() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/memo/remove');
      final response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'newsId': widget.newsId,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _note = ''; // 메모 삭제
        });
      } else {
        showErrorDialog(context, '메모를 삭제하는데 실패했습니다.');
      }
    } catch (e) {
      debugPrint('Error loading memo data: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _editNote() {
    TextEditingController noteController = TextEditingController(text: _note);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '메모 작성',
            style: TextStyle(
              fontSize: 16, // 제목 폰트 크기
            ),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: noteController,
              maxLines: 5,
              style: const TextStyle(fontSize: 16), // 입력 텍스트 폰트 크기
              decoration: InputDecoration(
                hintText: '뉴스 기사에 대한 메모를 작성하세요.',
                hintStyle: const TextStyle(color: Colors.grey), // 힌트 스타일
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // 둥근 테두리
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color(0xFF4D71F6), width: 2), // 포커스 시 테두리
                ),
                contentPadding: const EdgeInsets.all(12), // 내부 여백
              ),
            ),
          ),
          actions: [
            // 취소 버튼
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                '취소',
                style: TextStyle(color: Colors.red, fontSize: 14), // 취소 버튼 스타일
              ),
            ),
            // 저장 버튼
            ElevatedButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  _editMemo(noteController.text);
                  Navigator.pop(context); // 팝업 닫기
                } else {
                  showErrorDialog(context, '메모 내용이 비어 있습니다.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4D71F6), // 버튼 배경색
                foregroundColor: Colors.white, // 버튼 텍스트 색상
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10), // 버튼 내부 여백
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // 버튼 모서리 둥글게
                ),
              ),
              child: const Text(
                '저장',
                style: TextStyle(fontSize: 14), // 저장 버튼 폰트 크기
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 다이얼로그 모서리 둥글게
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNewsData(); // Load news data when the page is loaded
    _loadMemo();
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
          '뉴스 원본',
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
            // Header

            // Loading state
            if (_isLoading) const Center(child: CircularProgressIndicator()),

            // News Summary Display
            if (!_isLoading && news.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 15),
                      // Company, Title, and Info Section
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
                            const SizedBox(height: 16),
                            // Company
                            Text(
                              news['company'],
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Title
                            Text(
                              news['title'],
                              style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Date, Reporter, and Buttons Row
                      Container(
                        width: screenWidth,
                        padding: const EdgeInsets.only(
                            left: 24, right: 24, top: 4, bottom: 16),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey,
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Date and Reporter Text
                            Flexible(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Date
                                  Text(
                                    news['date'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // Reporter Name
                                  Text(
                                    news['reporter'],
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
                                    share();
                                    // 공유 기능
                                    /*Share.share(
                                      'Check out this news from ${news['company']}:\n\n${news['title']}\n\n${news['content']}',
                                      subject: 'News from ${news['company']}',
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
                                    // 기타 옵션 추가
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                      Icons.add_comment_outlined), // 펜 아이콘
                                  onPressed: _editNote, // 메모 작성 호출
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
                          news['content'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: screenWidth * 0.04,
                            height: 1.5,
                          ),
                        ),
                      ),

                      // Display Notes
                      if (_note.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '메모:\n$_note',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: screenWidth * 0.04,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  _removeMemo();
                                },
                              ),
                            ],
                          ),
                        ),
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
