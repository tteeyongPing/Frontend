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
    return Column(
      children: [

        Container(
          height: kToolbarHeight, // 높이를 kToolbarHeight로 고정
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
          ),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // 좌우로 요소 배치
            children: [
              // 왼쪽에 로고 아이콘
              Flexible(
                child: Image.asset(
                  'assets/logo.png',
                  height: 48, // 고정된 높이로 크기 조정
                  fit: BoxFit.contain, // 이미지를 컨테이너에 맞춤
                ),
              ),
              // 오른쪽 메뉴 아이콘
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
                  size: 32.0, // 고정된 크기 설정
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
