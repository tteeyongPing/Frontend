import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/SearchPage/SearchPage.dart'; // SetAlert import 추가

class Header extends StatelessWidget {
  final int visibilityFlag; // 파라미터 추가

  const Header({
    Key? key,
    this.visibilityFlag = 1, // 기본값 1로 설정, -1일 경우 GestureDetector 안 보이게
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            top: screenWidth * 0.11,
            right: screenWidth * 0.05,
            bottom: 0, // 아래쪽 패딩을 조정하여 약간의 공간 유지
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 왼쪽에 로고 아이콘
              Image.asset(
                'assets/logo.png',
                width: screenWidth * 0.3, // 로고의 크기를 조정
              ),
              Spacer(), // 로고와 메뉴 아이콘 사이에 공간 추가
              // 오른쪽 메뉴 아이콘, visibilityFlag가 -1일 때 안 보이게 처리
              if (visibilityFlag != -1) // visibilityFlag 값이 -1이 아니면 표시
                GestureDetector(
                  onTap: () {
                    // search 아이콘 클릭 시 SearchPage로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                  child: Icon(
                    Icons.search,
                    color: Color(0xFF0038FF),
                    size: screenWidth * 0.06,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
