import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/presentation/widgets/footer/footer.dart';
import 'package:newsee/presentation/pages/home/home_page.dart';
import 'package:newsee/presentation/pages/news/news_list_page.dart';
import 'package:newsee/presentation/pages/bookmark/bookmark_page.dart';
import 'package:newsee/presentation/pages/playlist/playlist_page.dart';
import 'package:newsee/presentation/pages/mypage/my_page.dart';
// MainPage 임포트

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int? _initialSelectedInterestId; // Example initial ID
  bool _isMine = true;

  @override
  void initState() {
    super.initState();
  }

  void _onItemTappedPlaylistPage(bool id) {
    setState(() {
      _selectedIndex = 3; // Update selected index
      _isMine = id; // Dynamically set the isMine value
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _initialSelectedInterestId = null;
  }

  void _onItemTappedNews(int id) {
    setState(() {
      _selectedIndex = 1; // Update selected index
    });

    // Logic for updating initial interest ID based on the selected news type
    _initialSelectedInterestId = id; // Dynamically set the selected interest ID
    NewsListPage(initialSelectedInterestId: _initialSelectedInterestId);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomePage(
        onNavigateToNews: (id) => _onItemTappedNews(id),
      ),
      NewsListPage(initialSelectedInterestId: _initialSelectedInterestId),
      const BookmarkPage(),
      PlaylistPage(isMine: _isMine),
      MyPage(
        onNavigateToNews: () => _onItemTapped(1),
        onNavigateToBookmark: () => _onItemTapped(2),
        onNavigateMyPlaylistPage: () => _onItemTappedPlaylistPage(true),
        onNavigateToPlaylistPage: () => _onItemTappedPlaylistPage(false),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(),
        flexibleSpace: const Header(),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Colors.grey,
            thickness: 1.0,
            height: 1.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: pages[_selectedIndex], // pages 리스트에서 현재 선택된 페이지 표시
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
