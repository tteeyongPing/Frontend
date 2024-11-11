import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SetAlertPage extends StatefulWidget {
  @override
  _SetAlertPageState createState() => _SetAlertPageState();
}

class _SetAlertPageState extends State<SetAlertPage> {
  int _selectedHour = 8;
  int _selectedMinute = 30;
  String _selectedAmPm = "AM";
  List<String> _selectedDays = [];

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  void _addAlert() {
    String formattedTime =
        '$_selectedHour:${_selectedMinute.toString().padLeft(2, '0')} $_selectedAmPm';
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('요일을 모두 선택해 주세요.')),
      );
    } else {
      Navigator.pop(context, {
        'date': formattedTime,
        'day': _selectedDays,
        'on': true,
        'selected': false,
      });
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
        title: null,
        flexibleSpace: Center(
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
                                    _selectedHour = (index % 12) + 1; // 1~12 순환
                                  });
                                },
                                children: List.generate(12, (index) {
                                  return Center(
                                      child: Text('${(index % 12) + 1}',
                                          style: TextStyle(fontSize: 24)));
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
                                    _selectedMinute = (index % 60); // 0~59 분 순환
                                  });
                                },
                                children: List.generate(60, (index) {
                                  return Center(
                                      child: Text('$index',
                                          style: TextStyle(fontSize: 24)));
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      Wrap(
                        runSpacing: screenWidth * 0.01, // 여러 줄에 걸친 아이템 간격
                        alignment: WrapAlignment.start,
                        children:
                            ['일', '월', '화', '수', '목', '금', '토'].map((day) {
                          bool isSelected = _selectedDays.contains(day);

                          return Container(
                            width:
                                screenWidth * 0.123, // 고정된 너비 (예: 화면 너비의 12%)
                            child: GestureDetector(
                              onTap: () {
                                _toggleDay(day); // 날짜 선택/해제
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8.0), // 안쪽 여백 추가
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Color(0xFFD0D9F6)
                                      : Colors.grey[200], // 선택된 상태에서 배경색 변경
                                  borderRadius:
                                      BorderRadius.circular(20), // 둥근 모서리
                                ),
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04, // 반응형 글씨 크기
                                      color: isSelected
                                          ? Color(0xFF0038FF)
                                          : Colors.black, // 선택 시 글씨 색 변경
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: screenWidth * 0.9,
                        height: screenWidth * 0.14,
                        child: ElevatedButton(
                          onPressed: _addAlert,
                          child: Text('알림 추가',
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
