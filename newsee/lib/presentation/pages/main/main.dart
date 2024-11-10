// MainPage.dart
import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/presentation/widgets/footer/footer.dart';
import 'package:newsee/presentation/pages/homePage/homePage.dart';
import 'package:newsee/presentation/pages/NewsPage/NewsListPage.dart';
import 'package:newsee/presentation/pages/BookmarkPage/BookmarkPage.dart';
import 'package:newsee/presentation/pages/PlaylistPage/PlaylistPage.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // `late`를 사용하여 나중에 초기화하도록 선언
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // `initState`에서 `_pages` 초기화
    _pages = [
      HomePage(),
      NewsListPage(),
      BookmarkPage(),
      PlaylistPage(),
      MyPage(
          onNavigateToNews: () => _onItemTapped(1),
          onNavigateToBookmark: () => _onItemTapped(2)), // 콜백 전달
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
      body: Column(
        children: [
          Header(),
          Divider(
            thickness: 1,
            color: Color(0xFFD3D3D3),
          ),
          Expanded(
            child: _pages[_selectedIndex],
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
