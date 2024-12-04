import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:newsee/presentation/widgets/news_consumption_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/presentation/pages/select_interests/select_interests_page.dart';
import 'package:intl/intl.dart';
import 'package:newsee/services/api_service.dart';
import 'package:logger/logger.dart';

class HomePage extends StatefulWidget {
  final Function(int) onNavigateToNews;

  const HomePage({
    super.key,
    required this.onNavigateToNews,
  });
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late List<Map<String, dynamic>> interests;
  bool isLoading = false;

  List<int> dailyCounts = [];
  List<String> dates = [];
  late ScrollController _scrollController;

  List<Map<String, dynamic>> sliderData = [];

  final PageController _pageController = PageController();
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

  final logger = Logger();

  Future<void> loadBanner() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getBannerList();
      setState(() {
        sliderData = data;
      });
    } catch (e) {
      logger.e('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadMyInterests() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.getMyInterests(icons);
      setState(() {
        interests = data;
      });
    } catch (e) {
      logger.e('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> generateAndSaveDummyData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();

    // 어제까지의 더미 데이터를 생성
    List<String> last13Dates = List.generate(
      13,
      (index) => DateFormat('yyyy-MM-dd')
          .format(today.subtract(Duration(days: 13 - index))),
    );

    // 더미 데이터: 각 날짜에 랜덤 조회수 추가
    List<int> dummyCounts = List.generate(
      13,
      (index) => (index + 1) * 2 - index % 4, // 5, 10, 15, ...
    );

    // SharedPreferences에 저장
    for (int i = 0; i < last13Dates.length; i++) {
      await prefs.setInt('dummy_${last13Dates[i]}', dummyCounts[i]);
      logger.e('Saved dummy data: ${last13Dates[i]} - ${dummyCounts[i]}');
    }
  }

  void loadChartData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime today = DateTime.now();

    // 전날까지의 더미 데이터 가져오기
    List<String> last13Dates = List.generate(
      13,
      (index) => DateFormat('yyyy-MM-dd')
          .format(today.subtract(Duration(days: 13 - index))),
    );

    List<int> counts = [];
    for (String date in last13Dates) {
      int? count = prefs.getInt('dummy_$date');
      counts.add(count ?? 0); // 데이터가 없으면 0으로 추가
      logger.e("Loaded data for $date: ${count ?? 0}");
    }

    // 오늘 날짜 데이터를 계산하여 추가
    String todayDate = DateFormat('yyyy-MM-dd').format(today);
    int todayTotal = 0;

    // SharedPreferences에서 오늘 날짜 데이터 가져오기
    for (String key in prefs.getKeys()) {
      if (key.contains(todayDate)) {
        todayTotal += prefs.getInt(key) ?? 0;
      }
    }

    counts.add(todayTotal); // 오늘 데이터를 추가
    logger.e("Today's data: $todayTotal");

    setState(() {
      dates = [
        ...last13Dates
            .map((date) => DateFormat('MM/dd').format(DateTime.parse(date))),
        DateFormat('MM/dd').format(today),
      ];
      dailyCounts = counts.isEmpty
          ? List.filled(14, 0) // 데이터가 비어있으면 0으로 채움
          : counts;
    });

    logger.e("Final dates: $dates");
    logger.e("Final dailyCounts: $dailyCounts");
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _scrollToRight() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  Future<void> _initializeData() async {
    await generateAndSaveDummyData(); // 더미 데이터 생성 완료 후
    loadChartData(); // 차트 데이터 로드
    loadBanner(); // 배너 데이터 로드
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
    _scrollController = ScrollController(); // 초기화
    _initializeData(); // 데이터 초기화 함수

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToRight(); // 화면 로드 후 오른쪽으로 스크롤
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onInterestTap(String text, int id) {
    logger.e(id);
    widget.onNavigateToNews(id);
    /*Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NewsListPage(
                initialSelectedInterestId: id,
              )),
    );*/
    logger.e('$text 클릭됨');
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
                        return SizedBox(
                          width: double.infinity,
                          child: Stack(fit: StackFit.expand, children: [
                            Image.network(
                              "https://search.pstatic.net/sunny/?src=https%3A%2F%2Fpng.pngtree.com%2Fthumb_back%2Ffw800%2Fbackground%2F20210902%2Fpngtree-blue-technology-news-background-image_782264.jpg&type=l340_165",
                              fit: BoxFit.cover,
                            ),
                            Container(
                              color: Colors.black.withOpacity(0.5),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceEvenly, // spaceEvenly 유지
                                children: [
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 30),
                                    child: SizedBox(
                                      width: double.infinity, // 전체 너비 100%
                                      child: Text(
                                        "오늘의 뉴스",
                                        //sliderData[index]['title']!,
                                        style: TextStyle(
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
                                      child: SizedBox(
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
                                      child: SizedBox(
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
                          ]),
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
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: Text(
                            '나의 관심분야',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: SizedBox(
                            height: 100,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        loadMyInterests(); // 아왔을 때 목록 다시 로드
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
                                              color: const Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              size: 40,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const Text(
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
                                            color: const Color(0xFFF2F2F2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Icon(
                                            interests[index]['icon'],
                                            size: 40,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 0),
                                        Text(
                                          interests[index]['text']!,
                                          style: const TextStyle(fontSize: 16),
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
                        Container(
                          height: kToolbarHeight / 2.6,
                          color: const Color(0xFFF2F2F2), // 원하는 색상
                        ),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          child: Text(
                            'Newsee를 통한 뉴스 소비량',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        NewsConsumptionChart(
                          dailyCounts: dailyCounts,
                          dates: dates,
                          scrollController: _scrollController,
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
