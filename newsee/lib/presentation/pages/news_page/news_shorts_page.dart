import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'news_origin_page.dart';
import 'package:newsee/models/news_counter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsShortsPage extends StatefulWidget {
  final int newsId;

  const NewsShortsPage({super.key, required this.newsId});

  @override
  _NewsShortsPageState createState() => _NewsShortsPageState();
}

class _NewsShortsPageState extends State<NewsShortsPage> {
  late Map<String, dynamic>? news; // news를 nullable로 설정
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

  @override
  void initState() {
    super.initState();
    _loadShortsPage(); // Load the news data when the page is initialized
    _recordViewCount(); // Record the view count when the page is initialized
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
                                          Share.share(
                                            'Check out this news: ${news!['title']}\n\n${news!['content']}',
                                            subject: news!['company'],
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.bookmark_border),
                                        onPressed: () {
                                          addBookmark();
                                          // Add favorite functionality here
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert),
                                        onPressed: () {
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
