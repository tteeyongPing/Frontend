// data/sample_news.dart

import '../models/News.dart';

List<News> allNewsData = [
  News(
    newsId: 1,
    categoryId: 1, // 예: 1 = 정치
    title: '추석 연휴 10명 중 4명은…"집에서 조용히 쉴래요"',
    date: '2024년 8월 22일',
    content: '''
조사 기관: SK텔레콤의 AI 기반 설문 서비스 ‘돈 버는 설문’

대상: T 멤버십 고객 1021명 (2024년 8월 21일 조사)

주요 결과:

- 가족 방문 계획: 42.7%가 고향 또는 가족 방문 계획
- 휴식 계획: 40.3%가 집에서 휴식 계획
- 직계가족과 함께 보낼 비율: 55%
- 부모/자녀 방문 비율: 80% 가까이
- 여행 계획: 17.2%가 여행 계획 중, 67.5%는 여행 계획 없음
- 작년 대비 감소: 지난해 추석 여행 경험 19.7%로 2.5% 감소
- 기타: 응답자 중 10명 중 6명은 추석에 대한 기대감이 없다고 응답하며, 차례를 치르는 가정은 40%에 불과함.
''',
    company: '이데일리',
    shorts: 'SK텔레콤이 T 멤버십 고객 1021명을 대상으로 한 추석 연휴 소비자 인식 조사 결과를 발표했다.',
    reporter: '홍길동 기자',
  ),
  News(
    newsId: 2,
    categoryId: 1, // 정치
    title: '집에서 조용히 쉴래요',
    date: '2023년 10월 2일',
    content:
        '경기관광공사, ‘달맞이 명소’ 6곳 추천\n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    company: '농민신문생활',
    shorts: '많은 사람들이 추석 연휴를 집에서 보내기를 원하고 있다.',
    reporter: '이영희 기자',
  ),
  News(
    newsId: 3,
    categoryId: 2, // 사회
    title: '제목 3',
    date: '2023년 10월 3일',
    content: '이것은 세 번째 슬라이드의 내용입니다.',
    company: '농민신문생활', 
    shorts: '세 번째 뉴스의 요약본입니다.',
    reporter: '김철수 기자',
  ),
  News(
    newsId: 4,
    categoryId: 2, // 사회
    title: '제목 4',
    date: '2023년 10월 4일',
    content: '이것은 네 번째 슬라이드의 내용입니다.',
    company: '농민신문생활',
    shorts: '네 번째 뉴스의 요약본입니다.',
    reporter: '박민수 기자',
  ),
  News(
    newsId: 5,
    categoryId: 2, // 사회
    title: '제목 5',
    date: '2023년 10월 5일',
    content: '이것은 다섯 번째 슬라이드의 내용입니다.',
    company: '농민신문생활',
    shorts: '다섯 번째 뉴스의 요약본입니다.',
    reporter: '최수민 기자',
  ),
  News(
    newsId: 6,
    categoryId: 3, // 경제
    title: '제목 6',
    date: '2023년 10월 6일',
    content: '이것은 여섯 번째 슬라이드의 내용입니다.',
    company: '농민신문생활',
    shorts: '여섯 번째 뉴스의 요약본입니다.',
    reporter: '윤지훈 기자',
  ),
];

List<News> politicsNewsData =
    allNewsData.where((news) => news.categoryId == 1).toList();

List<News> societyNewsData =
    allNewsData.where((news) => news.categoryId == 2).toList();

List<News> economyNewsData =
    allNewsData.where((news) => news.categoryId == 3).toList();
