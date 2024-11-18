import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> sliderData = [
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png', // 적절한 경로로 수정
      'title': '보름달 보며 소원 빌기 좋은 곳은 어디?… ‘달맞이 명소’ 6곳',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 \n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'title': '집에서 조용히 쉴래요',
      'description':
          '경기관광공사, ‘달맞이 명소’ 6곳 추천 \n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    },
    {
      'newspaper': '농민신문생활',
      'image': 'assets/logo.png',
      'title': '제목 3',
      'description': '이것은 세 번째 슬라이드의 내용입니다.',
    },
  ];

  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.how_to_vote_outlined, 'text': '정치'},
    {'icon': Icons.trending_up_outlined, 'text': '경제'},
    {'icon': Icons.groups_outlined, 'text': '사회'},
    {'icon': Ionicons.earth_sharp, 'text': '국제'},
    {'icon': Icons.add, 'text': '추가하기'},
  ];

  final PageController _pageController = PageController();
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

  void _onInterestTap(String text) {
    // print('$text 클릭됨');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double sliderHeight = screenWidth * 0.6;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 슬라이더
                  SizedBox(
                    height: sliderHeight,
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
                                    child: Text(
                                      sliderData[index]['newspaper']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Text(
                                      sliderData[index]['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Text(
                                      sliderData[index]['description']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.left,
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
                              horizontal: 12, vertical: 8),
                          child: Text(
                            '나의 관심분야',
                            style: TextStyle(fontSize: 18),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          child: Divider(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Container(
                            height: 100,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                childAspectRatio: 1.3,
                                mainAxisSpacing: 1.0,
                                crossAxisSpacing: 0,
                              ),
                              itemCount: interests.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () =>
                                      _onInterestTap(interests[index]['text']!),
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
                                          interests[index]['text']!,
                                          style: TextStyle(fontSize: 16),
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
                        const SizedBox(height: 20),
                        // 뉴스 소비량 그래프
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  // 이번 주 데이터
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, 9),
                                      FlSpot(1, 4),
                                      FlSpot(2, 5),
                                      FlSpot(3, 6),
                                      FlSpot(4, 8),
                                      FlSpot(5, 7),
                                      FlSpot(6, 3),
                                    ],
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 4,
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                  // 저번 주 데이터
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, 7),
                                      FlSpot(1, 5),
                                      FlSpot(2, 6),
                                      FlSpot(3, 4),
                                      FlSpot(4, 6),
                                      FlSpot(5, 5),
                                      FlSpot(6, 2),
                                    ],
                                    isCurved: true,
                                    color: Colors.red,
                                    barWidth: 4,
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const days = [
                                          '월',
                                          '화',
                                          '수',
                                          '목',
                                          '금',
                                          '토',
                                          '일'
                                        ];
                                        return Text(
                                          days[value.toInt()],
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 28,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: TextStyle(fontSize: 12),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 6,
                                minY: 0,
                                maxY: 10,
                              ),
                            ),
                          ),
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
