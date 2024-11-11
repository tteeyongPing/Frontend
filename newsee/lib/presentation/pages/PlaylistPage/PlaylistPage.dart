import 'package:flutter/material.dart';

class PlaylistPage extends StatefulWidget {
  @override
  _PlaylistPageState createState() => _PlaylistPageState();
}

class _PlaylistPageState extends State<PlaylistPage> {
  bool isNewsSelected = true; // 기본값을 '나의 플레이리스트'로 설정
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _searchItems(String query) {
    // 검색 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Center(
                                    child: Text(
                                      '나의 플레이리스트',
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
                              padding: EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 20),
                              color: Colors.white,
                              child: Center(
                                child: Text(
                                  '구독한 플레이리스트',
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
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
