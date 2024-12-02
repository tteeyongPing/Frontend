import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/presentation/pages/news_page/news_list_page.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToNews; // 콜백 타입 정의

  const HomePage({
    required this.onNavigateToNews,
  });
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> interests;
  bool isLoading = false;
  List<Map<String, dynamic>> sliderData = [];

  final PageController _pageController = PageController();
  int _currentIndex = 0;
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

  Future<void> loadBanner() async {
    setState(() => isLoading = true);
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/banner/list');
      var response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          sliderData = List<Map<String, dynamic>>.from(data['data'].asMap().map(
            (index, item) {
              return MapEntry(index, {
                'imageUrl': item['imageUrl'],
                'title': item['title'],
                'shorts': item['shorts'],
              });
            },
          ).values);
        });
      } else {
        _showErrorDialog('관심사를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
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
          interests = List<Map<String, dynamic>>.from(data['data'].asMap().map(
            (index, item) {
              return MapEntry(index, {
                'categoryId': item['categoryId'],
                'icon': icons[(item['categoryId'] % icons.length)],
                'text': item['categoryName'],
              });
            },
          ).values);
        });
      } else {
        _showErrorDialog('관심사를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    interests = [];
    // Future.wait()을 사용하여 비동기 함수들이 완료될 때까지 기다립니다.
    Future.wait([loadMyInterests()]).then((_) {
      setState(() {
        // 완료된 후 UI 업데이트
      });
    });
    loadBanner();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onInterestTap(String text, int id) {
    print(id);
    widget.onNavigateToNews(id);
    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewsListPage(
                initialSelectedInterestId: id,
              )),
    );*/
    print('$text 클릭됨');
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
                              Image.network(
                                "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fpng.pngtree.com%2Fthumb_back%2Ffw800%2Fbackground%2F20210902%2Fpngtree-blue-technology-news-background-image_782264.jpg&type=l340_165",
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.5),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 30),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly, // spaceEvenly 유지
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30),
                                      child: Container(
                                        width: double.infinity, // 전체 너비 100%
                                        child: Text(
                                          "오늘의 뉴스",
                                          //sliderData[index]['title']!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ),
                                    if (sliderData[index]['title'] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30),
                                        child: Container(
                                          width: double.infinity, // 전체 너비 100%
                                          child: Text(
                                            sliderData[index]['title']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 27,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    if (sliderData[index]['title'] != null)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 30),
                                        child: Container(
                                          width: double.infinity, // 전체 너비 100%
                                          child: Text(
                                            sliderData[index]['shorts']!,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              height: 1.5,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              )
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
                          padding: const EdgeInsets.only(left: 20, top: 10),
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
                              itemCount:
                                  interests.length + 1, // 아이템 수에 1을 더해줍니다.
                              itemBuilder: (context, index) {
                                // 마지막 인덱스일 경우 '추가하기' 버튼을 보여줍니다.
                                if (index == interests.length) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                SelectInterests(
                                                    visibilityFlag: -1)),
                                      );

                                      if (result == true) {
                                        loadMyInterests(); // 돌아왔을 때 목록 다시 로드
                                      }
                                    },
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
                                              Icons.add,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 0),
                                          Text(
                                            "추가하기",
                                            style: TextStyle(fontSize: 16),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }

                                // 나머지 아이템은 interests에서 가져옵니다.
                                return GestureDetector(
                                  onTap: () => _onInterestTap(
                                      interests[index]['text']!,
                                      interests[index]['categoryId']),
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
                          padding: const EdgeInsets.all(24),
                          child: SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                barGroups: [
                                  // 이번 주 데이터
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 9,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 4,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 2,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 5,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 3,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 6,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 4,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 8,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 5,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 7,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 6,
                                    barRods: [
                                      BarChartRodData(
                                        toY: 3,
                                        color: Colors.blue,
                                        width: 20,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 1,
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
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < days.length) {
                                          return Text(
                                            days[value.toInt()],
                                            style:
                                                const TextStyle(fontSize: 12),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border:
                                      Border.all(color: Colors.grey, width: 1),
                                ),
                                gridData: FlGridData(show: true),
                                barTouchData: BarTouchData(
                                  touchTooltipData: BarTouchTooltipData(
                                    // tooltipBgColor: Colors.blueAccent,
                                    getTooltipItem:
                                        (group, groupIndex, rod, rodIndex) {
                                      return BarTooltipItem(
                                        rod.toY.toString(),
                                        const TextStyle(color: Colors.white),
                                      );
                                    },
                                  ),
                                ),
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
