import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newsee/services/alert/load_alert.dart';
import 'package:newsee/services/alert/schedule_alert.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SetAlertPage extends StatefulWidget {
  final List<Map<String, dynamic>>? alarms; // 알람 데이터를 nullable로 변경

  SetAlertPage({this.alarms}); // 기본값 설정을 위해 nullable로 받음

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

  @override
  void initState() {
    super.initState();
    if (widget.alarms != null && widget.alarms!.isNotEmpty) {
      var alarm = widget.alarms!.first;
      _initializeAlarmData(alarm);
    }
  }

  // 알람 데이터 초기화
  void _initializeAlarmData(Map<String, dynamic> alarm) {
    _selectedDays = List<String>.from(alarm['days']);
    String time = alarm['date'];
    List<String> timeParts = time.split(':');
    int hour = int.parse(timeParts[0]);
    _selectedAmPm = hour < 12 ? '오전' : '오후';
    _selectedHour = hour % 12 == 0 ? 12 : hour % 12;
    _selectedMinute = int.parse(timeParts[1]);
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

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

  Future<void> _addOrUpdateAlert(bool isUpdate) async {
    if (_selectedDays.isEmpty) {
      _showErrorDialog('시간과 날짜를 모두 선택해주세요.');
      return;
    }

    setState(() => isLoading = true);
    String formattedTime = (_selectedAmPm == "오전" && _selectedHour == 12)
        ? '00:${_selectedMinute.toString().padLeft(2, '0')}'
        : (_selectedAmPm == "오전")
            ? '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}'
            : '${(_selectedHour % 12 + 12).toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}';

    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];
      int? userId = credentials['userId'];

      if (token == null || userId == null) {
        _showErrorDialog('로그인이 필요합니다.');
        return;
      }

      var url = Uri.parse(
          '${RootUrlProvider.baseURL}/alarm/${isUpdate ? "edit" : "create"}');

      http.Response response;

      if (isUpdate) {
        response = await http.patch(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'alarmId': widget.alarms!.first['alarmId'],
            'period': formattedTime,
            'days': _selectedDays,
            'active': widget.alarms!.first['on'],
          }),
        );
      } else {
        response = await http.post(
          url,
          headers: {
            'accept': '*/*',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'period': formattedTime,
            'days': _selectedDays,
            'active': true,
          }),
        );
      }

      if (response.statusCode == 200) {
        print('${isUpdate ? "수정" : "추가"} 성공');
        await cancelAllNotifications(); //알림 취소
        await LoadAlert(); // 알림 로드
        await scheduleNotifications(); // 알림 예약
        Navigator.pop(context, true);
      } else {
        print('응답 코드: ${response.statusCode}');
        print('응답 내용: ${response.body}');
        _showErrorDialog('${isUpdate ? "수정" : "추가"} 실패');
      }
    } catch (e) {
      _showErrorDialog('오류 발생: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height; // 화면 세로 크기 얻기

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.alarms != null ? '알림 수정' : '알림 추가',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true, // 제목을 정확히 가운데 정렬
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey, thickness: 1, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(0),
              child: Column(
                children: [
                  // 시간 선택 Picker
                  _buildTimePicker(screenWidth, screenHeight),
                  SizedBox(height: 20),
                  // 요일 선택 UI
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: screenWidth,
              height: screenHeight * 0.5, // 하단에 배치할 Container 크기
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xffE9EEFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  _selectedDays.isNotEmpty
                      ? Container(
                          width: screenWidth, // 화면 너비 설정
                          height: 40, // 고정된 세로 크기
                          margin: const EdgeInsets.only(left: 16, top: 10),
                          child: Text(
                            "매주 " +
                                _selectedDays.toString().substring(
                                    1, _selectedDays.toString().length - 1),
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        )
                      : Container(
                          width: screenWidth, // 화면 너비 설정
                          height: 40, // 고정된 세로 크기
                          margin: const EdgeInsets.only(left: 16, top: 10),
                          child: Text(
                            "요일을 선택해주세요.",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.left,
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: screenWidth * 0.9,
                    child: _buildDayPicker(screenWidth),
                  ),
                  SizedBox(height: 20),
                  _buildActionButton(screenWidth),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth * 0.9,
      height: screenHeight * 0.3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white, // 전체 배경 흰색
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 선택된 항목의 배경
          Positioned(
            top: (screenHeight * 0.3 - 45) / 2, // Picker 중앙에 위치
            left: 8,
            right: 8,
            child: Container(
              height: 45, // 선택된 행의 높이 (itemExtent와 동일)
              decoration: BoxDecoration(
                // color: Color(0xffE9EEFF), // 선택된 행 배경 색상 - 하늘색
                color: Colors.grey.withOpacity(0.2), // 선택된 행 배경 색상 - 회색
                borderRadius: BorderRadius.circular(12), // 선택된 행 모서리 둥글게
              ),
            ),
          ),
          Row(
            children: [
              // AM/PM Picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 45, // 행 높이
                  selectionOverlay: null,
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedAmPm = index == 0 ? "오전" : "오후");
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedAmPm == "오전" ? 0 : 1,
                  ),
                  children: ["오전", "오후"]
                      .map((period) => Center(
                              child: Text(
                            period,
                            style: TextStyle(
                              fontSize: 24, // 텍스트 크기
                              fontWeight: FontWeight.normal, // 텍스트 두께
                              color: Colors.black, // 텍스트 색상
                            ),
                          )))
                      .toList(),
                ),
              ),
              // 시간 Picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 45, // 행 높이
                  selectionOverlay: null,
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedHour = (index % 12) + 1); // 1~12 순환
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedHour - 1,
                  ),
                  children: List.generate(12, (i) => i + 1)
                      .map((hour) => Center(
                              child: Text(
                            '$hour',
                            style: TextStyle(
                              fontSize: 24, // 텍스트 크기
                              fontWeight: FontWeight.normal, // 텍스트 두께
                              color: Colors.black, // 텍스트 색상
                            ),
                          )))
                      .toList(),
                ),
              ),
              // 구분자 (:)
              Text(':', style: TextStyle(fontSize: 24, color: Colors.black)),
              // 분 Picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 45, // 행 높이
                  selectionOverlay: null,
                  onSelectedItemChanged: (index) {
                    setState(() => _selectedMinute = index % 60); // 0~59 순환
                  },
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedMinute,
                  ),
                  children: List.generate(60, (i) => i)
                      .map((minute) => Center(
                              child: Text(
                            '${minute.toString().padLeft(2, '0')}', // 두 자리로 포맷
                            style: TextStyle(
                              fontSize: 24, // 텍스트 크기
                              fontWeight: FontWeight.normal, // 텍스트 두께
                              color: Colors.black, // 텍스트 색상
                            ),
                          )))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker(double screenWidth) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween, // 아이템들 사이에 균등한 간격을 두기
      children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
        bool isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300), // 애니메이션 지속 시간 설정
            width: screenWidth / 11,
            height: screenWidth / 11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isSelected
                    ? Color(0xFF0038FF)
                    : Colors.transparent, // 선택된 상태에 따라 테두리 색상 변경
                width: 1, // 테두리 두께 설정
              ),
            ),
            curve: Curves.fastOutSlowIn,
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                    color: isSelected ? Color(0xFF0038FF) : Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton(double screenWidth) {
    return SizedBox(
      width: screenWidth * 0.9,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading || _selectedDays.isEmpty
            ? null
            : () => _addOrUpdateAlert(widget.alarms != null),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading || _selectedDays.isEmpty
              ? Colors.grey
              : Color(0xFF0038FF),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.alarms != null ? '수정' : '저장',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
      ),
    );
  }
}
