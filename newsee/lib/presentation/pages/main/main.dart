import 'package:flutter/material.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/presentation/widgets/footer/footer.dart';
import 'package:newsee/presentation/pages/homePage/homePage.dart';
import 'package:newsee/presentation/pages/news_page/news_list_page.dart';
import 'package:newsee/presentation/pages/BookmarkPage/BookmarkPage.dart';
import 'package:newsee/presentation/pages/PlaylistPage/playlist_page.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  int? _initialSelectedInterestId = null; // Example initial ID

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(
        onNavigateToNews: (id) =>
            _onItemTappedNews(id), // Pass the correct callback
      ),
      NewsListPage(initialSelectedInterestId: _initialSelectedInterestId),
      BookmarkPage(),
      //PlaylistPage(),
      MyPage(
        onNavigateToNews: () => _onItemTapped(1),
        onNavigateToBookmark: () => _onItemTapped(2),
        onNavigateMyPlaylistPage: () => _onItemTapped(3),
        onNavigateToPlaylistPage: () => _onItemTapped(3),
      ),
    ];
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
      BookmarkPage(),
      //PlaylistPage(),
      MyPage(
        onNavigateToNews: () => _onItemTapped(1),
        onNavigateToBookmark: () => _onItemTapped(2),
        onNavigateMyPlaylistPage: () => _onItemTapped(3),
        onNavigateToPlaylistPage: () => _onItemTapped(3),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: SizedBox.shrink(),
        flexibleSpace: Header(),
        bottom: PreferredSize(
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
