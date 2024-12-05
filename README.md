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
| 팀장 | 남민주 | 컴퓨터공학전공 | 프론트엔드 기능 개발  | namminju |
| 팀원 | 이효정 | 컴퓨터공학전공 | 프론트엔드 디자인 및 개발  | HyojunGenius |

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

캡쳐 추가할거에요


## 3. 프로젝트 디렉토리 구조

<details>
<summary>Backend/src 구조 확인하기</summary>
<div markdown="1">

```
.
├── main
│   ├── java
│   │   └── dgu
│   │       └── cse
│   │           └── newsee
│   │               ├── apiPayload
│   │               │   └── exception
│   │               ├── app
│   │               │   ├── controller
│   │               │   └── dto
│   │               ├── config
│   │               ├── domain
│   │               │   ├── converter
│   │               │   ├── entity
│   │               │   └── enums
│   │               ├── jwt
│   │               ├── repository
│   │               ├── service
│   │               │   ├── alarm
│   │               │   ├── bookmark
│   │               │   ├── category
│   │               │   ├── kakao
│   │               │   ├── memo
│   │               │   ├── news
│   │               │   ├── playlist
│   │               │   ├── search
│   │               │   └── user
│   │               └── util
│   └── resources
│       ├── static
│       └── templates
└── test
    └── java
        └── dgu
            └── cse
                └── newsee
```

</div>
</details>

<br>


## 4. 주요 기술 설명 (수정해야함)

```
1. News API
```
- NewsAPI와 NewsDATA API를 사용하여 오늘의 뉴스를 가지고 온다. (fetch)
- 매일 한 번씩 뉴스를 가지고 오고 24h가 지나면 다시 뉴스 정보를 갱신한다. (re-fetch)


```
2. GPT Shorts API
```
- 뉴스의 요약본을 제공하기 위해 GPT API를 사용한다.
- 3줄로 요약하며, 이미 요약본이 있는 News의 경우 저장된 요약본을 사용하고, 요약본이 아직 없는 경우만 GPT에 요청을 보낸다.

```
3. Alarm News
```
- 알림을 보낼 뉴스는 랜덤으로 선택한다.
- 사용자가 설정한 관심분야 중 1개를 고르고, 관심분야의 뉴스 중 1개를 골라서 client에게 전달한다.

<br>

## 5. Clean Code
#### SonarQube
(작성중)

<br>


## 📪 개발 문서
[🔗 Product Backlog](url)

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

