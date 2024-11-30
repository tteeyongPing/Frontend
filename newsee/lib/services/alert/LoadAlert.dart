import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newsee/services/alert/AlertDatabase.dart';
import 'package:newsee/services/getTokenAndUserId.dart';
import 'package:newsee/Api/RootUrlProvider.dart';

Future<void> printAlarms() async {
  final dbHelper = AlarmDatabaseHelper();
  final alarms = await dbHelper.getAlarms();
  print(alarms); // DB에서 가져온 알림 리스트 출력
}

Future<void> loadAlert() async {
  try {
    // 로그인 정보 및 토큰 가져오기
    final credentials = await getTokenAndUserId();
    String? token = credentials['token'];

    // 알림 API 요청
    var url = Uri.parse('${RootUrlProvider.baseURL}/alarm');
    var response = await http.get(url, headers: {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      // 서버 응답이 성공일 경우
      var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
      List<Map<String, dynamic>> newAlarms =
          List<Map<String, dynamic>>.from(data['data'].map((item) {
        return {
          'alarmId': item['alarmId'],
          'period': item['period'],
          'active': item['active'] ? 1 : 0, // DB에서는 bool 대신 0/1로 저장
          'days': item['days'].join(','), // 리스트를 콤마로 구분된 문자열로 저장
        };
      }));

      // DB에 알림 데이터 삽입/업데이트 하기 전에 기존 알림 삭제
      AlarmDatabaseHelper dbHelper = AlarmDatabaseHelper();

      // 기존 알림 삭제
      await dbHelper.deleteAllAlarms(); // 모든 알림을 삭제 (초기화)

      // 새로 받은 알림을 DB에 삽입
      if (newAlarms.isNotEmpty) {
        await dbHelper.insertAlarms(newAlarms);
      }

      // DB에서 알림 목록 출력
      printAlarms(); // 알림 데이터 출력
    } else if (response.statusCode == 404) {
      // 알림이 없을 경우
      print('알림을 찾을 수 없습니다.');
    } else {
      // 다른 오류 처리
      print('알림 목록을 불러오는 데 실패했습니다. 상태 코드: ${response.statusCode}');
    }
  } catch (e) {
    // 예외 처리
    print('오류 발생: $e');
    // 여기서 사용자에게 오류 메시지를 보여주는 방법을 추가할 수 있음
  }
}
