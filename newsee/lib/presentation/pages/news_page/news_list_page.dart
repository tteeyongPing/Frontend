import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/presentation/pages/news_page/news_shorts_page.dart';

// 텍스트의 실제 렌더링 길이를 기반으로 자르는 함수
String getTruncatedContent(String content, double maxWidth, TextStyle style) {
  final textPainter = TextPainter(
    text: TextSpan(text: content, style: style),
    textDirection: TextDirection.ltr,
    maxLines: 1, // 한 줄로 자르기
  );

  textPainter.layout(maxWidth: maxWidth);

  if (textPainter.size.width <= maxWidth) {
    return content; // 텍스트가 제한된 넓이에 맞다면 그대로 반환
  } else {
    // 텍스트가 제한된 넓이를 초과하면 잘라서 반환
    return content.substring(0, content.length - 3) + '...';
  }
}

// Example News Model
class News {
  final int id;
  final String category;
  final String company;
  final String title;
  final String content;
  final String reporter;
  final String date;

  News({
    required this.id,
    required this.category,
    required this.company,
    required this.title,
    required this.content,
    required this.reporter,
    required this.date,
  });
}

class Interest {
  final String categoryName;
  final int categoryId;
  final IconData icon;

  Interest({
    required this.categoryName,
    required this.categoryId,
    required this.icon,
  });
}

class NewsListPage extends StatefulWidget {
  final int? initialSelectedInterestId;

  // 생성자에서 initialSelectedInterest를 받아옵니다.
  NewsListPage({this.initialSelectedInterestId});

  @override
  NewsListPageState createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
  late List<Interest> interests = [];
  bool isLoading = false;

  final List<News> _displayedNews = [];
  late ScrollController _scrollController;
  Interest? _selectedInterest;

  final List<IconData> icons = [
    Icons.add,
    Icons.trending_up_outlined,
    Icons.mic_external_on_outlined,
    Icons.groups_outlined,
    Ionicons.fitness_outline,
    Icons.science_outlined,
    Icons.sports_basketball_outlined,
    Icons.palette_outlined,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        // _loadMoreNews();
      }
    });

    print(widget.initialSelectedInterestId);

    _displayedNews.clear();
    loadNews(true, 0);
    loadMyInterests().then((_) {
      if (widget.initialSelectedInterestId != null) {
        setState(() {
          _selectedInterest = interests.firstWhere(
            (interest) =>
                interest.categoryId == widget.initialSelectedInterestId,
            orElse: () => interests[0], // 기본 관심사를 선택
          );
          _displayedNews.clear();
          loadNews(false, _selectedInterest!.categoryId);
        });
      } else {
        _selectedInterest = null;
      }
    });
  }

  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'userId': prefs.getInt('userId'),
    };
  }

  Future<void> loadMyInterests() async {
    setState(() => isLoading = true);
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/category/my');
      var response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          interests = List<Interest>.from(data['data'].map((item) {
            return Interest(
              categoryId: item['categoryId'],
              categoryName: item['categoryName'],
              icon: icons[(item['categoryId'] % icons.length)],
            );
          }));
        });
      } else {
        _showErrorDialog('Failed to load interests.');
      }
    } catch (e) {
      print('Error occurred: $e');
      _showErrorDialog('Error while fetching data.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadNews(bool all, int id,
      {int offset = 0, int limit = 10}) async {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];
    var url = Uri.parse(
        '${RootUrlProvider.baseURL}/news/list${all ? "/all" : "?category=$id&offset=$offset&limit=$limit"}');

    http.Response response;
    response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _displayedNews.addAll(List<News>.from(data['data'].map((item) {
          return News(
            id: item['id'],
            category: item['category'],
            title: item['title'],
            date: item['date'],
            content: item['content'],
            company: item['company'],
            reporter: item['reporter'],
          );
        })));
      });
    } else {
      _showErrorDialog('Failed to load news.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onInterestTap(Interest selected) {
    setState(() {
      _selectedInterest = selected;
      _displayedNews.clear();
      loadNews(false, _selectedInterest!.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          // Interest selection grid (All, Add buttons, and Interests)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              height: 100,
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  childAspectRatio: 1.3,
                  mainAxisSpacing: 1.0,
                  crossAxisSpacing: 0,
                ),
                itemCount: interests.length + 2, // 'All' and 'Add' buttons
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return GestureDetector(
                      onTap: () {
                        _selectedInterest = null;
                        _displayedNews.clear();
                        loadNews(true, 0);
                        // Load all news
                      },
                      child: Container(
                        width: 80,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: _selectedInterest == null
                                    ? Color(0xFFD0D9F6)
                                    : const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.view_list, // "All" button icon
                                size: 40,
                                color: _selectedInterest == null
                                    ? Color(0xFF0038FF)
                                    : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "전체",
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedInterest == null
                                    ? Color(0xFF0038FF)
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (index == interests.length + 1) {
                    return GestureDetector(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SelectInterests(visibilityFlag: -1)),
                        );

                        if (result == true) {
                          loadMyInterests(); // Reload the list after adding interest
                        }
                      },
                      child: Container(
                        width: 80,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.add, // "Add" button icon
                                size: 40,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "추가",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final interest = interests[index - 1]; // Offset by 1
                  return GestureDetector(
                    onTap: () => _onInterestTap(interest),
                    child: Container(
                      width: 80,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: _selectedInterest == interest
                                  ? Color(0xFFD0D9F6)
                                  : const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              interest.icon,
                              size: 40,
                              color: _selectedInterest == interest
                                  ? Color(0xFF0038FF)
                                  : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            interest.categoryName,
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedInterest == interest
                                  ? Color(0xFF0038FF)
                                  : Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // News List
          isLoading
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _displayedNews.length,
                  itemBuilder: (context, index) {
                    final news = _displayedNews[index];
                    return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NewsShortsPage(newsId: news.id)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 10, left: 24, right: 24, bottom: 10),
                          padding: const EdgeInsets.only(
                              top: 12,
                              left: 17,
                              right: 17,
                              bottom: 12), // 패딩 설정
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 8,
                                offset: const Offset(0, 4), // 그림자 위치
                              ),
                            ],
                          ),
                          child: SizedBox(
                            height: 113, // 고정 높이 설정
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      news.company,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                Text(
                                  news.title.runes.take(1500).length > 60
                                      ? '${String.fromCharCodes(news.title.runes.take(1000).toList()).substring(0, 51)}...'
                                      : news.title,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                                Text(
                                  news.content.length > 43
                                      ? '${news.content.substring(0, 53)}...' // 내용이 길면 잘라서 표시
                                      : news.content,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                )),
        ],
      ),
    );
  }
}
