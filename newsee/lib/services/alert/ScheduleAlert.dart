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
  // 시간대 초기화
  tz.setLocalLocation(tz.getLocation('Asia/Seoul'));

  // DB에서 알림 목록 가져오기
  final dbHelper = AlarmDatabaseHelper();
  final alarms = await dbHelper.getAlarms();

  // 알림 세부 사항 설정
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    'repeating channel id',
    'repeating channel name',
    channelDescription: 'repeating description',
    importance: Importance.high,
    priority: Priority.high,
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);

  for (var alarm in alarms) {
    // 활성화된 알림만 처리
    if (alarm['active'] == 1) {
      String period = alarm['period']; // 알림 주기 (예: '01:00')
      List<String> days =
          alarm['days'].split(','); // 요일 정보 (예: ['금', '월', '화'])

      DateFormat timeFormat = DateFormat("HH:mm");
      DateTime scheduledTime = timeFormat.parse(period); // 알림 시간

      for (String day in days) {
        DateTime currentDate = DateTime.now();
        int dayOfWeek = getDayOfWeekFromString(day); // '월', '화', '금' 등을 숫자로 변환
        int daysDifference = (dayOfWeek - currentDate.weekday + 7) % 7;
        DateTime alarmDateTime =
            currentDate.add(Duration(days: daysDifference));
        alarmDateTime = DateTime(alarmDateTime.year, alarmDateTime.month,
            alarmDateTime.day, scheduledTime.hour, scheduledTime.minute);

        // 예약된 알림 시간 출력
        print('알림 예약: 알림 ID ${alarm['alarmId']} - 예약 시간: $alarmDateTime');

        await flutterLocalNotificationsPlugin.zonedSchedule(
          alarm['alarmId'], // 알림 ID
          '오늘의 뉴스', // 제목
          "\"마구 버려지는 플라스틱\"...바다는 해양쓰레기로 '몸살'[짤막영상]", // 내용
          tz.TZDateTime.from(alarmDateTime, tz.local), // 예약된 시간
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }
}

// 모든 예약된 알림을 취소
Future<void> cancelAllNotifications() async {
  await flutterLocalNotificationsPlugin.cancelAll();
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
