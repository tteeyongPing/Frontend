import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'package:newsee/presentation/pages/news_page/news_list_page.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;

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
          title: const Text('메모 작성'),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '뉴스 기사에 대한 메모를 작성하세요.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                if (noteController.text.isNotEmpty) {
                  _editMemo(noteController.text);
                  Navigator.pop(context); // 팝업 닫기
                } else {
                  showErrorDialog(context, '메모 내용이 비어 있습니다.');
                }
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _loadNewsData(); // Load news data when the page is loaded
    _loadMemo();
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
                                    // 공유 기능
                                    Share.share(
                                      'Check out this news from ${news['company']}:\n\n${news['title']}\n\n${news['content']}',
                                      subject: 'News from ${news['company']}',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border),
                                  onPressed: () {
                                    // 즐겨찾기 기능 추가
                                    addBookmark();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.more_vert),
                                  onPressed: () {
                                    // 기타 옵션 추가
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_note), // 펜 아이콘
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
