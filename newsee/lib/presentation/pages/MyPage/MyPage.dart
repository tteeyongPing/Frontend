import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/ProfilePage/ProfilePage.dart';
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';
import 'package:newsee/presentation/pages/MyPage/ProfilePage/EditInterests/EditInterestsPage.dart';
import 'package:newsee/presentation/pages/MyPage/AlertSettingsPage/AlertSettingsPage.dart';
import 'package:newsee/presentation/pages/SearchPage/SearchPage.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  final VoidCallback onNavigateToNews;
  final VoidCallback onNavigateToBookmark;
  final VoidCallback onNavigateMyPlaylistPage;
  final VoidCallback onNavigateToPlaylistPage;

  // 생성자 부분에서 각 콜백을 필수 항목으로 받고 있습니다.
  const MyPage({
    required this.onNavigateToNews,
    required this.onNavigateToBookmark,
    required this.onNavigateMyPlaylistPage,
    required this.onNavigateToPlaylistPage,
  });

  @override
  _MyPageState createState() => _MyPageState();
}

// 이름 저장
Future<void> saveUserName(String userName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userName', userName);
}

// 이름 불러오기
Future<String?> getUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName');
}

class _MyPageState extends State<MyPage> {
  bool isLoading = false; // 로딩 상태를 관리하는 변수
  String? nickName; // 사용자 닉네임을 저장할 변수

  @override
  void initState() {
    super.initState();
    loadName(); // 페이지 로드 시 닉네임을 불러오기
  }

  // SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('userId');
    return {'token': token, 'userId': userId};
  }

  // 오류 메시지를 보여주는 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // JSON 파일을 로드하여 관심사 데이터를 초기화
  Future<void> loadName() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/nickname/get');
      var response = await http.patch(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          nickName = data['data']; // 닉네임을 상태에 저장
          saveUserName('$nickName');
        });
      } else {
        _showErrorDialog('닉네임을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('닉네임을 불러오는 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 중복된 InkWell 코드 재사용을 위한 메서드
  Widget buildNavigationRow(String title, {VoidCallback? onTap}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        height: screenWidth * 0.12,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.04,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  // 섹션을 구성하는 메서드 (재사용)
  Widget buildSection({required String title, required List<Widget> items}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...items,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        // 화면이 길어지는 경우 스크롤 가능하게
        child: Column(
          children: [
            // 홍길동 컨테이너
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: SizedBox(
                width: screenWidth,
                height: 48,
                child: buildNavigationRow(
                  nickName ?? '로딩 중...', // nickName이 null일 경우 로딩 중이라고 표시
                  onTap: () async {
                    // ProfilePage로 이동하고 닉네임을 반환받음
                    final updatedNickName = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(),
                      ),
                    );

                    // 반환된 닉네임을 받아서 업데이트
                    if (updatedNickName != null) {
                      setState(() {
                        nickName = updatedNickName; // nickName 업데이트
                        saveUserName(nickName!); // SharedPreferences에 저장
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // 뉴스 탐색 섹션
            buildSection(
              title: "뉴스 탐색",
              items: [
                buildNavigationRow("뉴스 검색하기", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                }),
                GestureDetector(
                  onTap: widget.onNavigateToNews,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02,
                    ),
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "뉴스 목록 보기",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),

            // 나의 뉴스 관리 섹션
            buildSection(
              title: "나의 뉴스 관리",
              items: [
                GestureDetector(
                  onTap: widget.onNavigateToBookmark,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02,
                    ),
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "북마크",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onNavigateMyPlaylistPage,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02,
                    ),
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "뉴스 목록 보기",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onNavigateToPlaylistPage,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.05,
                      vertical: screenWidth * 0.02,
                    ),
                    height: screenWidth * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "뉴스 목록 보기",
                          style: TextStyle(fontSize: screenWidth * 0.04),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: screenWidth * 0.04,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenWidth * 0.05),

            // 설정 섹션
            buildSection(
              title: "설정",
              items: [
                buildNavigationRow("뉴스 알림 설정", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AlertSettingsPage()),
                  );
                }),
                buildNavigationRow("나의 관심 분야 설정", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SelectInterests(visibilityFlag: -1)),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
