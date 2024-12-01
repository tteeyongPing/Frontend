import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart'; // 시간을 포맷팅하기 위해 사용
import 'package:timezone/timezone.dart' as tz;
import 'package:newsee/services/alert/AlertDatabase.dart';
import 'package:newsee/presentation/pages/Main/Main.dart';

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
          '오늘의 뉴스',
          "\"마구 버려지는 플라스틱\"...바다는 해양쓰레기로 '몸살'[짤막영상]",
          tz.TZDateTime.from(alarmDateTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'detail_page', // MainPage로 이동하는 payload
        );
      }
    }
  }
}

// 모든 예약된 알림을 취소
Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
}

// 알림을 즉시 보여주는 함수
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

// 요일 문자열을 숫자 (1-7)로 변환하는 함수
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
