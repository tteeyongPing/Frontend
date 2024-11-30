import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/MyPage/ProfilePage/EditName/EditNamePage.dart';
import 'package:newsee/presentation/pages/loginPage/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/Api/RootUrlProvider.dart';

// SharedPreferences에서 사용자 데이터 제거
Future<void> removeUserData() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
  } catch (e) {
    print("SharedPreferences 오류: $e");
  }
}

// 이름 불러오기
Future<String?> getUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userName') ?? ' '; // 기본값 ' ' 반환
}

bool isLoading = false;

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String userName = ' '; // 기본값을 ' '으로 설정

  TextEditingController _controller = TextEditingController();

  // 로딩 상태를 UI에 반영하기 위한 방법 추가
  Widget _buildLoadingIndicator() {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : SizedBox.shrink();
  }

  // 로그아웃 요청 처리
  Future<void> doLogout() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/logout');
      var response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('로그아웃 성공');
        removeUserData(); // 사용자 데이터 삭제
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // 모든 페이지를 제거하고 새 페이지만 남김
        );
      } else {
        _showErrorDialog('로그아웃에 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('로그아웃 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  // 회원 탈퇴 요청 처리
  Future<void> deleteAccount() async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      var url = Uri.parse('${RootUrlProvider.baseURL}/user/leave');
      var response = await http.delete(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('회원 탈퇴 성공');
        removeUserData(); // 사용자 데이터 삭제
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // 모든 페이지를 제거하고 새 페이지만 남김
        );
      } else if (response.statusCode == 404) {
        print('이미 존재하지 않는 계정입니다');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
          (route) => false, // 모든 페이지를 제거하고 새 페이지만 남김
        );
      } else {
        _showErrorDialog('회원 탈퇴에 실패했습니다.');
      }
    } catch (e) {
      print('오류 발생: $e');
      _showErrorDialog('회원 탈퇴 중 오류가 발생했습니다.');
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
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  // 로그아웃 팝업을 표시하는 메서드
  void _showLogoutDialog() {
    showDialog(
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
                "Newsee에서 로그아웃하시겠습니까?",
                style: TextStyle(color: Colors.black),
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("취소", style: TextStyle(color: Colors.black)),
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
                      onPressed: () {
                        doLogout(); // 로그아웃 실행
                      },
                      child: Text("로그아웃", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 서비스 탈퇴 팝업을 표시하는 메서드
  void _showUnsubscribeDialog() {
    showDialog(
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
                "Newsee 서비스를 탈퇴하시겠습니까?",
                style: TextStyle(color: Colors.black),
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("취소", style: TextStyle(color: Colors.black)),
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
                      onPressed: () {
                        deleteAccount();
                      },
                      child:
                          Text("서비스 탈퇴", style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // 내비게이션 행 구성 함수
  Widget buildNavigationRow(String title, {VoidCallback? onTap}) {
    double screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.02,
        ),
        height: kToolbarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: screenWidth * 0.04),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: screenWidth * 0.03,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  // SharedPreferences에서 userName을 가져오는 함수
  Future<void> _loadUserName() async {
    String? name = await getUserName();
    setState(() {
      userName = name ?? ' '; // 값이 없으면 ' '으로 설정
    });
  }

  // Navigate to EditNamePage and update the userName on return
  void _navigateToEditNamePage() async {
    String? updatedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNamePage()),
    );

    // If a new nickname was returned, update the profile page
    if (updatedName != null && updatedName.isNotEmpty) {
      setState(() {
        userName = updatedName; // Update userName with new nickname
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(userName); // nickName 전달
          },
        ),
        flexibleSpace: Center(
          child: Text(
            '$userName님의 정보',
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: Column(
        children: [
          _buildLoadingIndicator(),
          buildNavigationRow('닉네임 변경', onTap: () {
            _navigateToEditNamePage();
          }),
          SizedBox(
            height: kToolbarHeight / 2,
          ),
          buildNavigationRow('로그아웃', onTap: _showLogoutDialog),
          buildNavigationRow('회원 탈퇴', onTap: _showUnsubscribeDialog),
        ],
      ),
    );
  }
}
