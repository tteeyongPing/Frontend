import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/mypage/profile/edit_name/edit_name_page.dart';
import 'package:newsee/presentation/pages/login/login_page.dart';
import 'package:newsee/presentation/widgets/custom_dialog.dart';
import 'package:newsee/services/my_page/profile_page_service.dart'; // 새로운 서비스 파일 임포트

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key); // Added key parameter

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String userName = ' '; // 기본값을 ' '으로 설정
  bool isLoading = false;

  Future<void> _loadUserName() async {
    String? name = await UserService.getUserName();
    setState(() {
      userName = name ?? ' ';
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _handleLogout() async {
    setState(() => isLoading = true);
    try {
      String? token = await UserService.getToken();
      bool success = await UserService.logout(token);

      if (success) {
        await UserService.removeUserData();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        _showErrorDialog('로그아웃에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('로그아웃 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    setState(() => isLoading = true);
    try {
      String? token = await UserService.getToken();
      bool success = await UserService.deleteAccount(token);

      if (success) {
        await UserService.removeUserData();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } else {
        _showErrorDialog('회원 탈퇴에 실패했습니다.');
      }
    } catch (e) {
      _showErrorDialog('회원 탈퇴 중 오류가 발생했습니다.');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Newsee에서 로그아웃하시겠습니까?',
          onConfirm: _handleLogout,
        );
      },
    );
  }

  void _showUnsubscribeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: 'Newsee 서비스를 탈퇴하시겠습니까?',
          onConfirm: _handleDeleteAccount,
        );
      },
    );
  }

  void _navigateToEditNamePage() async {
    String? updatedName = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditNamePage()),
    );
    if (updatedName != null && updatedName.isNotEmpty) {
      setState(() {
        userName = updatedName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop(userName);
          },
        ),
        title: Text('$userName님의 정보',
            style: const TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0),
        ),
      ),
      body: Column(
        children: [
          if (isLoading) const Center(child: CircularProgressIndicator()),
          _buildNavigationRow('닉네임 변경', onTap: _navigateToEditNamePage),
          const SizedBox(height: kToolbarHeight / 2.6),
          _buildNavigationRow('로그아웃', onTap: _showLogoutDialog),
          _buildNavigationRow('회원 탈퇴', onTap: _showUnsubscribeDialog),
        ],
      ),
    );
  }

  Widget _buildNavigationRow(String title, {VoidCallback? onTap}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.045,
          vertical: screenWidth * 0.02,
        ),
        height: kToolbarHeight,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Icon(Icons.arrow_forward_ios,
                size: screenWidth * 0.04, color: const Color(0xFFB0B0B0)),
          ],
        ),
      ),
    );
  }
}
