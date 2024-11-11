import 'package:flutter/material.dart';
import 'package:newsee/presentation/pages/loginPage/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
            Color.fromARGB(255, 13, 20, 45)), // Custom MaterialColor
        scaffoldBackgroundColor: Colors.white, // 모든 페이지의 배경색을 하얀색으로 설정
      ),
      home: LoginPage(),
    );
  }

  // Custom function to create a MaterialColor from a Color
  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = [0.05];
    Map<int, Color> swatch = {};

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    strengths.forEach((strength) {
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        color.red,
        color.green,
        color.blue,
        strength,
      );
    });

    return MaterialColor(color.value, swatch);
  }
}
