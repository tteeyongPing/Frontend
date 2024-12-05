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
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              TextField(
                controller: titleController,
                style: const TextStyle(fontSize: 16), // 입력 텍스트 폰트 크기
                decoration: InputDecoration(
                  labelText: '제목',
                  hintText: '제목을 입력하세요',
                  labelStyle: const TextStyle(fontSize: 14), // 레이블 폰트 크기
                  floatingLabelStyle: const TextStyle(color: Color(0xFF4D71F6)),
                  hintStyle: const TextStyle(fontSize: 12), // 힌트 폰트 크기
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF4D71F6), width: 2), // 선택 시 테두리 색상
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 설명 입력
              TextField(
                controller: descriptionController,
                style: const TextStyle(fontSize: 16), // 입력 텍스트 폰트 크기
                decoration: InputDecoration(
                  labelText: '설명',
                  hintText: '플레이리스트 설명을 입력하세요',
                  labelStyle: const TextStyle(fontSize: 14), // 레이블 폰트 크기
                  floatingLabelStyle: const TextStyle(color: Color(0xFF4D71F6)),
                  hintStyle: const TextStyle(fontSize: 12), // 힌트 폰트 크기
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF4D71F6), width: 2), // 선택 시 테두리 색상
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4D71F6), // 버튼 색상 설정
              foregroundColor: Colors.white,
            ),
            child: const Text(
              '생성',
              style: TextStyle(fontSize: 14), // 버튼 폰트 크기
            ),
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
            content: SizedBox(
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
                      decoration: const BoxDecoration(
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
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.grey),
                          left: BorderSide(color: Colors.grey, width: 0.5),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          try {
                            await onDelete(); // 삭제 작업 수행
                            if (context.mounted) {
                              // BuildContext가 여전히 유효한지 확인
                              Navigator.pop(context, true); // 성공적으로 삭제
                            }
                          } catch (e) {
                            if (context.mounted) {
                              // BuildContext가 여전히 유효한지 확인
                              showErrorDialog(context, '삭제 중 오류가 발생했습니다.');
                            }
                          }
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
