import 'package:flutter/material.dart';

final List<Map<String, dynamic>> menus = [
  {'icon': Icons.home_outlined, 'text': '홈'},
  {'icon': Icons.description_outlined, 'text': '뉴스'},
  {'icon': Icons.bookmark_border, 'text': '북마크'},
  {'icon': Icons.play_circle_outline, 'text': '플레이리스트'},
  {'icon': Icons.person_outline, 'text': '마이페이지'},
];

class Footer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  Footer({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70, // BottomNavigationBar의 높이 설정
      child: BottomNavigationBar(
        items: List.generate(menus.length, (index) {
          return BottomNavigationBarItem(
            icon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  menus[index]['icon'],
                  size: 30, // 아이콘 크기 설정
                  color: selectedIndex == index
                      ? const Color(0xFF619EF7)
                      : const Color(0xFF707070),
                ),
                SizedBox(height: 4), // 아이콘과 레이블 사이의 간격 설정
              ],
            ),
            label: menus[index]['text'],
          );
        }),
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontSize: 12,
            color: Color(0xFF619EF7),
            fontWeight: FontWeight.bold), // 선택된 레이블 크기
        unselectedLabelStyle:
            TextStyle(fontSize: 12, color: Color(0xFF707070)), // 선택되지 않은 레이블 크기
        backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
      ),
    );
  }
}
