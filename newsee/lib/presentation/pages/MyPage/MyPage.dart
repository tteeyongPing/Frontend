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
  bool isLoading = false;
  String? nickName;

  @override
  void initState() {
    super.initState();
    loadName();
  }

  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('userId');
    return {'token': token, 'userId': userId};
  }

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

  Future<void> loadName() async {
    setState(() => isLoading = true);
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/nickname/get');
      var response = await http.patch(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          nickName = data['data'];
          saveUserName('$nickName');
        });
      } else {
        _showErrorDialog('닉네임을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('닉네임을 불러오는 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildNavigationRow(String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 0,
        ),
        height: kToolbarHeight * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
          children: [
            Text(
              title,
              style: TextStyle(fontSize: kToolbarHeight * 0.3),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: kToolbarHeight * 0.4,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSection({required String title, required List<Widget> items}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, vertical: kToolbarHeight * 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: kToolbarHeight * 0.7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
              children: [
                Text(
                  title,
                  style: TextStyle(
                      fontSize: kToolbarHeight * 0.3,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
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
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: kToolbarHeight * 0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final updatedNickName = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(),
                        ),
                      );

                      if (updatedNickName != null) {
                        setState(() {
                          nickName = updatedNickName;
                          saveUserName(nickName!);
                        });
                      }
                    },
                    child: buildNavigationRow(
                      nickName ?? '로딩 중...',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: kToolbarHeight / 2,
            ),
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
                  child: buildNavigationRow("뉴스 목록 보기"),
                ),
              ],
            ),
            SizedBox(
              height: kToolbarHeight / 2,
            ),
            buildSection(
              title: "나의 뉴스 관리",
              items: [
                GestureDetector(
                  onTap: widget.onNavigateToBookmark,
                  child: buildNavigationRow("북마크"),
                ),
                GestureDetector(
                  onTap: widget.onNavigateMyPlaylistPage,
                  child: buildNavigationRow("내 뉴스 목록 보기"),
                ),
                GestureDetector(
                  onTap: widget.onNavigateToPlaylistPage,
                  child: buildNavigationRow("플레이리스트 보기"),
                ),
              ],
            ),
            SizedBox(
              height: kToolbarHeight / 2,
            ),
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
            SizedBox(
              height: kToolbarHeight / 2,
            ),
          ],
        ),
      ),
    );
  }
}
