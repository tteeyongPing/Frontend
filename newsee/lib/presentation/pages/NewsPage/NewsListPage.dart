import 'package:flutter/material.dart';
import 'package:newsee/data/SampleNews.dart'; // Import news data
import 'package:newsee/models/News.dart';
import './NewsSummaryPage.dart'; // Import NewsSummaryPage

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

  List<News> _allNewsData = allNewsData; // Dynamic list from imported data
  List<News> _displayedNews = [];
  bool _isLoading = false;
  late ScrollController _scrollController;
  String _selectedInterest = '전체'; // 선택된 관심사 값을 추적하는 변수

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _displayedNews = List.from(allNewsData); // Initially display all news
    _loadMoreNews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreNews();
      }
    });
  }

  void _loadMoreNews() {
    if (_isLoading || _displayedNews.length >= allNewsData.length) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        int nextBatch = (_displayedNews.length + 4) > allNewsData.length
            ? allNewsData.length
            : _displayedNews.length + 4;
        _displayedNews
            .addAll(allNewsData.sublist(_displayedNews.length, nextBatch));
        _isLoading = false;
      });
    });
  }

  void _onInterestTap(String text) {
    setState(() {
      _selectedInterest = text;

      if (text == '전체') {
        _displayedNews = List.from(allNewsData);
      } else if (text == '정치') {
        _displayedNews =
            allNewsData.where((news) => news.categoryId == 1).toList();
      } else if (text == '경제') {
        _displayedNews =
            allNewsData.where((news) => news.categoryId == 2).toList();
      } else if (text == '사회') {
        _displayedNews =
            allNewsData.where((news) => news.categoryId == 3).toList();
      } else {
        _displayedNews = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 관심사 선택 바
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
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: interests.length,
                itemBuilder: (context, index) {
                  final interest = interests[index];
                  final isSelected = _selectedInterest == interest['text'];

                  return GestureDetector(
                    onTap: () => _onInterestTap(interest['text']!),
                    child: Container(
                      width: screenWidth * 0.185,
                      height: screenWidth * 0.185,
                      color: Colors.white,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: screenWidth * 0.17,
                            height: screenWidth * 0.17,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Color(0xFFD0D9F6)
                                  : Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              interest['icon'],
                              size: screenWidth * 0.1,
                              color:
                                  isSelected ? Color(0XFF0038FF) : Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            interest['text']!,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color:
                                  isSelected ? Color(0XFF0038FF) : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  ClipRect(
                    child: Container(
                      width: screenWidth,
                      child: Column(
                        children: _displayedNews.map((news) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                        }).toList(),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
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

  String _getCategoryName(int categoryId) {
    if (categoryId == 1) {
      return '정치';
    } else if (categoryId == 2) {
      return '경제';
    } else if (categoryId == 3) {
      return '사회';
    } else {
      return '기타';
    }
  }
}
