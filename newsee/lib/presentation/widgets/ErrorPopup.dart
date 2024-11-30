import 'package:flutter/material.dart'; // showDialog 및 AlertDialog를 사용하기 위한 import

// 오류 메시지를 보여주는 함수 (State 클래스 내에서 사용)
void _showErrorDialog(BuildContext context, String message) {
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
