import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/AlertSettingsPage/SetAlert/SetAlert.dart'; // SetAlert import 추가

class AlertSettingsPage extends StatefulWidget {
  @override
  _AlertSettingsPageState createState() => _AlertSettingsPageState();
}

class _AlertSettingsPageState extends State<AlertSettingsPage> {
  TextEditingController _controller = TextEditingController();

  // 관심 분야 목록
  final List<Map<String, dynamic>> alarms = [
    {
      'date': '8:50',
      'day': ['월', '화', '수', '목', '금'],
      'on': true,
      'selected': false, // 선택 상태 추가
    },
    {
      'date': '18:10',
      'day': ['목', '금', '토'],
      'on': true,
      'selected': false,
    },
    {
      'date': '22:50',
      'day': ['월', '화'],
      'on': false,
      'selected': false,
    },
  ];

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
                    onPressed: () {
                      // SetAlert 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SetAlertPage()),
                      );
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
                              onChanged: (bool value) {
                                setState(() {
                                  alarm['on'] = value;
                                });
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
