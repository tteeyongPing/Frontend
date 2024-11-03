import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/SelectInterests/SelectInterests.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 하얀색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: screenWidth * 0.7,
            ),
            SizedBox(height: screenWidth * 0.04),
            Text('당신만을 위한 뉴스', style: TextStyle(fontSize: screenWidth * 0.04)),
            Text('뉴스로 세상과 대화를 시작해보세요',
                style: TextStyle(fontSize: screenWidth * 0.03)),
            SizedBox(height: screenWidth * 0.15),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SelectInterests()),
                );
              },
              child: Image.asset(
                'assets/kakaoLoginButton.png',
                width: screenWidth * 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
