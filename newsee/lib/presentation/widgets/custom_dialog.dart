import 'package:flutter/material.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final VoidCallback onConfirm;

  // Pass 'key' directly to the super constructor
  const CustomDialog({
    super.key,
    required this.title,
    required this.onConfirm,
  }); // 'key' is passed to the super constructor

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.zero,
      actionsPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 260,
        height: 80,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      actions: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                    right: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("취소"),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey, width: 0.5),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    onConfirm();
                    Navigator.pop(context);
                  },
                  child: const Text("확인"),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
