import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final List<Map<dynamic, dynamic>> sliderData = [
    {
      'image': 'assets/logo.png', // 이미지 경로 (적절한 경로로 변경)
      'title': '제목 1',
      'description': '이것은 첫 번째 슬라이드의 내용입니다.',
    },
    {
      'image': 'assets/logo.png', // 이미지 경로 (적절한 경로로 변경)
      'title': '제목 2',
      'description': '이것은 두 번째 슬라이드의 내용입니다.',
    },
    {
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
    double sliderHeight = screenWidth * 0.5; // 슬라이드 높이 비율 설정 (가로의 50%)

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(67), // 헤더의 높이 설정
        child: Header(), // 기존 헤더 위젯 사용
      ),
      body: SingleChildScrollView(
        // 스크롤 가능한 영역
        child: Column(
          children: [
            SizedBox(
              height: sliderHeight, // 슬라이드 높이 사용
              child: PageView.builder(
                controller: _pageController,
                itemCount: sliderData.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: double.infinity, // 가로를 꽉 채우도록 변경
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          sliderData[index]['image']!,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          color: Colors.black.withOpacity(0.8), // 70% 검은색 오버레이
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              sliderData[index]['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                sliderData[index]['description']!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(height: 20), // 점과 내용 사이의 여백
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                sliderData.length,
                                (dotIndex) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
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
            // 슬라이드 아래의 텍스트 및 관심 분야 그리드
            Container(
              padding: const EdgeInsets.all(16.0), // 상하좌우 여백 추가
              alignment: Alignment.centerLeft, // 왼쪽 정렬
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                children: [
                  Text(
                    '나의 관심분야',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(
                    color: Color(0xFFE8E8E8), // 색상 설정
                    indent: 0, // 왼쪽 여백
                    endIndent: 0, // 오른쪽 여백
                  ),
                  // 그리드 뷰 추가
                  Container(
                    height: 100, // 그리드 높이 설정
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal, // 가로 스크롤
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1, // 가로로 1개씩 표시
                        childAspectRatio: 1.2, // 정사각형 형태로 설정
                        mainAxisSpacing: 2.0, // 아이템 간격 (수직)
                        crossAxisSpacing: 2.0, // 아이템 간격 (수평)
                      ),
                      itemCount: interests.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () =>
                              _onInterestTap(interests[index]['title']!),
                          child: Container(
                            width: 80, // 원하는 너비
                            height: 150, // 원하는 높이
                            color: Colors.white, // 아이템 배경 색상
                            margin: EdgeInsets.symmetric(horizontal: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 75, // 아이콘 컨테이너 너비
                                  height: 75, // 아이콘 컨테이너 높이
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE8E8E8), // 회색 배경
                                    borderRadius:
                                        BorderRadius.circular(20), // 둥글게 하기
                                  ),
                                  child: Icon(
                                    interests[index]['icon'], // 아이콘
                                    size: 40,
                                    color: Colors.black, // 아이콘 색상
                                  ),
                                ),
                                SizedBox(height: 0), // 아이콘과 텍스트 사이의 여백
                                Text(
                                  interests[index]['title']!,
                                  style: TextStyle(fontSize: 14), // 텍스트 크기 조정
                                  textAlign: TextAlign.center, // 텍스트 중앙 정렬
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Container(
                    color: Color(0xFFE8E8E8),
                    width: screenWidth,
                    height: screenWidth * 0.03,
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    '나의 뉴스 소비량',
                    style: TextStyle(fontSize: 18),
                  ),
                  Divider(
                    color: Color(0xFFE8E8E8), // 색상 설정
                    indent: 0, // 왼쪽 여백
                    endIndent: 0, // 오른쪽 여백
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
    );
  }
}
