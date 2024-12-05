import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:share_plus/share_plus.dart';

/// 카카오톡 공유 기능
Future<void> shareViaKakaoTalk(String playlistName) async {
  bool isKakaoTalkSharingAvailable =
      await ShareClient.instance.isKakaoTalkSharingAvailable();

  if (isKakaoTalkSharingAvailable) {
    try {
      Uri uri = await ShareClient.instance.shareDefault(
        template: TextTemplate(
          text: 'Newsee\n친구가 플레이 리스트를 공유했어요!\n$playlistName',
          link: Link(),
          buttonTitle: "플레이 리스트 보러가기",
        ),
      );
      await ShareClient.instance.launchKakaoTalk(uri);
      // print('카카오톡 공유 완료');
    } catch (error) {
      // print('카카오톡 공유 실패: $error');
    }
  } else {
    try {
      Uri shareUrl = await WebSharerClient.instance.makeDefaultUrl(
        template: TextTemplate(
          text: 'Newsee\n친구가 플레이 리스트를 공유했어요!\n$playlistName',
          link: Link(),
          buttonTitle: "플레이 리스트 보러가기",
        ),
      );
      await launchBrowserTab(shareUrl, popupOpen: true);
    } catch (error) {
      // print('카카오톡 공유 실패: $error');
    }
  }
}

/// 기본 공유 기능
void sharePlaylistDetails(String playlistName, String description,
    String userName, List<String> newsTitles) {
  final String shareContent = '''
플레이리스트: $playlistName
설명: $description
작성자: $userName
뉴스 개수: ${newsTitles.length}
    
뉴스 목록:
${newsTitles.map((title) => '- $title').join('\n')}
  ''';
  Share.share(shareContent, subject: '플레이리스트 공유');
}
