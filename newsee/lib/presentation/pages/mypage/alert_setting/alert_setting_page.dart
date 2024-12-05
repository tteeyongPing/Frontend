import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/mypage/alert_setting/set_alert/set_alert_page.dart'; // SetAlert import 추가
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/services/alert/load_alert.dart';
import 'package:newsee/services/alert/schedule_alert.dart';

class AlertSettingsPage extends StatefulWidget {
  @override
  _AlertSettingsPageState createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends State<AlertSettingsPage> {
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
              'days': item['days'],
              'selected': false
            };
          })));
        });
      } else if (response.statusCode == 404) {
        alarms.clear();
      } else {
        _showErrorDialog('알림 목록을 불러오는 데 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('알림 목록을 불러오는 중 오류가 발생했습니다.');
    } finally {
      await cancelAllNotifications(); //알림 취소
      await LoadAlert(); // 알림 로드
      await scheduleNotifications(); // 알림 예약
      setState(() {
        isLoading = false;
        _selectedAlarms.clear(); // 삭제 후 선택된 항목 초기화
        _isEditing = false; // 편집 종료
        _updateSelectAll(); // 전체 선택 상태 업데이트
      });
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
    } else if (hour == 0) {
      hour = 12;
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

  Future<void> _patchActive(bool active) async {
    setState(() => isLoading = true); // 로딩 상태 시작

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url = Uri.parse('${RootUrlProvider.baseURL}/alarm/edit');

      // _selectedAlarms의 각 항목에 대해 상태 변경 요청을 보냄
      for (var index in _selectedAlarms) {
        var alarm = alarms[index]; // _selectedAlarms에서 index에 해당하는 알람 가져오기

        var response = await http.patch(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'alarmId': alarm['alarmId'], // alarm의 ID
            'period': alarm['date'], // 알람의 주기
            'days': alarm['days'], // 알람이 반복되는 요일
            'active': active, // 새로운 active 값
          }),
        );

        if (response.statusCode == 200) {
          // 성공하면 알람의 상태를 active로 업데이트
          setState(() {
            alarm['on'] = active;
            _isEditing = false;
          });
        } else {
          _showErrorDialog('알림 상태를 변경하는 데 실패했습니다.');
        }
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('알림 상태를 변경하는 중 오류가 발생했습니다.');
    } finally {
      await cancelAllNotifications(); //알림 취소
      await LoadAlert(); // 알림 로드
      await scheduleNotifications(); // 알림 예약
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  Future<void> _deleteSelectedAlarms() async {
    setState(() => isLoading = true); // 로딩 상태 시작

    try {
      // 선택된 알람을 내림차순으로 정렬해서 삭제
      _selectedAlarms.sort((a, b) => b.compareTo(a));

      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      // 알람 삭제 요청
      for (var index in _selectedAlarms) {
        var url = Uri.parse('${RootUrlProvider.baseURL}/alarm/remove?alarmId=' +
            alarms[index]['alarmId'].toString());
        print(url);
        var response = await http.delete(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          print("알람 삭제 룰루");
          alarms.removeAt(index); // 알람 목록에서 삭제
        } else {
          _showErrorDialog('알림을 삭제하는 데 실패했습니다.');
          return; // 실패하면 더 이상 진행하지 않음
        }
      }

      // 선택된 알람 초기화 및 상태 업데이트
      setState(() {
        _selectedAlarms.clear(); // 삭제 후 선택된 항목 초기화
        _isEditing = false; // 편집 종료
        _updateSelectAll(); // 전체 선택 상태 업데이트
      });
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('알림 삭제 중 오류가 발생했습니다.');
    } finally {
      await cancelAllNotifications(); //알림 취소
      await LoadAlert(); // 알림 로드
      await scheduleNotifications(); // 알림 예약
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 오류 메시지를 보여주는 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
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
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '뉴스 알림 설정',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
        centerTitle: true, // 제목을 정확히 가운데 정렬
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // 편집 버튼과 추가 버튼
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, // 좌우 패딩을 화면 크기 비율로 설정
              ),
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
                              color: const Color(0xFF4D71F6),
                            ),
                          ) // 편집 모드일 때 편집 텍스트는 없애고, O 체크박스 아이콘 추가
                        : const Text(
                            '편집',
                            style: TextStyle(
                              color: Color(0xFF4D71F6),
                            ),
                          ),
                  ),
                  // + 버튼을 눌러 SetAlert 페이지로 이동
                  IconButton(
                    icon: const Icon(Icons.add,
                        size: 20, color: Color(0xFF4D71F6)),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetAlertPage()),
                      );

                      if (result == true) {
                        loadAlert(); // 돌아왔을 때 목록 다시 로드
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
                return GestureDetector(
                  onLongPress: () {
                    // 길게 눌렀을 때 동작
                    setState(() {
                      _isEditing = !_isEditing; // 편집 모드 토글
                    });
                    _toggleSelection(alarms.indexOf(alarm));
                    //print('길게 눌림');
                  },
                  onTap: () async {
                    if (!_isEditing) {
                      // _isEditing이 true일 때만 동작
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SetAlertPage(alarms: [alarm]), // 알람 데이터를 전달
                        ),
                      );

                      // 결과가 true일 때 목록을 다시 로드
                      if (result == true) {
                        loadAlert(); // 돌아왔을 때 알림 목록을 다시 로드
                      }
                    } else {
                      _toggleSelection(alarms.indexOf(alarm));
                    }
                    // _isEditing이 false일 경우 아무 동작도 하지 않음
                  },
                  child: Container(
                    width: screenWidth * 0.9,
                    margin: EdgeInsets.only(
                      left: screenWidth * 0.05, // 왼쪽 패딩
                      right: screenWidth * 0.05, // 오른쪽 패딩
                      bottom: screenWidth * 0.05, // 위쪽 패딩
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 8,
                          offset: const Offset(0, 4), // 그림자 아래로
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _isEditing
                                    ? Padding(
                                        padding: EdgeInsets.only(
                                            right: screenWidth * 0.1),
                                        child: GestureDetector(
                                          onTap: () {
                                            _toggleSelection(
                                                alarms.indexOf(alarm));
                                          },
                                          child: Icon(
                                            alarm['selected']
                                                ? Icons.check_circle
                                                : Icons.radio_button_unchecked,
                                            color: alarm['selected']
                                                ? const Color(0xFF4D71F6)
                                                : Colors.grey,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: formatTime(alarm['date']!)
                                            .substring(0, 2),
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
                            Row(
                              children: ['일', '월', '화', '수', '목', '금', '토']
                                  .map((day) {
                                bool isSelected = alarm['days']!.contains(day);
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      right: 4, top: 30, bottom: 30),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.03,
                                        color: isSelected
                                            ? const Color(0xFF0038FF)
                                            : const Color(0xFFB0B0B0),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                );
                              }).toList(),
                            ),
                            if (!_isEditing)
                              Switch(
                                value: alarm['on'],
                                onChanged: (bool value) async {
                                  setState(() {
                                    alarm['on'] = value;
                                  });

                                  try {
                                    final credentials =
                                        await getTokenAndUserId();
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
                                        "days": alarm['days'],
                                        'active': value
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      await cancelAllNotifications(); // 알림 취소
                                      print('알림 취소 완료');
                                      await LoadAlert(); // 알림 로드
                                      print('알림 로드 완료');
                                      await scheduleNotifications(); // 알림 예약
                                      print('알림 예약 완료');
                                    } else {
                                      setState(() {
                                        alarm['on'] = !value;
                                      });
                                      _showErrorDialog('알림 상태를 변경하는 데 실패했습니다.');
                                    }
                                  } catch (e) {
                                    print('오류 발생: $e');
                                    setState(() {
                                      alarm['on'] = !value;
                                    });
                                    _showErrorDialog(
                                        '알림 상태를 변경하는 중 오류가 발생했습니다.');
                                  }
                                },
                                activeTrackColor: const Color(0xFF4D71F6),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: const Color(0XffD3D3D3),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )),
            // 삭제 버튼 (편집 모드일 때만)
            if (_isEditing && _selectedAlarms.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                width: screenWidth * 1,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly, // 아이템 간의 간격을 띄우기
                  children: [
                    // 첫 번째 버튼 (켜기)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _patchActive(true),
                        child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          height: 100, // 원하는 높이

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.alarm_outlined,
                                  size: 24, color: Color(0xFF0038FF)), // 아이콘
                              const SizedBox(height: 8),
                              Text(
                                '켜기',
                                style: TextStyle(
                                  color: const Color(0xFF0038FF),
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 두 번째 버튼 (끄기)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _patchActive(false),
                        child: Container(
                          color: Colors.white,
                          alignment: Alignment.center,
                          height: 100, // 원하는 높이

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.alarm_off_outlined,
                                  size: 24, color: Color(0xFF0038FF)), // 아이콘
                              const SizedBox(height: 8),
                              Text(
                                '끄기',
                                style: TextStyle(
                                  color: const Color(0xFF0038FF),
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 세 번째 버튼 (삭제)
                    Expanded(
                      child: GestureDetector(
                        onTap: _deleteSelectedAlarms,
                        child: Container(
                          color: Colors.white,
                          width: screenWidth / 3,
                          alignment: Alignment.center,
                          height: 100, // 원하는 높이

                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.delete_outline,
                                  size: 24, color: Color(0xFF0038FF)), // 아이콘
                              const SizedBox(height: 8),
                              Text(
                                '삭제',
                                style: TextStyle(
                                  color: const Color(0xFF0038FF),
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
