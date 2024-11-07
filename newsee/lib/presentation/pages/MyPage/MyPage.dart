// MyPage.dart
import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/EditName/EditNamePage.dart';
import 'package:newsee/presentation/pages/MyPage/EditInterests/EditInterestsPage.dart';

class MyPage extends StatefulWidget {
  final VoidCallback onNavigateToNews;
  final VoidCallback onNavigateToBookmark;

  MyPage({required this.onNavigateToNews, required this.onNavigateToBookmark});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 홍길동 컨테이너
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 40,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditNamePage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("홍길동"),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          // 뉴스 탐색 섹션
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 100,
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("뉴스 탐색"),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("마지막 뉴스 이어보기"),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: widget.onNavigateToNews, // 뉴스 페이지로 이동 콜백 호출
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("뉴스 목록 보기"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          // 나머지 섹션들
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 130,
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("나의 뉴스 관리"),
                    ],
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: widget.onNavigateToBookmark, // 북마크 페이지로 이동 콜백 호출
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("북마크"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("마이 플레이리스트"),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("구독한 플레이리스트"),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 100,
              child: Column(
                children: [
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("설정"),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("뉴스 알림 설정"),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: Colors.black,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditInterestsPage()),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("나의 관심 분야 설정"),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
