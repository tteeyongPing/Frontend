import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.menu, 'text': '전체'},
    {'icon': Icons.how_to_vote_outlined, 'text': '정치'},
    {'icon': Icons.trending_up_outlined, 'text': '경제'},
    {'icon': Icons.groups_outlined, 'text': '사회'},
    {'icon': Icons.add, 'text': '추가하기'},
  ];

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

  void _onInterestTap(String text) {
    print('$text 클릭됨');

    setState(() {
      _selectedInterest = text; // 선택된 관심사를 변경

      if (text == '전체') {
        _displayedNews = List.from(allNewsData);
      } else if (text == '정치') {
        _displayedNews = List.from(politicsNewsData);
      } else if (text == '경제') {
        _displayedNews = List.from(
            allNewsData.where((news) => news['type'] == '경제').toList());
      } else if (text == '사회') {
        _displayedNews = List.from(societyNewsData);
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
