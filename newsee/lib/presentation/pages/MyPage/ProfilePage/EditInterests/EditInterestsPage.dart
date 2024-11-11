import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart'; // 패키지 임포트
import 'package:typicons_flutter/typicons_flutter.dart';

class EditInterestsPage extends StatefulWidget {
  @override
  _EditInterestsPageState createState() => _EditInterestsPageState();
}

class _EditInterestsPageState extends State<EditInterestsPage> {
  TextEditingController _controller = TextEditingController();

  // 관심 분야 목록
// 관심 분야 목록
  final List<Map<String, dynamic>> interests = [
    {'icon': Icons.how_to_vote_outlined, 'text': '정치'},
    {'icon': Icons.trending_up_outlined, 'text': '경제'},
    {'icon': Icons.groups_outlined, 'text': '사회'},
    {'icon': Ionicons.earth_sharp, 'text': '국제'},
    {'icon': Icons.sports_basketball_outlined, 'text': '스포츠'},
    {'icon': Icons.palette_outlined, 'text': '문화/예술'},
    {'icon': Icons.science_outlined, 'text': '과학/기술'},
    {'icon': Ionicons.fitness_outline, 'text': '건강/의료'},
    {'icon': Icons.mic_external_on_outlined, 'text': '연예/오락'},
    {'icon': Typicons.leaf, 'text': '환경'}, // 환경 아이콘 추가
  ];

  List<bool> selectedInterests =
      List.generate(10, (index) => false); // 관심 분야 선택 여부를 관리하는 리스트

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        flexibleSpace: Center(
          child: Text(
            '관심분야 수정',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 헤더 추가
            SizedBox(height: 16),
            Text(
              '당신의 관심 분야를 선택해주세요.',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Container(
                  width: screenWidth * 0.84,
                  child: GridView.builder(
                    itemCount: interests.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 줄에 3개
                      childAspectRatio: 1,
                    ),
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          margin: EdgeInsets.all(6.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
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
                                  fontSize: screenWidth * 0.035,
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
              width: screenWidth * 0.84,
              height: screenWidth * 0.14,
              child: ElevatedButton(
                onPressed: () {
                  // 입력된 텍스트를 출력하거나 다른 작업을 할 수 있습니다.

                  Navigator.pop(context); // 이름 변경 후 이전 페이지로 돌아가기
                },
                child: Text(
                  '저장하기',
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
            SizedBox(height: screenWidth * 0.1),
          ],
        ),
      ),
    );
  }
}
