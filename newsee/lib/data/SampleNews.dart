// data/sample_news.dart

import '../models/News.dart';

List<News> allNewsData = [
  News(
    newsId: 1,
    categoryId: 1, // 예: 1 = 정치
    title: '추석 연휴 10명 중 4명은…"집에서 조용히 쉴래요"',
    date: '2024년 8월 22일',
    content: '''
추석연휴, 가족 방문 42.7%, 집에서 휴식 40.3%
SK텔레콤 AI기반 설문 서비스
T멤버십 고객 대상..1021명 참여
10명 중 6명은 추석에 기대감 없어
차례 치르는 가정 40%에 불과

[이데일리 김현아 기자] SK텔레콤(017670)이 자사의 AI 기반 설문 서비스 ‘돈 버는 설문’을 통해 2024년 추석 연휴에 대한 소비자 인식을 조사하고, 결과를 자사 뉴스룸에 공개했다. 이번 조사는 2024년 8월 21일 T 멤버십 고객을 대상으로 진행되었으며, 총 1021명이 참여했다.

설문 결과에 따르면, 응답자의 42.7%만이 ‘고향 또는 가족, 친척 방문’을 계획하고 있다고 답했다.특히, ‘집에서 휴식’을 계획하는 응답자는 40.3%로, 긴 연휴 동안 특별한 이동 계획 없이 조용히 쉬는 것을 선호하는 사람들이 많은 것으로 나타났다.

추석 연휴에 주로 누구와 시간을 보낼 계획인지 묻는 질문에 ‘직계가족과 함께 지낸다’고 답한 비율은 55%였으며, 부모나 자녀를 방문하거나 방문 오는 경우는 80%에 가까운 것으로 조사됐다.

여행 계획 감소세

추석 연휴 여행에 대한 질문에 ‘계획 중’이라고 응답한 비율은 17.2%로, 대다수의 응답자는 ‘여행 계획이 없다’고 답변했다(67.5%). 작년 추석에 국내/해외 여행을 다녀왔다는 응답자는 전체의 19.7%로, 지난해에 비해 2.5% 감소한 것으로 나타났다.
''',
    newspaper: '이데일리',
    summary: '''
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
    reporter: '김현아',
  ),
  News(
    newsId: 2,
    categoryId: 1, // 정치
    title: '집에서 조용히 쉴래요',
    date: '2023년 10월 2일',
    content:
        '경기관광공사, ‘달맞이 명소’ 6곳 추천\n가평 별빛정원, SNS서 별의 성지로 입소문\n수원화성 서장대, 성곽의 운치와 야경 일품',
    newspaper: '농민신문생활',
    summary: '많은 사람들이 추석 연휴를 집에서 보내기를 원하고 있다.',
    reporter: '이영희',
  ),
  News(
    newsId: 3,
    categoryId: 2, // 사회
    title: '제목 3',
    date: '2023년 10월 3일',
    content: '이것은 세 번째 슬라이드의 내용입니다.',
    newspaper: '농민신문생활',
    summary: '세 번째 뉴스의 요약본입니다.',
    reporter: '김철수',
  ),
  News(
    newsId: 4,
    categoryId: 2, // 사회
    title: '제목 4',
    date: '2023년 10월 4일',
    content: '이것은 네 번째 슬라이드의 내용입니다.',
    newspaper: '농민신문생활',
    summary: '네 번째 뉴스의 요약본입니다.',
    reporter: '박민수',
  ),
  News(
    newsId: 5,
    categoryId: 2, // 사회
    title: '제목 5',
    date: '2023년 10월 5일',
    content: '이것은 다섯 번째 슬라이드의 내용입니다.',
    newspaper: '농민신문생활',
    summary: '다섯 번째 뉴스의 요약본입니다.',
    reporter: '최수민',
  ),
  News(
    newsId: 6,
    categoryId: 3, // 경제
    title: '제목 6',
    date: '2023년 10월 6일',
    content: '이것은 여섯 번째 슬라이드의 내용입니다.',
    newspaper: '농민신문생활',
    summary: '여섯 번째 뉴스의 요약본입니다.',
    reporter: '윤지훈',
  ),
];

List<News> politicsNewsData =
    allNewsData.where((news) => news.categoryId == 1).toList();

List<News> societyNewsData =
    allNewsData.where((news) => news.categoryId == 2).toList();

List<News> economyNewsData =
    allNewsData.where((news) => news.categoryId == 3).toList();
