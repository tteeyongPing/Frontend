import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // JSON 변환을 위한 import
import 'package:shared_preferences/shared_preferences.dart';

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
                  _buildTimePicker(screenWidth),
                  SizedBox(height: 20),
                  // 요일 선택 UI
                  _buildDayPicker(screenWidth),
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

  Widget _buildTimePicker(double screenWidth) {
    return Container(
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
              onSelectedItemChanged: (index) {
                setState(() => _selectedAmPm = index == 0 ? "오전" : "오후");
              },
              scrollController: FixedExtentScrollController(
                initialItem: _selectedAmPm == "오전" ? 0 : 1,
              ),
              children: ["오전", "오후"]
                  .map((period) => Center(
                      child: Text(period, style: TextStyle(fontSize: 24))))
                  .toList(),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 50.0,
              onSelectedItemChanged: (index) {
                setState(() => _selectedHour = (index % 12) + 1);
              },
              scrollController: FixedExtentScrollController(
                initialItem: _selectedHour - 1,
              ),
              children: List.generate(12, (i) => i + 1)
                  .map((hour) => Center(
                      child: Text('$hour', style: TextStyle(fontSize: 24))))
                  .toList(),
            ),
          ),
          Text(':', style: TextStyle(fontSize: 30)),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 50.0,
              onSelectedItemChanged: (index) {
                setState(() => _selectedMinute = index);
              },
              scrollController: FixedExtentScrollController(
                initialItem: _selectedMinute,
              ),
              children: List.generate(60, (i) => i)
                  .map((minute) => Center(
                      child: Text('$minute', style: TextStyle(fontSize: 24))))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayPicker(double screenWidth) {
    return Wrap(
      alignment: WrapAlignment.start,
      children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
        bool isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () => _toggleDay(day),
          child: Container(
            width: screenWidth * 0.123,
            margin: EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFD0D9F6) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  color: isSelected ? Color(0xFF0038FF) : Colors.black,
                ),
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
        onPressed:
            isLoading ? null : () => _addOrUpdateAlert(widget.alarms != null),
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : Colors.blue,
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Text(
                widget.alarms != null ? '수정' : '추가',
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
