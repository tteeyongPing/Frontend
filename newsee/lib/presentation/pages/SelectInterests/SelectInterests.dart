import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:newsee/presentation/widgets/header/header.dart';
import 'package:newsee/Api/RootUrlProvider.dart';

class SelectInterests extends StatefulWidget {
  final int visibilityFlag; // Constructor를 통해 visibilityFlag 값을 받음
  SelectInterests({required this.visibilityFlag});
  @override
  _SelectInterestsState createState() => _SelectInterestsState();
}

class _SelectInterestsState extends State<SelectInterests> {
  late List<Map<String, dynamic>> interests;
  List<int> selectedInterests = [];
  bool isLoading = false;

  final List<IconData> icons = [
    Icons.trending_up_outlined,
    Icons.mic_external_on_outlined,
    Icons.groups_outlined,
    Ionicons.fitness_outline,
    Icons.science_outlined,
    Icons.sports_basketball_outlined,
    Icons.palette_outlined,
  ];

  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString('token'),
      'userId': prefs.getInt('userId'),
    };
  }

  Future<void> loadInterests(String endpoint) async {
    setState(() => isLoading = true);
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/category/$endpoint');
      var response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          if (endpoint == "list") {
            interests =
                List<Map<String, dynamic>>.from(data['data'].asMap().map(
              (index, item) {
                return MapEntry(index, {
                  'categoryId': item['categoryId'],
                  'icon': icons[index % icons.length],
                  'text': item['categoryName'],
                });
              },
            ).values);
          }
          // 관심사 목록을 로드하는 경우 처리
          if (endpoint == "my") {
            // 'visibilityFlag'가 -1일 경우 Navigator.push 실행을 막습니다.
            if (data['data'].length != 0 && widget.visibilityFlag != -1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainPage()),
              );
            }

            // 'categoryId'가 문자열일 수 있으므로, 이를 int로 변환
            selectedInterests = data['data'].map<int>((item) {
              var categoryId = item['categoryId'];
              if (categoryId is String) {
                return int.parse(categoryId);
              } else if (categoryId is int) {
                return categoryId;
              } else {
                throw FormatException('Invalid categoryId type');
              }
            }).toList();
          }
        });
      } else {
        _showErrorDialog('관심사를 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('데이터를 불러오는 중 문제가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> sendData() async {
    setState(() => isLoading = true);
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      int? userId = credentials['userId'];

      var url =
          Uri.parse('${RootUrlProvider.baseURL}/category/edit?userId=$userId');
      var response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(selectedInterests),
      );

      if (response.statusCode == 200) {
        if (widget.visibilityFlag != -1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainPage()),
          );
        } else {
          Navigator.pop(context, true);
        }
      } else {
        _showErrorDialog('관심사를 저장하는 데 실패했습니다.');
      }
    } catch (e) {
      print('저장 오류: $e');
      _showErrorDialog('저장 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    interests = [];
    // Future.wait()을 사용하여 비동기 함수들이 완료될 때까지 기다립니다.
    Future.wait([loadInterests("my"), loadInterests("list")]).then((_) {
      setState(() {
        // 완료된 후 UI 업데이트
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: SizedBox.shrink(),
        flexibleSpace: Header(visibilityFlag: -1),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 16),
                Text(
                  '당신의 관심 분야를 선택해주세요.',
                  style: TextStyle(fontSize: screenWidth * 0.045),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    itemCount: interests.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                interests[index]['icon'],
                                size: screenWidth * 0.11,
                                color: isSelected
                                    ? Color(0xFF0038FF)
                                    : Colors.black,
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
                SizedBox(height: 16),
                Container(
                  width: screenWidth * 0.84,
                  height: screenWidth * 0.14,
                  child: ElevatedButton(
                    onPressed: (selectedInterests.isEmpty)
                        ? null
                        : () {
                            sendData(); // sendData()를 함수처럼 호출
                          },
                    child: Text(
                      widget.visibilityFlag != -1 ? '해당 관심 분야로 시작하기' : '저장하기',
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
    );
  }
}
