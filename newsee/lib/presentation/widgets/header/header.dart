import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            left: screenWidth * 0.05,
            top: screenWidth * 0.05,
            right: screenWidth * 0.05,
            bottom: screenWidth * 0.025, // 아래쪽 패딩을 조정하여 약간의 공간 유지
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
              // 오른쪽 메뉴 아이콘
              Icon(
                Icons.search,
                color: Color(0xFF0038FF),
                size: screenWidth * 0.06,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
