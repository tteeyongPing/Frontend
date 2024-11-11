import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/ProfilePage/ProfilePage.dart';
import 'package:newsee/presentation/pages/MyPage/ProfilePage/EditInterests/EditInterestsPage.dart';
import 'package:newsee/presentation/pages/MyPage/AlertSettingsPage/AlertSettingsPage.dart';

class MyPage extends StatefulWidget {
  final VoidCallback onNavigateToNews;
  final VoidCallback onNavigateToBookmark;

  MyPage({required this.onNavigateToNews, required this.onNavigateToBookmark});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
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
                child: buildNavigationRow("홍길동", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage()), // ProfilePage로 이동
                  );
                }),
              ),
            ),
            SizedBox(height: screenWidth * 0.05),

            // 뉴스 탐색 섹션
            buildSection(
              title: "뉴스 탐색",
              items: [
                buildNavigationRow("마지막 뉴스 이어보기", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
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
                buildNavigationRow("마이 플레이리스트", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                }),
                buildNavigationRow("구독한 플레이리스트", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                }),
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
                        builder: (context) => EditInterestsPage()),
                  );
                }),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: SizedBox(
        width: screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.025,
              ),
              child: Text(
                title,
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
            Column(
              children: items,
            ),
          ],
        ),
      ),
    );
  }
}
