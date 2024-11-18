import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class Interest {
  final int categoryId;
  final String categoryName;
  final IconData icon;

  Interest({
    required this.categoryId,
    required this.categoryName,
    required this.icon,
  });
}

class News {
  final String company;
  final String title;
  final String shorts;

  News({
    required this.company,
    required this.title,
    required this.shorts,
  });
}

class NewsListPage extends StatefulWidget {
  const NewsListPage({super.key});

  @override
  NewsListPageState createState() => NewsListPageState();
}

class NewsListPageState extends State<NewsListPage> {
  // Interest 객체 리스트로 관심사 정의
  final List<Interest> interests = [
    Interest(
        categoryId: 1, categoryName: '정치', icon: Icons.how_to_vote_outlined),
    Interest(
        categoryId: 2, categoryName: '경제', icon: Icons.trending_up_outlined),
    Interest(categoryId: 3, categoryName: '사회', icon: Icons.groups_outlined),
    Interest(categoryId: 4, categoryName: '국제', icon: Ionicons.earth_sharp),
    Interest(
        categoryId: 5,
        categoryName: '스포츠',
        icon: Icons.sports_basketball_outlined),
    Interest(
        categoryId: 6, categoryName: '문화/예술', icon: Icons.palette_outlined),
    Interest(
        categoryId: 7, categoryName: '과학/기술', icon: Icons.science_outlined),
    Interest(
        categoryId: 8, categoryName: '건강/의료', icon: Ionicons.fitness_outline),
    Interest(
        categoryId: 9,
        categoryName: '연예/오락',
        icon: Icons.mic_external_on_outlined),
    Interest(categoryId: 10, categoryName: '환경', icon: Typicons.leaf),
  ];

  final List<News> _displayedNews = [];
  bool _isLoading = false;
  late ScrollController _scrollController;

  // 선택된 관심사를 저장하는 변수
  Interest? _selectedInterest;

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

    // 초기 선택된 관심사 설정 (예: 첫 번째 관심사)
    _selectedInterest = interests[0];
  }

  void _onInterestTap(Interest selected) {
    setState(() {
      _selectedInterest = selected;

      // 관심사에 따라 _displayedNews를 필터링하거나 초기화
      _displayedNews.clear();
      _loadMoreNews(); // 예시: 기존 데이터 유지
    });
  }

  void _loadMoreNews() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (_displayedNews.length < 10) {
          // Mock data 추가
          _displayedNews.addAll(
            List.generate(
              4,
              (index) => News(
                company: '회사 ${_displayedNews.length + index + 1}',
                title: '제목 ${_displayedNews.length + index + 1}',
                shorts: '내용 요약 ${_displayedNews.length + index + 1}',
              ),
            ),
          );
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
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
                  offset: const Offset(0, 6),
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
                  final isSelected = _selectedInterest == interest;

                  return GestureDetector(
                    onTap: () => _onInterestTap(interest),
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
                                  ? const Color(0xFFD0D9F6)
                                  : const Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              interest.icon,
                              size: screenWidth * 0.1,
                              color: isSelected
                                  ? const Color(0XFF0038FF)
                                  : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            interest.categoryName,
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: isSelected
                                  ? const Color(0XFF0038FF)
                                  : Colors.black,
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
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _displayedNews.length,
              itemBuilder: (context, index) {
                final news = _displayedNews[index];
                return Container(
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
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            news.company,
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            _selectedInterest?.categoryName ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.blue),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(news.title, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        news.shorts.length > 43
                            ? '${news.shorts.substring(0, 43)}...'
                            : news.shorts,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
