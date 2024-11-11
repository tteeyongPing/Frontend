import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/presentation/widgets/footer/footer.dart';
import 'package:newsee/presentation/pages/homePage/homePage.dart';
import 'package:newsee/presentation/pages/NewsPage/NewsPage.dart';
import 'package:newsee/presentation/pages/BookmarkPage/BookmarkPage.dart';
import 'package:newsee/presentation/pages/PlaylistPage/PlaylistPage.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      NewsPage(),
      BookmarkPage(),
      PlaylistPage(),
      MyPage(
        onNavigateToNews: () => _onItemTapped(1),
        onNavigateToBookmark: () => _onItemTapped(2),
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 색상 고정
        elevation: 0, // 그림자 효과 없애기
        leading: SizedBox.shrink(), // 왼쪽 아이콘 제거
        flexibleSpace: Header(), // Header 위젯을 배치
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Divider의 높이 설정
          child: Divider(
            color: Colors.grey, // Divider 색상 설정
            thickness: 1.0, // Divider 두께 설정
            height: 1.0, // Divider가 차지할 높이 설정
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _pages[_selectedIndex], // 선택된 페이지 표시
          ),
        ],
      ),
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
