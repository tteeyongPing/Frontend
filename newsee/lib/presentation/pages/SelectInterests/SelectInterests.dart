import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:typicons_flutter/typicons_flutter.dart'; // Typicons 사용
import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

class SelectInterests extends StatefulWidget {
  @override
  _SelectInterestsState createState() => _SelectInterestsState();
}

class _SelectInterestsState extends State<SelectInterests> {
  late List<Map<String, dynamic>> interests; // 관심사 아이콘과 텍스트 리스트
  List<int> selectedInterests = []; // 선택된 항목의 categoryId 리스트
  bool isLoading = false; // 로딩 상태 관리

  // 아이콘 목록
  final List<IconData> icons = [
    Icons.trending_up_outlined,
    Icons.mic_external_on_outlined,
    Icons.groups_outlined,
    Ionicons.fitness_outline,
    Icons.science_outlined,
    Icons.sports_basketball_outlined,
    Icons.palette_outlined,
  ];

  // SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('userId');
    return {'token': token, 'userId': userId};
  }

  // JSON 파일을 로드하여 관심사 데이터를 초기화
  Future<void> loadInterestsFromAsset() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/category/list');
      var response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          interests = List<Map<String, dynamic>>.from(data['data'].map((item) {
            return {
              'categoryId': item['categoryId'],
              'icon':
                  icons[data['data'].indexOf(item) % icons.length], // 아이콘 매핑
              'text': item['categoryName'],
            };
          }));
        });
      } else {
        _showErrorDialog('관심 분야 데이터를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 선택된 관심사를 서버에 전송
  Future<void> sendData() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      int? userId = credentials['userId'];

      var body = selectedInterests;

      print('body: $body');
      var url =
          Uri.parse('${RootUrlProvider.baseURL}/category/edit?userId=$userId');
      var response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('관심분야 저장 성공');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      } else {
        _showErrorDialog('선택된 관심 분야를 저장하는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('저장 중 오류가 발생했습니다.$e');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 오류 메시지를 보여주는 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    interests = []; // 초기값 설정
    loadInterestsFromAsset(); // 데이터 로드
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white, // 색상 고정
        elevation: 0, // 그림자 효과 없애기
        leading: SizedBox.shrink(), // 왼쪽 아이콘 제거
        flexibleSpace:
            Header(visibilityFlag: -1), // -1일 경우 GestureDetector가 표시되지 않습니다.
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0), // Divider의 높이 설정
          child: Divider(
            color: Colors.grey, // Divider 색상 설정
            thickness: 1.0, // Divider 두께 설정
            height: 1.0, // Divider가 차지할 높이 설정
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 표시
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text(
                    '당신의 관심 분야를 선택해주세요.',
                    style: TextStyle(fontSize: screenWidth * 0.045),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Container(
                        width: screenWidth * 0.84,
                        child: GridView.builder(
                          itemCount: interests.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
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
                                          color: Color(0xFF0038FF), width: 2.0)
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
                        sendData();
                      },
                      child: Text(
                        '해당 관심 분야로 시작하기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.032,
                        ),
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
