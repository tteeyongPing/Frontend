import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/presentation/pages/news_page/news_shorts_page.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
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

class _BookmarkPageState extends State<BookmarkPage> {
  List<News> allNewsData = [];
  bool _isLoading = false;
  bool _isEditing = false; // 편집 모드
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBookmarks();
  }

  // 북마크 데이터 로드
  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      final url = Uri.parse('${RootUrlProvider.baseURL}/bookmark/list');
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
          allNewsData = List<News>.from(
            data['data'].map((item) => News.fromJson(item)),
          );
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

  // 선택 상태 토글
  void _toggleSelection(News news) {
    setState(() {
      news.selected = !news.selected;
    });
  }

  Future<bool> deleteBookmark(int newsId) async {
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      final url = Uri.parse('${RootUrlProvider.baseURL}/bookmark/delete');
      print("URL: $url");

      final response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode([
          {
            'newsId': newsId,
          }
        ]),
      );

      if (response.statusCode == 200) {
        debugPrint('Bookmark deleted successfully.');
        return true; // 성공 시 true 반환
      } else {
        debugPrint('Failed to delete bookmark: ${response.body}');
        showErrorDialog(context, '북마크 삭제에 실패했습니다.');
        return false; // 실패 시 false 반환
      }
    } catch (e) {
      debugPrint('Error deleting bookmark: $e');
      showErrorDialog(context, '에러가 발생했습니다: $e');
      return false; // 예외 발생 시 false 반환
    }
  }

  Future<void> deleteSelectedNews() async {
    final selectedNews = allNewsData.where((news) => news.selected).toList();

    for (var news in selectedNews) {
      // 삭제 요청이 실패했을 때 뉴스 항목을 제거하지 않도록 처리
      bool success = await deleteBookmark(news.newsId);
      if (success) {
        setState(() {
          allNewsData.removeWhere((newsItem) => newsItem.newsId == news.newsId);
        });
      }
    }
  }

// 뉴스 카드 위젯
  Widget _buildNewsCard(News news) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsShortsPage(newsId: news.newsId),
          ),
        );
      },
      child: Container(
        height: 140,
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(news.company, style: TextStyle(fontSize: 14)),
                if (_isEditing)
                  GestureDetector(
                    onTap: () => _toggleSelection(news),
                    child: Icon(
                      news.selected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: news.selected ? Color(0xFF4D71F6) : Colors.grey,
                    ),
                  )
                else
                  Text(
                    news.categoryId,
                    style: TextStyle(fontSize: 12, color: Color(0xFF0038FF)),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              news.title.length > 60
                  ? '${news.title.substring(0, 60)}...'
                  : news.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              news.content.length > 40
                  ? '${news.content.substring(0, 40)}...'
                  : news.content,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 40,
              child: Center(
                child: Text(
                  "나의 북마크",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // 본문
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // 상단 툴바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("북마크한 뉴스: ${allNewsData.length}"),
                        GestureDetector(
                          onTap: () async {
                            if (_isEditing) {
                              await deleteSelectedNews();
                              setState(() => _isEditing = false);
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Text(
                            _isEditing ? '삭제' : '편집',
                            style: TextStyle(color: Color(0xFF4D71F6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: allNewsData
                          .map((news) => _buildNewsCard(news))
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// News 모델 클래스
class News {
  final int newsId;
  final String categoryId;
  final String title;
  final String date;
  final String content;
  final String company;
  final String reporter;
  String? shorts;
  bool selected;

  News({
    required this.newsId,
    required this.categoryId,
    required this.title,
    required this.date,
    required this.content,
    required this.company,
    required this.reporter,
    this.shorts,
    this.selected = false,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      newsId: json['id'],
      categoryId: json['category'],
      title: json['title'],
      date: json['date'],
      content: json['content'],
      company: json['company'],
      reporter: json['reporter'],
      shorts: json['shorts'],
      selected: false,
    );
  }
}
