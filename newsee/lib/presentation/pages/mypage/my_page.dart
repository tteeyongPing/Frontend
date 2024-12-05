import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/mypage/profile/profile_page.dart';
import 'package:newsee/presentation/pages/select_interests/select_interests_page.dart';
import 'package:newsee/presentation/pages/mypage/alert_setting/alert_setting_page.dart';
import 'package:newsee/presentation/pages/search/search_page.dart';
import 'package:newsee/services/my_page_service.dart';

class MyPage extends StatefulWidget {
  final VoidCallback onNavigateToNews;
  final VoidCallback onNavigateToBookmark;
  final VoidCallback onNavigateMyPlaylistPage;
  final VoidCallback onNavigateToPlaylistPage;

  // `key`를 추가하고, super 생성자에 전달
  const MyPage({
    Key? key, // Key를 받아서
    required this.onNavigateToNews,
    required this.onNavigateToBookmark,
    required this.onNavigateMyPlaylistPage,
    required this.onNavigateToPlaylistPage,
  }) : super(key: key); // 부모 클래스의 생성자에 전달

  @override
  MyPageState createState() => MyPageState();
}

class MyPageState extends State<MyPage> {
  bool isLoading = true; // Initially loading
  String? nickName;
  final MyPageService myPageService = MyPageService();

  @override
  void initState() {
    super.initState();
    loadNickName();
  }

  Future<void> loadNickName() async {
    try {
      String? name = await myPageService.loadName();
      setState(() {
        nickName = name;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildNavigationRow(String title, {VoidCallback? onTap}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        height: kToolbarHeight,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFFB0B0B0),
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
      decoration: const BoxDecoration(color: Colors.white),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: 12.0, bottom: 12.0, left: screenWidth * 0.05),
            child: Text(title, style: const TextStyle(fontSize: 16)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget buildProfileHeader() {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      height: kToolbarHeight,
      padding: EdgeInsets.zero,
      child: buildNavigationRow(
        isLoading ? '로딩 중...' : (nickName ?? '닉네임 없음'),
        onTap: () async {
          final updatedNickName = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePage()),
          );
          if (updatedNickName != null) {
            setState(() {
              nickName = updatedNickName;
            });
          }
        },
      ),
    );
  }

  Widget buildSizedBox() {
    return const SizedBox(height: kToolbarHeight / 2.6); // 중복되는 SizedBox
  }

  Widget buildSectionWithItems(String title, List<Widget> items) {
    return buildSection(title: title, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProfileHeader(),
            buildSizedBox(), // 중복된 SizedBox 사용
            buildSectionWithItems(
              "뉴스 탐색",
              [
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
            buildSizedBox(), // 중복된 SizedBox 사용
            buildSectionWithItems(
              "나의 뉴스 관리",
              [
                GestureDetector(
                  onTap: widget.onNavigateToBookmark,
                  child: buildNavigationRow("북마크"),
                ),
                GestureDetector(
                  onTap: widget.onNavigateMyPlaylistPage,
                  child: buildNavigationRow("마이 플레이리스트 보기"),
                ),
                GestureDetector(
                  onTap: widget.onNavigateToPlaylistPage,
                  child: buildNavigationRow("구독한 플레이리스트 보기"),
                ),
              ],
            ),
            buildSizedBox(), // 중복된 SizedBox 사용
            buildSectionWithItems(
              "설정",
              [
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
            buildSizedBox(), // 중복된 SizedBox 사용
          ],
        ),
      ),
    );
  }
}
