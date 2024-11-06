import 'package:flutter/material.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  final List<Map<String, dynamic>> allNewsData = [
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '정치',
      'title': '보름달 보며 소원 빌기 좋은 곳은 어디?… ‘달맞이 명소’ 6곳',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 가평 별빛정원, SNS서 별의 성지로 입소문 수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '정치',
      'title': '집에서 조용히 쉴래요',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 가평 별빛정원, SNS서 별의 성지로 입소문 수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 3',
      'description': '이것은 세 번째 슬라이드의 내용입니다.',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 4',
      'description': '이것은 네 번째 슬라이드의 내용입니다.',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 5',
      'description': '이것은 다섯 번째 슬라이드의 내용입니다.',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '경제',
      'title': '제목 6',
      'description': '이것은 여섯 번째 슬라이드의 내용입니다.',
    },
  ];

  final List<Map<String, dynamic>> societyNewsData = [
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 3',
      'description': '이것은 세 번째 슬라이드의 내용입니다.',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 4',
      'description': '이것은 네 번째 슬라이드의 내용입니다.',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '사회',
      'title': '제목 5',
      'description': '이것은 다섯 번째 슬라이드의 내용입니다.',
    },
  ];

  final List<Map<String, dynamic>> politicsNewsData = [
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '경제',
      'title': '보름달 보며 소원 빌기 좋은 곳은 어디?… ‘달맞이 명소’ 6곳',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 가평 별빛정원, SNS서 별의 성지로 입소문 수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'type': '경제',
      'title': '집에서 조용히 쉴래요',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 가평 별빛정원, SNS서 별의 성지로 입소문 수원화성 서장대, 성곽의 운치와 야경 일품',
    },
  ];

  List<Map<String, dynamic>> _displayedNews = [];
  bool _isLoading = false;
  late ScrollController _scrollController;
  String _selectedInterest = '전체'; // 선택된 관심사 값을 추적하는 변수

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

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        if (_displayedNews.length < allNewsData.length) {
          _displayedNews.addAll(allNewsData.sublist(
              _displayedNews.length,
              (_displayedNews.length + 4) > allNewsData.length
                  ? allNewsData.length
                  : _displayedNews.length + 4));
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
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
                  child: Center(child: Text("나의 북마크")))),
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
                            return Container(
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
                                    offset: Offset(0, 4), // 그림자 아래로
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
                                        news['newspaper']!,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                      Text(
                                        news['type']!,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Color(0xFF0038FF),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    news['title']!,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    news['description']!.length > 43
                                        ? '${news['description']!.substring(0, 43)}...'
                                        : news['description']!,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.025,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
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
}
