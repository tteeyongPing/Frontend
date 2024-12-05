import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // 시간을 포맷팅하기 위해 사용
import 'package:timezone/timezone.dart' as tz;
import 'package:newsee/services/alert/alert_database.dart';
import 'package:newsee/presentation/pages/Main/Main.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> scheduleNotifications() async {
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final dbHelper = AlarmDatabaseHelper();
  final alarms = await dbHelper.getAlarms();

  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'repeating channel id',
    'repeating channel name',
    channelDescription: 'repeating description',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
  );
  const DarwinNotificationDetails iosNotificationDetails =
      DarwinNotificationDetails(badgeNumber: 1);

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails,
    iOS: iosNotificationDetails,
  );

  await loadAlertData();

  for (var alarm in alarms) {
    if (alarm['active'] == 1) {
      String period = alarm['period'];
      List<String> days = alarm['days'].split(',');

      DateFormat timeFormat = DateFormat("HH:mm");
      DateTime scheduledTime = timeFormat.parse(period);

      for (String day in days) {
        DateTime currentDate = DateTime.now();
        int dayOfWeek = getDayOfWeekFromString(day);
        int daysDifference = (dayOfWeek - currentDate.weekday + 7) % 7;
        DateTime alarmDateTime =
            currentDate.add(Duration(days: daysDifference));
        alarmDateTime = DateTime(alarmDateTime.year, alarmDateTime.month,
            alarmDateTime.day, scheduledTime.hour, scheduledTime.minute);

        if (alarmDateTime.isBefore(currentDate)) {
          alarmDateTime = alarmDateTime.add(Duration(days: 7));
        }

        debugPrint('알림 예약: 알림 ID ${alarm['alarmId']} - 예약 시간: $alarmDateTime');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          alarm['alarmId'],
          null, // Title은 비워둡니다
          null, // Content도 비워둡니다
          tz.TZDateTime.from(alarmDateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: alarm['alarmId'].toString(), // 알림 ID만 전달
        );
      }
    }
  }
}

String AlarmTitle = "";
String AlarmContent = "";
String AlarmId = "";

Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}

Future<void> loadAlertData() async {
  // 로딩 상태 업데이트 (상태 관리 필요시 수정)
  try {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];
    final url = Uri.parse('${RootUrlProvider.baseURL}/banner/alarm/news');
    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      AlarmId = data['data']['id'].toString();
      AlarmTitle = data['data']['title'];
      AlarmContent = data['data']['content'];
      debugPrint('알림 데이터 로드 성공: Title: $AlarmTitle, Content: $AlarmContent');
    } else {
      debugPrint('Error: 뉴스 로드 실패');
      // 필요시 에러 처리
    }
  } catch (e) {
    debugPrint('Error loading alert data: $e');
    // 필요시 에러 처리
  }
}

Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

Future<void> showNotification({
  required int id,
  required String title,
  required String body,
  String? payload,
}) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'channelId',
    'channelName',
    channelDescription: 'channelDescription',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
    badgeNumber: 1,
  );

  const NotificationDetails generalNotificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: iosDetails,
  );

  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    generalNotificationDetails,
    payload: payload,
  );
}

int getDayOfWeekFromString(String day) {
  switch (day) {
    case '일':
      return DateTime.sunday;
    case '월':
      return DateTime.monday;
    case '화':
      return DateTime.tuesday;
    case '수':
      return DateTime.wednesday;
    case '목':
      return DateTime.thursday;
    case '금':
      return DateTime.friday;
    case '토':
      return DateTime.saturday;
    default:
      return DateTime.monday; // 기본값
  }
}

void initializeNotificationHandler() {
  flutterLocalNotificationsPlugin.initialize(
    InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        String alarmId = response.payload!;
        await fetchAndShowNotificationDetails(alarmId);
      }
    },
  );
}

Future<void> fetchAndShowNotificationDetails(String alarmId) async {
  try {
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];
    final url =
        Uri.parse('${RootUrlProvider.baseURL}/banner/alarm/news/$alarmId');
    final response = await http.get(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );
    if (response.statusCode == 200) {
      var data = json.decode(utf8.decode(response.bodyBytes));
      String title = data['data']['title'];
      String content = data['data']['content'];

      // 새 알림을 사용자에게 표시
      await showNotification(
        id: int.parse(alarmId),
        title: title,
        body: content,
      );
    } else {
      debugPrint('Error: 알림 데이터 로드 실패');
    }
  } catch (e) {
    debugPrint('Error fetching notification details: $e');
  }
}
