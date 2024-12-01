import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위한 패키지 임포트
import 'package:newsee/presentation/pages/loginPage/login.dart';
import 'package:newsee/presentation/pages/Main/Main.dart'; // MainPage 임포트
import 'package:newsee/presentation/pages/MyPage/AlertSettingsPage/AlertSettingsPage.dart'; // MainPage 임포트

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'Newsee', // 고유 ID
  'Newsee', // 채널 이름
  description: '오늘은 오류나지 마라', // 설명
  importance: Importance.high,
);

const YOUR_NATIVE_APP_KEY = '26bb41329a634b7abb90a966b30a02b7';
const YOUR_JAVASCRIPT_APP_KEY = '2c8616b833de5f755af7e399d420eea6';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: '${YOUR_NATIVE_APP_KEY}',
    javaScriptAppKey: '${YOUR_JAVASCRIPT_APP_KEY}',
  );

  // 알림 권한 요청
  await _requestNotificationPermission();

  // 시간대 초기화
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  // 알림 채널 생성
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // 알림 초기화
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: onSelectNotification, // 알림 클릭 이벤트 핸들러
  );

  runApp(MyApp());
}

// Android 알림 권한 요청 함수
Future<void> _requestNotificationPermission() async {
  // Android 13 이상에서 권한 요청
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  // 권한이 승인되었는지 확인
  if (await Permission.notification.isGranted) {
    print("알림 권한이 승인되었습니다.");
  } else {
    print("알림 권한이 거부되었습니다.");
  }
}

class MyApp extends StatelessWidget {
  // NavigatorKey 추가
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // NavigatorKey 설정
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

// 알림 클릭 이벤트 핸들러
Future<void> onSelectNotification(NotificationResponse response) async {
  // 알림에서 전달된 payload 확인
  String? payload = response.payload;

  if (payload == 'detail_page') {
    // MainPage로 이동
    MyApp.navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (context) => MainPage()),
    );
  }
}
