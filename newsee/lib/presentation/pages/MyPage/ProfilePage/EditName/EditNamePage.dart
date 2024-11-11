import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/MyPage.dart';

class EditNamePage extends StatefulWidget {
  @override
  _EditNamePageState createState() => _EditNamePageState();
}

class _EditNamePageState extends State<EditNamePage> {
  TextEditingController _controller =
      TextEditingController(); // 입력된 텍스트를 관리하는 컨트롤러

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
                            print('입력한 이름: ${_controller.text}');
                            Navigator.pop(context); // 이름 변경 후 이전 페이지로 돌아가기
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
