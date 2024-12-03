import 'package:shared_preferences/shared_preferences.dart';

class NewsCounter {
  static const _dailyTotalKey = 'daily_total_count_queue'; // 하루 총 조회수 큐 키
  static const _dateKey = 'last_updated_date';
  static const _queueSize = 14;

  // 뉴스 개수를 날짜별로 저장하는 함수
  static Future<void> recordNewsCount(int newsId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String todayString = _formatDate(now);
    String countKey = 'news_read_count_$newsId$todayString';

    // 조회수 증가
    int currentCount = prefs.getInt(countKey) ?? 0;
    await prefs.setInt(countKey, currentCount + 1);
  }

  // 하루가 지나면 뉴스 별로 기록한 조회수를 초기화하고 총합을 저장하는 함수
  static Future<void> resetDailyCounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String todayString = _formatDate(now);

    // 마지막 업데이트 날짜 확인
    String? lastUpdatedDate = prefs.getString(_dateKey);
    if (lastUpdatedDate == todayString) return; // 이미 업데이트된 경우 종료

    int dailyTotal = 0;

    // 모든 뉴스 아이디 조회 후 오늘자 키 조회
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.contains(todayString)) {
        dailyTotal += prefs.getInt(key) ?? 0;
        await prefs.remove(key); // 개별 뉴스 조회수 기록 삭제
      }
    }

    // 하루치 총 조회수 큐 업데이트
    await _updateDailyTotalQueue(dailyTotal);

    // 마지막 업데이트 날짜를 오늘로 설정
    await prefs.setString(_dateKey, todayString);
  }

  // 하루 총 조회수 큐 업데이트
  static Future<void> _updateDailyTotalQueue(int dailyTotal) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dailyTotals = prefs.getStringList(_dailyTotalKey) ?? [];

    // 총 조회수를 큐에 추가
    dailyTotals.add(dailyTotal.toString());

    // 큐가 2주 이상으로 커지면 오래된 데이터 삭제
    if (dailyTotals.length > _queueSize) {
      dailyTotals.removeAt(0);
    }

    await prefs.setStringList(_dailyTotalKey, dailyTotals);
  }

  // 오늘 날짜의 조회수를 0으로 설정하는 함수
  static Future<void> resetTodayCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = DateTime.now();
    String todayString = _formatDate(now);

    // 오늘 날짜와 관련된 모든 뉴스 조회수 초기화
    Set<String> keys = prefs.getKeys();
    for (String key in keys) {
      if (key.contains(todayString)) {
        await prefs.setInt(key, 0); // 오늘 날짜의 조회수 초기화
      }
    }
  }

  // 2주 동안의 총 조회수 합산 계산
  static Future<int> getTwoWeekTotal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> dailyTotals = prefs.getStringList(_dailyTotalKey) ?? [];

    int total = 0;
    for (String daily in dailyTotals) {
      total += int.tryParse(daily) ?? 0;
    }

    return total;
  }

  // 날짜 형식을 yyyy-MM-dd로 포맷팅하는 함수
  static String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
