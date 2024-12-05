import 'package:flutter/material.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart'; // 카카오 SDK 임포트
import 'package:permission_handler/permission_handler.dart'; // 권한 요청을 위한 패키지 임포트
import 'package:newsee/presentation/pages/login/login_page.dart';
import 'package:newsee/presentation/pages/news/news_shorts_page.dart'; // NewsShortsPage 임포트
import 'package:newsee/presentation/pages/playlist/playlist_detail/playlist_detail_page.dart';
// AlertSettingPage 임포트
import 'package:newsee/models/news_counter.dart';
import 'package:app_links/app_links.dart';

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
  // 앱 링크 초기화
  await _initAppLinks(); // 앱 링크 초기화 호출
  await NewsCounter.resetTodayCount();

  // Flutter SDK 초기화
  KakaoSdk.init(
    nativeAppKey: YOUR_NATIVE_APP_KEY,
    javaScriptAppKey: YOUR_JAVASCRIPT_APP_KEY,
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
    onDidReceiveNotificationResponse: onSelectNotification,
  );

  runApp(const MyApp());
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

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // NavigatorKey 설정
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: createMaterialColor(
            Color.fromARGB(255, 13, 20, 45)), // Custom MaterialColor
        scaffoldBackgroundColor: Colors.white, // 모든 페이지의 배경색을 하얀색으로 설정
        fontFamily: 'Pretendard', // 전체 폰트 Pretendard로 설정
        dialogBackgroundColor: Colors.white,
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

Future<void> onSelectNotification(NotificationResponse response) async {
  // 알림에서 전달된 payload 확인
  String? payload = response.payload;

  if (payload != null) {
    try {
      // payload를 int로 변환
      int newsId = int.parse(payload);

      // MainPage로 이동
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => NewsShortsPage(newsId: newsId)),
      );
    } catch (e) {
      // payload가 유효한 숫자 형태가 아닌 경우 처리
      print("잘못된 payload 형식: $e");
      // 필요 시 사용자에게 오류를 알리거나 다른 처리 추가
    }
  } else {
    print("payload가 null입니다.");
    // 필요 시 사용자에게 오류를 알리거나 다른 처리 추가
  }
}

final AppLinks _appLinks = AppLinks();

// 앱이 시작될 때 URL을 받습니다.
Future<void> _initAppLinks() async {
  // 앱이 처음 실행될 때 링크를 받음
  final initialLink = await _appLinks.getInitialLink();
  if (initialLink != null) {
    _handleLink(initialLink.toString()); // 초기 링크 처리
  }
  print("link" + initialLink.toString());
  // 백그라운드에서 실행될 때 링크를 받을 수 있도록 처리
  _appLinks.uriLinkStream.listen((link) {
    _handleLink(link.toString());
  });
}

// 받은 URL에서 파라미터를 추출하여 해당 페이지로 이동
void _handleLink(String link) {
  Uri uri = Uri.parse(link);
  String? key1 = uri.queryParameters['key1'];
  String? key2 = uri.queryParameters['key2'];
  print("Handling link: $link 키는 /$key1/$key2");

  if (key1 == "news") {
    if (key2 != null) {
      try {
        int newsId = int.parse(key2);
        Navigator.push(
          MyApp.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => NewsShortsPage(newsId: newsId)),
        );
      } catch (e) {
        print("Invalid key2 format: $e");
      }
    } else {
      print("Invalid key2: $key2");
    }
  } else if (key1 == 'playlist') {
    if (key2 != null) {
      Navigator.push(
        MyApp.navigatorKey.currentContext!,
        MaterialPageRoute(
            builder: (context) => PlaylistDetailPage(
                  playlistId: int.parse(key2),
                )),
      );
    } else {
      print("Invalid key2: $key2");
    }
  }
}
