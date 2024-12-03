import 'package:flutter/material.dart';
import 'package:newsee/utils/dialog_utils.dart'; // showErrorDialog를 사용하려면 import

Future<void> showPlaylistDialog(BuildContext context,
    Function(String title, String description) onSubmit) async {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text(
          '플레이리스트 생성',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: '제목',
                  hintText: '제목을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 설명 입력
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: '설명',
                  hintText: '플레이리스트 설명을 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 다이얼로그 닫기
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              String title = titleController.text.trim();
              String description = descriptionController.text.trim();

              if (title.isEmpty) {
                showErrorDialog(context, '제목을 입력해주세요.');
                return;
              }

              Navigator.pop(context); // 다이얼로그 닫기
              onSubmit(title, description); // 입력 데이터를 콜백으로 전달
            },
            child: const Text('생성'),
          ),
        ],
      );
    },
  );
}

Future<bool> showDeleteDialog({
  required BuildContext context,
  required String message,
  required Future<void> Function() onDelete,
}) async {
  bool isDeleted = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.zero,
            actionsPadding: EdgeInsets.zero,
            content: Container(
              width: 260,
              height: 80,
              child: Center(
                child: Text(
                  message,
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
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey),
                          right: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text(
                          "취소",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey),
                          left: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          await onDelete(); // 삭제 작업 수행
                          Navigator.pop(context, true); // 성공적으로 삭제
                        },
                        child: const Text(
                          "삭제",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ) ??
      false; // 다이얼로그 취소 시 false 반환

  return isDeleted; // 삭제 성공 여부 반환
}
