import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeChanged; // 부모로 시간을 전달할 콜백 함수

  TimePickerWidget({required this.onTimeChanged});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ScrollDateTimePicker(
      itemExtent: 54, // 항목의 높이
      infiniteScroll: true, // 무한 스크롤
      dateOption: DateTimePickerOption(
        dateFormat: DateFormat('hh:mm a'), // 시간만 포맷
        minDate: DateTime(2024, 1, 1, 0, 0), // 최소시간
        maxDate: DateTime(2024, 1, 1, 23, 59), // 최대시간
        initialDate: time, // 초기값
      ),
      onChange: (datetime) {
        setState(() {
          time = datetime; // 선택된 시간을 상태에 저장
        });
        widget.onTimeChanged(datetime); // 부모로 시간 전달
      },
      itemBuilder: (context, pattern, text, isActive, isDisabled) {
        return Text(
          text,
          style: TextStyle(
            fontSize: isActive ? 30 : 20, // Bold on active (centered) item
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Color(0xFFB0B0B0),
          ),
        );
      },
    );
  }
}

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
  DateTime? selectedTime; // 선택된 시간 저장 변수

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
    String formattedTime = _selectedAmPm == "오전"
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
        title: Center(
          child: Text(
            widget.alarms != null ? '알림 수정' : '알림 추가',
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(color: Colors.grey, thickness: 1, height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 시간 선택 Picker
                  TimePickerWidget(
                    onTimeChanged: (DateTime newTime) {
                      setState(() {
                        selectedTime = newTime;
                        _selectedHour = newTime.hour;
                        _selectedMinute = newTime.minute;
                        _selectedAmPm = newTime.hour < 12 ? '오전' : '오후';
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  // 요일 선택 UI
                  Container(
                    width: screenWidth * 0.9,
                    child: _buildDayPicker(screenWidth),
                  ),
                  SizedBox(height: 20),
                  // 추가/수정 버튼
                  _buildActionButton(screenWidth),
                ],
              ),
            ),
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Color(0xFF0038FF),
                        spreadRadius: 0.5,
                      ),
                    ]
                  : [], // 선택된 상태일 때만 그림자 추가
            ),
            curve: Curves.easeInOut, // 애니메이션의 곡선 설정 (부드럽게)
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
    return ElevatedButton(
      onPressed:
          isLoading ? null : () => _addOrUpdateAlert(widget.alarms != null),
      style: ElevatedButton.styleFrom(
        minimumSize: Size(screenWidth * 0.8, 50),
        backgroundColor: Colors.blue,
      ),
      child: isLoading
          ? CircularProgressIndicator()
          : Text(
              widget.alarms != null ? '수정하기' : '추가하기',
              style: TextStyle(fontSize: 18),
            ),
    );
  }
}
