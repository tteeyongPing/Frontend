import 'package:flutter/material.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected; // 시간을 전달할 콜백 추가

  TimePickerWidget({required this.onTimeSelected}); // 콜백을 받아오는 생성자

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  DateTime time = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ScrollDateTimePicker(
      itemExtent: 54,
      infiniteScroll: true,
      dateOption: DateTimePickerOption(
        dateFormat: DateFormat('a hh:mm'),
        minDate: DateTime(2024, 1, 1, 0, 0),
        maxDate: DateTime(2024, 1, 1, 23, 59),
        initialDate: time,
      ),
      onChange: (datetime) {
        setState(() {
          time = datetime;
        });
        widget.onTimeSelected(time); // 선택된 시간을 콜백을 통해 부모로 전달
      },
      itemBuilder: (context, pattern, text, isActive, isDisabled) {
        return Text(
          text,
          style: TextStyle(
            fontSize: isActive ? 30 : 20,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black : Color(0xFFB0B0B0),
          ),
        );
      },
    );
  }
}
