import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';

class SetAlertPage extends StatefulWidget {
  @override
  _SetAlertPageState createState() => _SetAlertPageState();
}

// SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  int? userId = prefs.getInt('userId');
  return {'token': token, 'userId': userId};
}

class _SetAlertPageState extends State<SetAlertPage> {
  int _selectedHour = 1;
  int _selectedMinute = 0;
  String _selectedAmPm = "오전";
  List<String> _selectedDays = [];
  bool isLoading = false; // 로딩 상태 관리

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
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

  Future<void> _addAlert() async {
    // 필수 입력값 체크
    if (_selectedHour == -1 ||
        _selectedMinute == -1 ||
        _selectedAmPm.isEmpty ||
        _selectedDays.isEmpty) {
      _showErrorDialog('시간과 날짜를 모두 선택해주세요.');
      return;
    }

    setState(() => isLoading = true); // 로딩 상태 시작
    String formattedTime;

    try {
      if (_selectedAmPm == "오전") {
        formattedTime =
            '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
      } else {
        formattedTime =
            '${(_selectedHour % 12 + 12).toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';
      }

      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      int? userId = credentials['userId'];

      if (token == null || userId == null) {
        _showErrorDialog('로그인이 필요합니다.');
        return;
      }

      var url = Uri.parse('${RootUrlProvider.baseURL}/alarm/create');
      var response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'period': formattedTime,
          //'day': _selectedDays,
          'day': "MONDAY",
          'userId': userId,
          'active': true,
        }),
      );
      print("body 확인" +
          jsonEncode({
            'period': formattedTime,
            //'day': _selectedDays,
            'userId': userId,
            'active': true,
          }));
      if (response.statusCode == 200) {
        print('알림 생성 성공');
        Navigator.pop(context, true);
      } else {
        print('응답 코드: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        _showErrorDialog('알림 생성을 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('알림 생성 오류가 발생했습니다: $e');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

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
        title: Center(
          child: Text(
            '알림 추가',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey, thickness: 1, height: 1),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 시간 선택 Picker UI
                      Container(
                        width: screenWidth * 0.9,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: CupertinoPicker(
                                backgroundColor: Colors.transparent,
                                itemExtent: 50.0,
                                diameterRatio: 1.2,
                                useMagnifier: true,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedAmPm = index == 0 ? "오전" : "오후";
                                  });
                                },
                                children: [
                                  Center(
                                      child: Text("오전",
                                          style: TextStyle(fontSize: 24))),
                                  Center(
                                      child: Text("오후",
                                          style: TextStyle(fontSize: 24))),
                                ],
                              ),
                            ),
                            Expanded(
                              child: CupertinoPicker(
                                backgroundColor: Colors.transparent,
                                itemExtent: 50.0,
                                diameterRatio: 1.2,
                                useMagnifier: true,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    // 무한 스크롤처럼 동작하도록 설정
                                    _selectedHour = (index % 12) + 1; // 1~12 순환
                                  });
                                },
                                children: List.generate(1000, (index) {
                                  // 큰 숫자로 설정
                                  return Center(
                                    child: Text(
                                      '${(index % 12) + 1}', // 1~12 반복
                                      style: TextStyle(fontSize: 24),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            Text(':', style: TextStyle(fontSize: 30)),
                            Expanded(
                              child: CupertinoPicker(
                                backgroundColor: Colors.transparent,
                                itemExtent: 50.0,
                                diameterRatio: 1.2,
                                useMagnifier: true,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedMinute = (index % 60);
                                  });
                                },
                                children: List.generate(6000, (index) {
                                  return Center(
                                      child: Text('${(index % 61)}',
                                          style: TextStyle(fontSize: 24)));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // 요일 선택 UI
                      Wrap(
                        runSpacing: screenWidth * 0.01,
                        alignment: WrapAlignment.start,
                        children:
                            ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                          bool isSelected = _selectedDays.contains(day);
                          return Container(
                            width: screenWidth * 0.123,
                            child: GestureDetector(
                              onTap: () {
                                _toggleDay(day);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFFD0D9F6)
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      color: isSelected
                                          ? Color(0xFF0038FF)
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      // 알림 추가 버튼
                      Container(
                        width: screenWidth * 0.9,
                        height: screenWidth * 0.14,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _addAlert,
                          child: isLoading
                              ? CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text('알림 추가',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.04)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0038FF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
