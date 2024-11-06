import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/presentation/widgets/footer/footer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  final List<Map<dynamic, dynamic>> sliderData = [
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png', // 이미지 경로 (적절한 경로로 변경)
      'title': '보름달 보며 소원 빌기 좋은 곳은 어디?… ‘달맞이 명소’ 6곳',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 \n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png', // 이미지 경로 (적절한 경로로 변경)
      'title': '집에서 조용히 쉴래요',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 \n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png', // 이미지 경로 (적절한 경로로 변경)
      'title': '제목 3',
      'description': '이것은 세 번째 슬라이드의 내용입니다.',
    },
  ];

  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.how_to_vote_outlined, 'title': '정치'},
    {'icon': Icons.trending_up_outlined, 'title': '경제'},
    {'icon': Icons.groups_outlined, 'title': '사회'},
    {'icon': Icons.public, 'title': '국제'},
    {'icon': Icons.sports_soccer_outlined, 'title': '스포츠'},
    {'icon': Icons.palette_outlined, 'title': '문화/예술'},
    {'icon': Icons.science_outlined, 'title': '과학/기술'},
    {'icon': FontAwesomeIcons.heartPulse, 'title': '건강/의료'},
    {'icon': Icons.mic_external_on_outlined, 'title': '연예/오락'},
    {'icon': Icons.forest_outlined, 'title': '환경'},
    {'icon': Icons.add, 'title': '추가하기'},
  ];

  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onInterestTap(String title) {
    // 페이지 이동 로직을 여기에 추가
    print('$title 클릭됨');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sliderHeight = screenWidth * 0.6; // 슬라이드 높이 비율 설정 (가로의 60%)

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(67), // 헤더의 높이 설정
        child: Header(), // 기존 헤더 위젯 사용
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: sliderHeight, // 슬라이드 높이 사용
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: sliderData.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: double.infinity,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                sliderData[index]['image']!,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.8),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Container(
                                      width: double.infinity, // 전체 너비 사용
                                      child: Text(
                                        sliderData[index]['newspaper']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Container(
                                      width: double.infinity, // 전체 너비 사용
                                      child: Text(
                                        sliderData[index]['title']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Container(
                                      width: double.infinity,
                                      child: Text(
                                        sliderData[index]['description']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          height: 1.5, // 줄 간격을 늘리기 위한 height 설정
                                        ),
                                        textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      sliderData.length,
                                      (dotIndex) => AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 4.0),
                                        width: 8.0,
                                        height: 8.0,
                                        decoration: BoxDecoration(
                                          color: _currentIndex == dotIndex
                                              ? Color(0xFF619EF7)
                                              : Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8), // 좌우 패딩 추가
                          child: Text(
                            '나의 관심분야',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬
                          ),
                        ),
                        Container(
                          width: double.infinity, // 전체 너비를 차지하도록 설정
                          child: Divider(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 4), // 좌우 패딩 추가
                          child: Container(
                            height: 100,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1.2,
                                mainAxisSpacing: 2.0,
                                crossAxisSpacing: 2.0,
                              ),
                              itemCount: interests.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => _onInterestTap(
                                      interests[index]['title']!),
                                  child: Container(
                                    width: 80,
                                    height: 150,
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            interests[index]['icon'],
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                        ),
                                        SizedBox(height: 0),
                                        Text(
                                          interests[index]['title']!,
                                          style: TextStyle(fontSize: 14),
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
                        SizedBox(height: 20),
                        Container(
                          color: Color(0xFFF2F2F2),
                          width: screenWidth,
                          height: screenWidth * 0.03,
                        ),
                        SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8), // 좌우 패딩 추가
                          child: Text(
                            '나의 관심분야',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.left, // 텍스트를 왼쪽 정렬
                          ),
                        ),
                        Container(
                          width: double.infinity, // 전체 너비를 차지하도록 설정
                          child: Divider(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        Image.asset(
                          'assets/logo.png',
                          width: screenWidth,
                          height: screenWidth * 0.8,
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
    );
  }
}
