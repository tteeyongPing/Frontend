import 'package:flutter/material.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.onTimeSelected,
  });

  @override
  TimePickerWidgetState createState() => TimePickerWidgetState();
}

class TimePickerWidgetState extends State<TimePickerWidget> {
  static const double _activeItemFontSize = 30.0;
  static const double _inactiveItemFontSize = 20.0;
  static const double _itemExtent = 54.0;

  final DateTime _initialDate = DateTime.now();
  final DateTime _minDate = DateTime(2024, 1, 1, 0, 0);
  final DateTime _maxDate = DateTime(2024, 1, 1, 23, 59);

  late DateTime _selectedTime = _initialDate;

  TextStyle _getTextStyle({
    required bool isActive,
    required bool isDisabled,
  }) {
    if (isDisabled) {
      return const TextStyle(
        fontSize: _inactiveItemFontSize,
        fontWeight: FontWeight.normal,
        color: Colors.grey,
      );
    }

    return TextStyle(
      fontSize: isActive ? _activeItemFontSize : _inactiveItemFontSize,
      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      color: isActive ? Colors.black : Colors.lightGreenAccent,
    );
  }

  void _handleTimeChange(DateTime datetime) {
    setState(() {
      _selectedTime = datetime;
    });
    widget.onTimeSelected(_selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollDateTimePicker(
      itemExtent: _itemExtent,
      infiniteScroll: true,
      dateOption: DateTimePickerOption(
        dateFormat: DateFormat('hh:mm a'),
        minDate: _minDate,
        maxDate: _maxDate,
        initialDate: _initialDate,
      ),
      onChange: _handleTimeChange,
      itemBuilder: (context, pattern, text, isActive, isDisabled) {
        return Text(
          text,
          style: _getTextStyle(
            isActive: isActive,
            isDisabled: isDisabled,
          ),
        );
      },
    );
  }
}
