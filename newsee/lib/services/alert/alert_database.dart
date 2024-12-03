import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AlarmDatabaseHelper {
  static final AlarmDatabaseHelper _instance = AlarmDatabaseHelper._internal();
  factory AlarmDatabaseHelper() => _instance;
  static Database? _database;

  AlarmDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // DB 초기화
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'alarms.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) {
      return db.execute('''
        CREATE TABLE alarms (
          alarmId INTEGER PRIMARY KEY,
          period TEXT,
          active INTEGER,
          days TEXT
        )
      ''');
    });
  }

  // 알림 데이터 삽입
  Future<void> insertAlarms(List<Map<String, dynamic>> alarms) async {
    final db = await database;
    for (var alarm in alarms) {
      await db.insert(
        'alarms',
        alarm,
        conflictAlgorithm: ConflictAlgorithm.replace, // 업데이트 시 덮어쓰기
      );
    }
  }

  // 알림 데이터 가져오기
  Future<List<Map<String, dynamic>>> getAlarms() async {
    final db = await database;
    return await db.query('alarms');
  }

  // 알림 데이터 업데이트
  Future<void> updateAlarms(List<Map<String, dynamic>> alarms) async {
    final db = await database;
    for (var alarm in alarms) {
      await db.update(
        'alarms',
        alarm,
        where: 'alarmId = ?',
        whereArgs: [alarm['alarmId']],
      );
    }
  } // 모든 알림 삭제

  Future<void> deleteAllAlarms() async {
    final db = await database;
    await db.delete('alarms'); // alarms 테이블의 모든 데이터 삭제
  }
}
