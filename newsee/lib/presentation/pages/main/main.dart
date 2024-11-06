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

  // 페이지 목록
  final List<Widget> _pages = [
    HomePage(), // 홈 페이지
    NewsPage(), // 뉴스 보기 페이지
    BookmarkPage(), // 북마크 페이지
    PlaylistPage(), // 플레이리스트 페이지
    MyPage(), // 마이 페이지
  ];

  // 네비게이션 아이템 클릭 시 호출되는 함수
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 상단에 고정된 Header
          Header(),
          Divider(
            thickness: 1, // 두께 설정
            color: Color(0xFFD3D3D3), // 밑줄 색상 설정
          ),

          // 현재 선택된 페이지 표시
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),

      // Footer는 하단에 고정
      bottomNavigationBar: Footer(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
