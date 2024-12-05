<img src = "image/title.png">
<br>

# 🍎 Newsee 프로젝트 소개

Newsee는 1일 1뉴스가 가능하도록 알림을 보내주는 앱 서비스입니다.

뉴스 보는 습관이 없거나, 내용 요약이 필요한 사람들에게, Newsee ! 👀
<br>
<br>

## 🏋🏻‍♀️ Frontend Team
| 팀 | 이름 | 전공 | 역할  | 깃허브 아이디 |
|----| ----- | ----- | -------- | ------- |
| 팀장 | 남민주 | 컴퓨터공학전공 | 프론트엔드 기능 개발 | namminju |
| 팀원 | 이효정 | 컴퓨터공학전공 | 프론트엔드 디자인 및 개발 | HyojunGenius |

<br>


## 1. 개발 환경 및 기술 스택

##### Front-end 
<img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=Flutter&logoColor=white">

##### Language
<img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=Dart&logoColor=white">

##### Tools
<img src="https://img.shields.io/badge/Android%20Studio-3DDC84?style=for-the-badge&logo=Android%20Studio&logoColor=white">
<img src="https://img.shields.io/badge/Figma-F24E1E?style=for-the-badge&logo=Figma&logoColor=white">

<br>


## 2. UI/UX 설계

[🔗 UI/UX](https://www.notion.so/proysm/UI-UX-c48e6ad836a447a686870d33a1ddbf25?pvs=4)

## 3. 프로젝트 디렉토리 구조

<details>
<summary>Backend/src 구조 확인하기</summary>
<div markdown="1">

```
.
newsee
├── assets
│   ├── category
│   │   └── list.json
│   ├── fonts
│   │  
│   ├── images
│       
├── build
├── ios
├── lib
│   ├── API
│   │   └── RootUrlProvider.dart
│   ├── config
│   │   ├── app_config.dart
│   │   └── routes.dart
│   ├── models
│   │   ├── Interests.dart
│   │   ├── news_counter.dart
│   │   ├── news.dart
│   │   └── Playlist.dart
│   ├── presentation
│   │   ├── pages
│   │   │   ├── bookmark
│   │   │   │   └── bookmark_page.dart
│   │   │   ├── home
│   │   │   │   ├── home_page.dart
│   │   │   │   └── news_consumption_chart.dart
│   │   │   ├── login
│   │   │   │   └── login_page.dart
│   │   │   ├── main
│   │   │   │   └── main.dart
│   │   │   ├── mypage
│   │   │   │   ├── alert_setting
│   │   │   │   │   ├── set_alert.dart
│   │   │   │   │   ├── set_alert_page.dart
│   │   │   │   │   ├── time_picker_widget.dart
│   │   │   │   │   └── alert_setting_page.dart
│   │   │   │   ├── profile
│   │   │   │   │   ├── edit_interests
│   │   │   │   │   │   └── edit_interests_page.dart
│   │   │   │   │   ├── edit_name
│   │   │   │   │   │   └── edit_name_page.dart
│   │   │   │   │   └── profile_page.dart
│   │   │   │   └── news
│   │   │   │       ├── news_list_page.dart
│   │   │   │       └── news_shorts_page.dart
│   │   │   ├── playlist
│   │   │   │   ├── playlist_detail
│   │   │   │   │   └── playlist_detail_page.dart
│   │   │   │   ├── playlist_dialog.dart
│   │   │   │   └── playlist_page.dart
│   │   │   ├── search
│   │   │   │   └── search_page.dart
│   │   │   └── select_interests
│   │   │       └── select_interests_page.dart
│   │   └── widgets
│   │       ├── footer
│   │       │   └── footer.dart
│   │       ├── header
│   │       │   └── header.dart
│   │       ├── custom_dialog.dart
│   │       └── news_card.dart
│   ├── services
│   │   ├── alert
│   │   │   ├── alert_database.dart
│   │   │   ├── load_alert.dart
│   │   │   └── schedule_alert.dart
│   │   ├── my_page
│   │   │   ├── edit_name_service.dart
│   │   │   ├── my_page_service.dart
│   │   │   └── profile_page_service.dart
│   │   ├── api_service.dart
│   │   ├── bookmark_service.dart
│   │   ├── interests_service.dart
│   │   ├── login_service.dart
│   │   ├── news_service.dart
│   │   ├── playlist_service.dart
│   │   └── share_service.dart
│   ├── utils
│   │   ├── auth_utils.dart
│   │   └── dialog_utils.dart
│   └── main.dart

```

</div>
</details>

<br>


## 4. 주요 기술 설명

```
1. 카카오 로그인
```
- 사용자가 카카오 계정을 통해 로그인할 수 있는 기능을 제공.
- 로그인

```
2. 뉴스 보기
```
- 뉴스 목록을 카테고리 별로 분류하여 볼 수 있다.
- 각 뉴스의 요약본을 확인할 수 있다.
- 원본 보기 버튼을 클릭하면 외부 링크로 이동하여 뉴스의 원본을 확인할 수 있다.

```
3. 뉴스 공유하기 (카카오)
```
- 뉴스와 플레이리스트를 카카오톡을 통해 공유할 수 있다.
- 
```
4. 뉴스 알람
```
- 알림을 받을 날짜 및 시간을 자유롭게 선택할 수 있다.
- 사용자가 선택한 관심 분야의 뉴스를 한 가지 선택하여 알림으로 보내준다.


<br>


## 📪 개발 문서
[🔗 Figma](https://www.figma.com/design/cgOxj1CazP5apiyEqXAROG/Newsee?node-id=116-2348&t=hFrnE2YeVEDZXYT4-1)

<br>

## 🎯 Commit Convention
| 제목 | 설명 |
| --- | --- |
| Feat : | 새로운 기능 추가 |
| Fix : | 버그 수정 |
| Docs : | 문서 수정 |
| Update : | 기타 업데이트 |
| Style : | 코드 포맷 변경, 세미콜론 누락, 코드 변경 없음 |
| Refactor : | 프로덕션 코드 리팩터링 |

