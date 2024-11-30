import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/SearchPage/SearchPage.dart'; // SetAlert import 추가

class Header extends StatelessWidget implements PreferredSizeWidget {
  final int visibilityFlag; // 파라미터 추가

  const Header({
    Key? key,
    this.visibilityFlag = 1, // 기본값 1로 설정, -1일 경우 GestureDetector 안 보이게
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = kToolbarHeight; // AppBar의 기본 높이를 사용

    return AppBar(
      toolbarHeight: appBarHeight, // AppBar 높이 설정
      elevation: 0, // 그림자 없애기
      backgroundColor: Colors.transparent, // 배경 투명하게 설정
      titleSpacing: 0, // 기본 AppBar titleSpacing 없애기
      automaticallyImplyLeading: false, // 기본 왼쪽 아이콘 제거
      title: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05, // 좌우 패딩을 화면 크기 비율로 설정
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 요소 배치
          crossAxisAlignment: CrossAxisAlignment.center, // 세로 중앙 정렬
          children: [
            // 왼쪽 로고 아이콘
            Flexible(
              child: Image.asset(
                'assets/logo.png',
                height: appBarHeight * 0.5, // 고정된 높이로 크기 조정
                fit: BoxFit.contain, // 이미지를 컨테이너에 맞춤
              ),
            ),
            // 오른쪽 메뉴 아이콘 (visibilityFlag 조건 추가)
            if (visibilityFlag != -1) // visibilityFlag가 -1이 아닐 때만 표시
              GestureDetector(
                onTap: () {
                  // search 아이콘 클릭 시 SearchPage로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
                child: const Icon(
                  Icons.search,
                  color: Color(0xFF0038FF),
                  size: kToolbarHeight * 0.5, // 고정된 크기 설정
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // AppBar 높이 설정
}
