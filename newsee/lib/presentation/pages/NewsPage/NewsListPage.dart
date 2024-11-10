import 'package:flutter/material.dart';
import 'NewsSummaryPage.dart';
import 'package:newsee/models/News.dart';
import 'package:newsee/data/SampleNews.dart';

class NewsListPage extends StatefulWidget {
  @override
  _NewsListPageState createState() => _NewsListPageState();
}

class _NewsListPageState extends State<NewsListPage> {
  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.menu, 'text': '전체'},
    {'icon': Icons.how_to_vote_outlined, 'text': '정치'},
    {'icon': Icons.trending_up_outlined, 'text': '경제'},
    {'icon': Icons.groups_outlined, 'text': '사회'},
    {'icon': Icons.add, 'text': '추가하기'},
  ];

  List<News> _displayedNews = [];
  bool _isLoading = false;
  late ScrollController _scrollController;
  String _selectedInterest = '전체';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMoreNews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreNews();
      }
    });
  }

  void _loadMoreNews() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (_displayedNews.length < allNewsData.length) {
          _displayedNews.addAll(
            allNewsData.sublist(
              _displayedNews.length,
              (_displayedNews.length + 4) > allNewsData.length
                  ? allNewsData.length
                  : _displayedNews.length + 4,
            ),
          );
        }
        _isLoading = false;
      });
    });
  }

  void _onInterestTap(String text) {
    print('$text 클릭됨');

    setState(() {
      _selectedInterest = text;

      if (text == '전체') {
        _displayedNews = List.from(allNewsData);
      } else if (text == '정치') {
        _displayedNews = allNewsData
            .where((news) => news.categoryId == 1)
            .toList();
      } else if (text == '경제') {
        _displayedNews = allNewsData
            .where((news) => news.categoryId == 3)
            .toList();
      } else if (text == '사회') {
        _displayedNews = allNewsData
            .where((news) => news.categoryId == 2)
            .toList();
      } else {
        _displayedNews = [];
      }
    });
  }

  String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return '정치';
      case 2:
        return '사회';
      case 3:
        return '경제';
      default:
        return '기타';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 관심사 선택 위젯 (기존 코드 유지)
          // ...

          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  ClipRect(
                    child: Container(
                      width: screenWidth,
                      child: Column(
                        children: _displayedNews.map(
                          (news) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsSummaryPage(news: news),
                                  ),
                                );
                              },
                              child: Container(
                                width: screenWidth * 0.9,
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
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // 뉴스 아이템 UI
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          news.newspaper,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                          ),
                                        ),
                                        Text(
                                          _getCategoryName(news.categoryId),
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.03,
                                            color: Color(0xFF0038FF),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      news.title,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      news.summary.length > 43
                                          ? '${news.summary.substring(0, 43)}...'
                                          : news.summary,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: screenWidth * 0.025,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
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
