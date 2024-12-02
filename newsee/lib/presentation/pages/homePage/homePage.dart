import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/presentation/pages/news_page/news_list_page.dart';
import 'package:intl/intl.dart';

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

  List<int> dailyCounts = [];
  List<String> dates = [];

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

  Future<void> loadChartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dailyTotals =
        prefs.getStringList('daily_total_count_queue') ?? [];

    // 현재 날짜를 기준으로 14일 데이터 생성
    DateTime today = DateTime.now();
    List<String> last14Dates = List.generate(
      14,
      (index) => DateFormat('MM/dd')
          .format(today.subtract(Duration(days: 13 - index))),
    );

    // 데이터 매핑
    List<int> counts = List.generate(14, (index) {
      int queueIndex = dailyTotals.length - 14 + index;
      if (queueIndex >= 0 && queueIndex < dailyTotals.length) {
        return int.tryParse(dailyTotals[queueIndex]) ?? 0;
      }
      return 0; // 없는 데이터는 0으로 설정
    });

    setState(() {
      dates = last14Dates;
      dailyCounts = counts;
    });
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

  void _loadDummyData() {
    DateTime today = DateTime.now();

    // 현재 날짜를 기준으로 14일간의 더미 데이터 생성
    dates = List.generate(
      14,
      (index) => DateFormat('MM/dd')
          .format(today.subtract(Duration(days: 13 - index))),
    );

    // 더미 데이터: 각 날짜에 랜덤 조회수 추가
    dailyCounts =
        List.generate(14, (index) => (index + 1) * 5); // 5, 10, 15, ...
    setState(() {});
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
    _loadDummyData(); // 더미 데이터를 로드합니다.
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
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: Text(
                            '나의 관심분야',
                            style: TextStyle(fontSize: 16),
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
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: SizedBox(
                              width: 1000, // 그래프 가로 길이
                              height: 300, // 그래프 세로 길이
                              child: BarChart(
                                BarChartData(
                                  barGroups: List.generate(
                                    dailyCounts.length,
                                    (index) => BarChartGroupData(
                                      x: index,
                                      barRods: [
                                        BarChartRodData(
                                          toY: dailyCounts[index].toDouble(),
                                          color: Colors.blue,
                                          width: 20,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < dates.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                dates[value.toInt()],
                                                style: const TextStyle(
                                                    fontSize: 10),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        reservedSize: 30,
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
                                    border: Border.all(
                                        color: Colors.grey, width: 1),
                                  ),
                                  gridData: FlGridData(show: true),
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      // tooltipBackgroundColor: Colors.blueAccent,
                                      getTooltipItem:
                                          (group, groupIndex, rod, rodIndex) {
                                        return BarTooltipItem(
                                          '${dates[groupIndex]}: ${rod.toY.toInt()}',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
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
