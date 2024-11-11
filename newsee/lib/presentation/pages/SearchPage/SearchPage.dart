import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];
  List<String> _allItems = [
    'Apple',
    'Banana',
    'Orange',
    'Grapes',
    'Watermelon',
    'Peach',
    'Pineapple',
    'Strawberry',
  ];

  List<String> _recentSearches = [];
  FocusNode _focusNode = FocusNode();
  bool isSearchOpen = false; // 검색어 목록이 열려 있는지 상태를 관리

  // 검색 기능
  void _searchItems(String query) {
    setState(() {
      _searchResults = _allItems
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // 최근 검색어 추가
  void _addRecentSearch(String query) {
    setState(() {
      if (!_recentSearches.contains(query)) {
        if (_recentSearches.length >= 5) {
          _recentSearches.removeAt(0); // 최대 5개로 제한
        }
        _recentSearches.add(query); // 최근 검색어에 추가
      }
    });
  }

  // 검색어 목록을 닫는 함수
  void _toggleSearchList() {
    setState(() {
      isSearchOpen = !isSearchOpen; // 검색어 목록의 상태를 반전
    });
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
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
        title: null,
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
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {});
                },
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
                    }
                  },
                ),
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
              _toggleSearchList(); // 검색어 목록을 열거나 닫기
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
      body: Padding(
        padding: EdgeInsets.all(0.0),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                _toggleSearchList(); // 다른 곳을 클릭하면 검색어 목록 닫기
              },
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Expanded(
                    child: _searchResults.isEmpty
                        ? Center(child: Text('검색 결과가 없습니다.'))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return Container(
                                color: Colors.yellow
                                    .withOpacity(0.2), // 영역을 시각적으로 확인
                                child: ListTile(
                                  title: Text(_searchResults[index]),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            // 검색창에 포커스가 없을 때도 최근 검색어 목록이 보이게 함
            if (isSearchOpen && _recentSearches.isNotEmpty)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _toggleSearchList, // 최근 검색어 영역 클릭 시 닫기
                  child: Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _recentSearches.length,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.blue.withOpacity(0.2), // 영역을 시각적으로 확인
                          child: ListTile(
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
                                  child: Text(_recentSearches[index]),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Center(
                                    child: Transform.rotate(
                                      angle: -0.785398,
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
                              print('최근 검색어 클릭됨: ${_recentSearches[index]}');
                              String selectedSearch = _recentSearches[index];
                              setState(() {
                                _searchController.text = selectedSearch;
                              });

                              _searchItems(selectedSearch);
                              _focusNode.requestFocus();
                              _toggleSearchList(); // 최근 검색어 클릭 시 닫기
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
