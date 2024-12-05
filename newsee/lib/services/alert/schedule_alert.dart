import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // 시간을 포맷팅하기 위해 사용
import 'package:timezone/timezone.dart' as tz;
import 'package:newsee/services/alert/alert_database.dart';
import 'package:shared_preferences/shared_preferences.dart'; // SharedPreferences 임포트
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

String AlarmTitle = "";
String AlarmContent = "";
String AlarmId = "";

// 알림 기본 설정
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

Future<void> scheduleNotifications() async {
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  final dbHelper = AlarmDatabaseHelper();
  final alarms = await dbHelper.getAlarms();

  for (var alarm in alarms) {
    if (alarm['active'] == 1) {
      String period = alarm['period'];
      List<String> days = alarm['days'].split(',');
      DateFormat timeFormat = DateFormat("HH:mm");
      DateTime scheduledTime = timeFormat.parse(period);

      // 각 알림마다 loadAlertData 호출하여 최신 데이터 로드
      await loadAlertData();

      for (String day in days) {
        DateTime alarmDateTime = await _getAlarmDateTime(day, scheduledTime);

        // 알림 예약
        await flutterLocalNotificationsPlugin.zonedSchedule(
          alarm['alarmId'],
          AlarmTitle, // 최신 뉴스 제목 사용
          AlarmContent, // 최신 뉴스 내용 사용
          tz.TZDateTime.from(alarmDateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: AlarmId, // 알림 ID만 전달
        );
      }
    }
  }
}

Future<DateTime> _getAlarmDateTime(String day, DateTime scheduledTime) async {
  DateTime currentDate = DateTime.now();
  int dayOfWeek = getDayOfWeekFromString(day);
  int daysDifference = (dayOfWeek - currentDate.weekday + 7) % 7;
  DateTime alarmDateTime = currentDate.add(Duration(days: daysDifference));
  alarmDateTime = DateTime(alarmDateTime.year, alarmDateTime.month,
      alarmDateTime.day, scheduledTime.hour, scheduledTime.minute);

  if (alarmDateTime.isBefore(currentDate)) {
    alarmDateTime = alarmDateTime.add(const Duration(days: 7));
  }

  debugPrint('알림 예약: 예약 시간: $alarmDateTime');
  return alarmDateTime;
}

Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return {
    'token': prefs.getString('token'),
    'userId': prefs.getInt('userId'),
  };
}

Future<void> loadAlertData() async {
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
      var data = json.decode(utf8.decode(response.bodyBytes))['data'];
      AlarmId = data['id'].toString();
      AlarmTitle = data['title'];
      AlarmContent = data['content'];
      debugPrint('알림 데이터 로드 성공: Title: $AlarmTitle, Content: $AlarmContent');
    } else {
      debugPrint('Error: 뉴스 로드 실패');
    }
  } catch (e) {
    debugPrint('Error loading alert data: $e');
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

  const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(badgeNumber: 1);

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
