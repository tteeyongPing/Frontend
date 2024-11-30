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

// 이름 저장
Future<void> saveUserName(String userName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userName', userName);
}

class _EditNamePageState extends State<EditNamePage> {
  TextEditingController _controller =
      TextEditingController(); // 입력된 텍스트를 관리하는 컨트롤러
  bool isLoading = false;

  // 닉네임 업데이트를 위한 API 호출
  Future<void> patchNickname(String nickname) async {
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
        saveUserName('$nickname');
        Navigator.pop(context, nickname);
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
        title: Text(
          '닉네임 변경',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),

        centerTitle: true, // 제목을 정확히 가운데 정렬
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          Divider(
            color: Colors.grey,
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '이름을 입력하세요',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {}); // 입력 값이 변경될 때마다 UI를 갱신
                        },
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: screenWidth * 0.9,
                        height: screenWidth * 0.14,
                        child: ElevatedButton(
                          onPressed: _controller.text.isEmpty
                              ? null // 입력값이 없으면 버튼 비활성화
                              : () {
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
