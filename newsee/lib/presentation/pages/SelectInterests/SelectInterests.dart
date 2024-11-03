import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:newsee/presentation/pages/Main/Main.dart';

class SelectInterests extends StatefulWidget {
  @override
  _SelectInterestsState createState() => _SelectInterestsState();
}

class _SelectInterestsState extends State<SelectInterests> {
  // 아이콘과 텍스트 목록
  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.how_to_vote_outlined, 'text': '정치'},
    {'icon': Icons.trending_up_outlined, 'text': '경제'},
    {'icon': Icons.groups_outlined, 'text': '사회'},
    {'icon': Icons.public, 'text': '국제'},
    {'icon': Icons.sports_soccer_outlined, 'text': '스포츠'},
    {'icon': Icons.palette_outlined, 'text': '문화/예술'},
    {'icon': Icons.science_outlined, 'text': '과학/기술'},
    {'icon': FontAwesomeIcons.heartPulse, 'text': '건강/의료'},
    {'icon': Icons.mic_external_on_outlined, 'text': '연예/오락'},
    {'icon': Icons.forest_outlined, 'text': '환경'},
  ];

  // 선택된 항목을 관리하는 리스트
  List<bool> selectedInterests = List.filled(10, false);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Header(), // 헤더 추가
            SizedBox(height: 16),
            Text(
              '당신의 관심 분야를 선택해주세요.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth * 0.88,
                  child: GridView.builder(
                    itemCount: interests.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 줄에 3개
                      childAspectRatio: 1,
                    ),
                    padding: EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      bool isSelected = selectedInterests[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedInterests[index] =
                                !selectedInterests[index];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Color(0xFFD0D9F6)
                                : Color(0xFFE8E8E8),
                            border: isSelected
                                ? Border.all(
                                    color: Color(0xFF0038FF),
                                    width: 2.0,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(24), // 원형 크기 20
                          ),
                          margin: EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              index == 9
                                  ? FaIcon(
                                      FontAwesomeIcons.seedling,
                                      size: 40,
                                      color: isSelected
                                          ? Color(0xFF0038FF)
                                          : Color(0xFF000000),
                                    )
                                  : Icon(
                                      interests[index]['icon'],
                                      size: screenWidth * 0.11,
                                      color: isSelected
                                          ? Color(0xFF0038FF)
                                          : Color(0xFF000000),
                                    ),
                              SizedBox(height: 8),
                              Text(
                                interests[index]['text'],
                                style: TextStyle(
                                  fontSize: screenWidth * 0.032,
                                  color: isSelected
                                      ? Color(0xFF0038FF)
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: screenWidth * 0.88,
              height: screenWidth * 0.14,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                },
                child: Text(
                  '해당 관심 분야로 시작하기',
                  style: TextStyle(
                      color: Colors.white, fontSize: screenWidth * 0.032),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0038FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

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
            bottom: screenWidth * 0.025,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/logo.png',
                width: screenWidth * 0.3,
              ),
              Spacer(),
              Icon(
                Icons.search,
                color: Color(0xFF0038FF),
                size: screenWidth * 0.06,
              ),
            ],
          ),
        ),
        Container(
          width: screenWidth * 0.92,
          child: Divider(
            thickness: 1,
            color: Color(0xFFD3D3D3),
          ),
        ),
      ],
    );
  }
}
