import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle 사용을 위해 추가
import 'package:typicons_flutter/typicons_flutter.dart'; // Typicons 패키지 import
import 'package:newsee/presentation/pages/Main/Main.dart';

class SelectInterests extends StatefulWidget {
  @override
  _SelectInterestsState createState() => _SelectInterestsState();
}

class _SelectInterestsState extends State<SelectInterests> {
  late List<Map<String, dynamic>> interests; // 관심사 아이콘과 텍스트 리스트
  List<int> selectedInterests = []; // 선택된 항목의 categoryId 리스트

  // 문자열로 된 아이콘 이름을 IconData로 변환하는 함수
  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case "Icons.how_to_vote_outlined":
        return Icons.how_to_vote_outlined;
      case "Icons.trending_up_outlined":
        return Icons.trending_up_outlined;
      case "Icons.groups_outlined":
        return Icons.groups_outlined;
      case "Ionicons.earth_sharp":
        return Icons.groups_outlined; // Ionicons 사용
      case "Icons.sports_basketball_outlined":
        return Icons.sports_basketball_outlined;
      case "Icons.palette_outlined":
        return Icons.palette_outlined;
      case "Icons.science_outlined":
        return Icons.science_outlined;
      case "Ionicons.fitness_outline":
        return Icons.groups_outlined; // Ionicons 사용
      case "Icons.mic_external_on_outlined":
        return Icons.mic_external_on_outlined;
      case "Typicons.leaf":
        return Typicons.leaf; // Typicons 사용
      default:
        return Icons.help_outline; // 기본 아이콘
    }
  }

  // JSON 파일을 로드하여 아이콘 목록을 초기화하는 함수
  Future<void> loadInterestsFromAsset() async {
    final String response =
        await rootBundle.loadString('assets/category/list.json');
    final data = json.decode(response); // JSON 파싱

    setState(() {
      interests = List<Map<String, dynamic>>.from(data['data'].map((item) {
        return {
          'categoryId': item['categoryId'],
          'icon': getIconFromString(item['icon']), // 아이콘을 IconData로 변환
          'text': item['categoryName'],
        };
      }));
    });
  }

  @override
  void initState() {
    super.initState();
    interests = []; // 초기값으로 빈 리스트 설정
    loadInterestsFromAsset(); // 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
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
                    itemCount: interests.length, // interests의 항목 개수만큼 표시
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // 한 줄에 3개
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      bool isSelected = selectedInterests
                          .contains(interests[index]['categoryId']);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedInterests
                                  .remove(interests[index]['categoryId']);
                            } else {
                              selectedInterests
                                  .add(interests[index]['categoryId']);
                            }
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
                  // 선택된 categoryId 리스트를 사용하여 원하는 동작을 처리
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MainPage()),
                  );
                  print('선택된 관심 분야 IDs: $selectedInterests');
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
            SizedBox(height: screenWidth * 0.1),
          ],
        ),
      ),
    );
  }
}
