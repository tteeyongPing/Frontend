import 'package:flutter/material.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected;

  // 콜백을 받아오는 생성자
  TimePickerWidget({required this.onTimeSelected});

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime time = DateTime.now(); // 현재 시간으로 초기화

  @override
  Widget build(BuildContext context) {
    return ScrollDateTimePicker(
      itemExtent: 54, // 항목의 높이
      infiniteScroll: true, // 무한 스크롤
      dateOption: DateTimePickerOption(
        dateFormat: DateFormat('hh:mm a'), // 시간만 포맷 (AM/PM 뒤에 오도록)
        minDate: DateTime(2024, 1, 1, 0, 0), // 최소시간
        maxDate: DateTime(2024, 1, 1, 23, 59), // 최대시간
        initialDate: time, // initialDate는 최초 선택된 시간
      ),
      onChange: (datetime) {
        setState(() {
          time = datetime; // 시간 업데이트
        });
        widget.onTimeSelected(time); // 선택된 시간을 콜백을 통해 부모로 전달
      },
      itemBuilder: (context, pattern, text, isActive, isDisabled) {
        // `isDisabled`가 true일 때 비활성화 상태인 항목을 구별하기 위해
        if (isDisabled) {
          return Text(
            text,
            style: TextStyle(
              fontSize: 20, // 비활성화된 항목의 폰트 크기
              fontWeight: FontWeight.normal,
              color: Colors.grey, // 비활성화된 항목은 회색
            ),
          );
        } else {
          return Text(
            text,
            style: TextStyle(
              fontSize: isActive ? 30 : 20, // 활성화된 항목은 더 크게 표시
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? Colors.black // 활성화된 항목은 검은색
                  : Colors.lightGreenAccent, // 비활성화된 항목은 연두색
            ),
          );
        }
      },
    );
  }
}
