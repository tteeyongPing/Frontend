import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/AlertSettingsPage/SetAlert/SetAlert.dart'; // SetAlert import 추가
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';

class AlertSettingsPage extends StatefulWidget {
  @override
  _AlertSettingsPageState createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends State<AlertSettingsPage> {
  TextEditingController _controller = TextEditingController();
  bool isLoading = false; // 로딩 상태 관리

  @override
  void initState() {
    super.initState();
    loadAlert(); // 알림 데이터를 로드
  }

  // SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
  Future<Map<String, dynamic>> getTokenAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    int? userId = prefs.getInt('userId');
    return {'token': token, 'userId': userId};
  }

  // 관심 분야 목록
  final List<Map<String, dynamic>> alarms = [];

  // JSON 파일을 로드하여 알림 데이터를 초기화
  Future<void> loadAlert() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/alarm');
      var response = await http.get(url, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          alarms.clear();
          alarms
              .addAll(List<Map<String, dynamic>>.from(data['data'].map((item) {
            return {
              'alarmId': item['alarmId'],
              'date': item['period'],
              'on': item['active'],
              'day': ["월", "화"]
            };
          })));
        });
      } else {
        _showErrorDialog('알림 목록을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('알림 목록을 불러오는 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  bool _isEditing = false; // 편집 모드 여부
  List<int> _selectedAlarms = []; // 선택된 알람의 인덱스 리스트
  bool _selectAll = false; // 전체 선택 여부

  String formatTime(String time) {
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    String period = hour < 12 ? '오전' : '오후';
    if (hour > 12) {
      hour -= 12;
    }
    return '$period ${hour}:${timeParts[1]}';
  }

  void _toggleSelection(int index) {
    setState(() {
      // 선택 상태를 토글
      alarms[index]['selected'] = !alarms[index]['selected'];
      if (alarms[index]['selected']) {
        _selectedAlarms.add(index); // 선택된 항목 추가
      } else {
        _selectedAlarms.remove(index); // 선택 해제 시 항목 제거
      }
      // 하위 항목에 따라 전체 선택 상태 업데이트
      _updateSelectAll();
    });
  }

  void _deleteSelectedAlarms() {
    setState(() {
      // 선택된 알람 삭제
      _selectedAlarms.sort((a, b) => b.compareTo(a)); // 내림차순으로 정렬해서 삭제
      for (var index in _selectedAlarms) {
        alarms.removeAt(index);
      }
      _selectedAlarms.clear(); // 삭제 후 선택된 항목 초기화
      _isEditing = false; // 삭제 후 편집 종료
      _updateSelectAll(); // 전체 선택 상태 업데이트
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

  void _toggleSelectAll() {
    setState(() {
      _selectAll = !_selectAll; // 전체 선택 상태 토글
      for (var i = 0; i < alarms.length; i++) {
        alarms[i]['selected'] = _selectAll;
        if (_selectAll) {
          if (!_selectedAlarms.contains(i)) {
            _selectedAlarms.add(i); // 전체 선택 시 모든 알람 추가
          }
        } else {
          _selectedAlarms.clear(); // 전체 해제 시 선택 해제
        }
      }
    });
  }

  // 전체 선택 상태를 업데이트하는 함수
  void _updateSelectAll() {
    // 모든 알람이 선택된 경우만 전체 선택 상태를 true로 설정
    _selectAll = alarms.every((alarm) => alarm['selected']);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
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
            '뉴스 알림 설정',
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
            // 편집 버튼과 추가 버튼
            Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // O 체크박스를 왼쪽에 배치
                children: [
                  // 편집 버튼 (편집 상태일 때 O 체크박스 표시)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isEditing = !_isEditing; // 편집 모드 토글
                      });
                    },
                    child: _isEditing
                        ? GestureDetector(
                            onTap: _toggleSelectAll,
                            child: Icon(
                              _selectAll
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked, // O 체크박스 구현
                              size: 30,
                              color: Color(0xFF4D71F6),
                            ),
                          ) // 편집 모드일 때 편집 텍스트는 없애고, O 체크박스 아이콘 추가
                        : Text(
                            '편집',
                            style: TextStyle(
                              color: Color(0xFF4D71F6),
                            ),
                          ),
                  ),
                  // + 버튼을 눌러 SetAlert 페이지로 이동
                  IconButton(
                    icon: Icon(Icons.add, size: 20, color: Color(0xFF4D71F6)),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetAlertPage()),
                      );

                      // SetAlertPage에서 true를 반환한 경우 새로고침
                      if (result == true) {
                        loadAlert();
                      }
                    },
                  ),
                ],
              ),
            ),
            // 알림 목록
            Expanded(
              child: ListView(
                children: alarms.map((alarm) {
                  return Container(
                    width: screenWidth * 0.9,
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: Offset(0, 4), // 그림자 아래로
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 체크박스와 알람 시간 표시
                            Row(
                              children: [
                                // 체크박스 추가
                                _isEditing
                                    ? GestureDetector(
                                        onTap: () {
                                          _toggleSelection(
                                              alarms.indexOf(alarm));
                                        },
                                        child: Icon(
                                          alarm['selected']
                                              ? Icons.check_circle
                                              : Icons.radio_button_unchecked,
                                          color: alarm['selected']
                                              ? Color(0xFF4D71F6)
                                              : Colors.grey,
                                          size: 30,
                                        ),
                                      )
                                    : Container(), // 편집 모드일 때만 체크박스 표시
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: formatTime(alarm['date']!)
                                            .substring(0, 2), // 오전/오후 부분만 작게
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                        ),
                                      ),
                                      TextSpan(
                                        text: formatTime(alarm['date']!)
                                            .substring(2),
                                        style: TextStyle(
                                            fontSize: screenWidth * 0.07),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // 요일 표시
                            Row(
                              children: ['일', '월', '화', '수', '목', '금', '토']
                                  .map((day) {
                                bool isSelected = alarm['day']!.contains(day);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 4, top: 30, bottom: 30),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.03,
                                      color: isSelected
                                          ? Colors.black
                                          : Color(0xFFB0B0B0),
                                      fontWeight: isSelected
                                          ? FontWeight.normal
                                          : FontWeight.normal,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            // 알람 스위치
                            Switch(
                              value: alarm['on'],
                              onChanged: (bool value) async {
                                setState(() {
                                  alarm['on'] = value; // UI 업데이트
                                });

                                try {
                                  final credentials = await getTokenAndUserId();
                                  String? token = credentials['token'];

                                  var url = Uri.parse(
                                      '${RootUrlProvider.baseURL}/alarm/edit');
                                  var response = await http.patch(
                                    url,
                                    headers: {
                                      'accept': '*/*',
                                      'Authorization': 'Bearer $token',
                                      'Content-Type': 'application/json',
                                    },
                                    body: json.encode({
                                      'alarmId': alarm['alarmId'],
                                      "period": alarm['date'],
                                      "day": "FRIDAY",
                                      'active': value
                                    }),
                                  );

                                  if (response.statusCode != 200) {
                                    // 상태 복구 (API 실패 시 이전 상태로 롤백)
                                    setState(() {
                                      alarm['on'] = !value;
                                    });
                                    _showErrorDialog('알림 상태를 변경하는 데 실패했습니다.');
                                  }
                                } catch (e) {
                                  print('오류 발생: $e');
                                  // 상태 복구 (오류 발생 시 이전 상태로 롤백)
                                  setState(() {
                                    alarm['on'] = !value;
                                  });
                                  _showErrorDialog('알림 상태를 변경하는 중 오류가 발생했습니다.');
                                }
                              },
                              activeTrackColor: Color(0xFF4D71F6),
                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor: Color(0XffD3D3D3),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // 삭제 버튼 (편집 모드일 때만)
            if (_isEditing && _selectedAlarms.isNotEmpty)
              Container(
                padding: EdgeInsets.all(20),
                child: GestureDetector(
                  onTap: _deleteSelectedAlarms,
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF4C4C),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
