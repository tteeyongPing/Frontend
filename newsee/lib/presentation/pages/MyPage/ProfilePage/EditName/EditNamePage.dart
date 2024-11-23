import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditNamePage extends StatefulWidget {
  @override
  _EditNamePageState createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  TextEditingController _controller =
      TextEditingController(); // 입력된 텍스트를 관리하는 컨트롤러
  bool isLoading = false;

  Future<void> patchNickname(nickname) async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var url = Uri.parse(
          '${RootUrlProvider.baseURL}/user/nickname/edit?nickname=$nickname');
      var response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        print('닉네임 변경 성공');
        Navigator.pop(context); // 네비게이션 팝
      } else if (response.statusCode == 409) {
        _showErrorDialog('이미 존재하는 닉네임입니다.\n 다른 닉네임을 사용해주세요.');
      } else {
        _showErrorDialog('닉네임 변경을 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('저장 중 오류가 발생했습니다: $e');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 오류 메시지를 보여주는 함수
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // '확인' 버튼
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 뒤로가기 아이콘
          onPressed: () => Navigator.of(context).pop(), // 뒤로가기 처리
        ),
        title: null, // 기본 title을 null로 설정
        flexibleSpace: Center(
          child: Text(
            '닉네임 변경',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Divider 추가: AppBar와 body 사이에 구분선
          Divider(
            color: Colors.grey, // 구분선 색상 설정
            thickness: 1, // 구분선 두께 설정
            height: 1, // 구분선과 AppBar 간의 간격 설정
          ),
          // 나머지 content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
                    children: [
                      Text(
                        '닉네임 변경',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(height: 24),
                      Container(
                        width: screenWidth * 0.9,
                        child: Text(
                          '변경할 이름을 입력해주세요.',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      SizedBox(height: 8),
                      // 텍스트 입력 필드
                      TextField(
                        controller: _controller, // 컨트롤러 연결
                        decoration: InputDecoration(
                          hintText: '이름을 입력하세요',
                          border: OutlineInputBorder(), // 입력 필드의 테두리
                        ),
                      ),
                      SizedBox(height: 20),
                      // 저장하기 버튼
                      Container(
                        width: screenWidth * 0.9,
                        height: screenWidth * 0.14,
                        child: ElevatedButton(
                          onPressed: () {
                            // 입력된 텍스트를 출력하거나 다른 작업을 할 수 있습니다.
                            patchNickname(_controller.text);
                          },
                          child: Text(
                            '저장하기',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.04),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF0038FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
