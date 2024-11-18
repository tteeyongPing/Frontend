import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/data/SampleNews.dart';
import 'package:newsee/models/News.dart';
import 'package:newsee/presentation/pages/news_page/news_shorts_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<News> _searchResults = [];
  List<News> _allNewsData = allNewsData; // SampleNews.dart에서 가져온 데이터

  List<String> _recentSearches = [];
  FocusNode _focusNode = FocusNode();
  bool isSearchOpen = false;
  bool isNewsSelected = true; // '뉴스'가 기본적으로 선택되도록

  // 최근 검색어를 SharedPreferences에서 불러오기
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

  // 최근 검색어를 SharedPreferences에 저장하기
  Future<void> _saveRecentSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!_recentSearches.contains(query)) {
      if (_recentSearches.length >= 5) {
        _recentSearches.removeAt(0); // 최대 5개까지만 저장
      }
      _recentSearches.add(query);
      await prefs.setStringList('recentSearches', _recentSearches);
    }
  }

  void _searchItems(String query) {
    setState(() {
      if (isNewsSelected) {
        _searchResults = _allNewsData
            .where((news) =>
                news.title.toLowerCase().contains(query.toLowerCase()) ||
                news.shorts.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        // 플레이리스트에 대한 검색 로직 추가 (가정)
        _searchResults = _allNewsData
            .where((news) =>
                news.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addRecentSearch(String query) {
    _saveRecentSearch(query);
  }

  void _toggleSearchList() {
    setState(() {
      isSearchOpen = !isSearchOpen;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _focusNode.addListener(() {
      setState(() {
        isSearchOpen = _focusNode.hasFocus; // 포커스가 있을 때 최근 검색어 목록 열기
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.15),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '뉴스 또는 플레이리스트 검색',
                  border: InputBorder.none,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    _searchItems(query);
                    _addRecentSearch(query);
                    _focusNode.unfocus(); // 검색 완료 후 포커스 해제
                  }
                },
                onTap: () {
                  setState(() {
                    isSearchOpen = !isSearchOpen; // 상태를 토글하여 최근 검색어 목록 열기/닫기
                  });
                  _focusNode.unfocus(); // 검색 아이콘 클릭 시 포커스 해제
                },
                onChanged: (query) {
                  setState(() {
                    _searchItems(query);
                  });
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              String query = _searchController.text;
              if (query.isNotEmpty) {
                _searchItems(query);
                _addRecentSearch(query);
              }
              setState(() {
                isSearchOpen = !isSearchOpen; // 상태를 토글하여 최근 검색어 목록 열기/닫기
              });
              _focusNode.unfocus(); // 검색 아이콘 클릭 시 포커스 해제
            },
            child: Icon(
              Icons.search,
              color: Color(0xFF0038FF),
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (isSearchOpen) {
            setState(() {
              isSearchOpen = false; // 외부 클릭 시 최근 검색어 창 닫기
            });
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // 탭을 추가하여 '뉴스'와 '플레이리스트' 선택
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNewsSelected = true; // 뉴스 선택
                        });
                        _searchItems(_searchController.text);
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        color: Colors.white,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Center(
                              child: Text(
                                '관련된 뉴스',
                                style: TextStyle(
                                  fontWeight: isNewsSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 16,
                                  color: isNewsSelected
                                      ? Colors.black
                                      : Color(0xFF707070),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNewsSelected = false; // 플레이리스트 선택
                        });
                        _searchItems(_searchController.text);
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            '관련된 플레이리스트',
                            style: TextStyle(
                              fontWeight: !isNewsSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                              color: !isNewsSelected
                                  ? Colors.black
                                  : Color(0xFF707070),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // 탭과 구분선 추가
                !isNewsSelected
                    ? Container(
                        width: screenWidth * 1, // 원하는 width 설정
                        alignment: Alignment.centerRight, // 오른쪽 정렬
                        child: Container(
                          width: screenWidth * 0.5,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.025,
                                right: screenWidth * 0.025), // 왼쪽 여백 설정
                            child: Divider(
                              height: 1.2,
                              color: Colors.black,
                              thickness: 1.0,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        width: screenWidth * 1, // 원하는 width 설정
                        alignment: Alignment.centerLeft, // 왼쪽 정렬
                        child: Container(
                          width: screenWidth * 0.5,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: screenWidth * 0.025,
                                right: screenWidth * 0.025), // 왼쪽 여백 설정
                            child: Divider(
                              height: 1.2,
                              color: Colors.black,
                              thickness: 1.0,
                            ),
                          ),
                        ),
                      ),

                SizedBox(height: 10),
                Expanded(
                  child: _searchResults.isEmpty
                      ? Center(child: Text('검색 결과가 없습니다.'))
                      : ListView.builder(
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final news = _searchResults[index];
                            return GestureDetector(
                              onTap: () {
                                // 클릭 시 NewsSummaryPage로 이동
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsShortsPage(news: news),
                                  ),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(12),
                                margin: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          news.company, // 신문사
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0038FF),
                                          ),
                                        ),
                                        Text(
                                          news.company,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF707070),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      news.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      news.shorts,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF707070),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            // 최근 검색어 목록이 열렸을 때
            if (isSearchOpen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Icon(
                                  Icons.access_time_outlined,
                                  color: Color(0xFF707070),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              flex: 8,
                              child: Text(
                                _recentSearches[index],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: Transform.rotate(
                                  angle: -0.785398, // 화살표 회전 (45도)
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: Color(0xFF707070),
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _searchController.text = _recentSearches[index];
                          _searchItems(_recentSearches[index]);
                          _focusNode.unfocus(); // 검색어 클릭 후 포커스 해제
                          setState(() {
                            isSearchOpen = false; // 최근 검색어 목록 닫기
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
