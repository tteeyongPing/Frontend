import '../models/Playlist.dart';
import 'SampleNews.dart';

List<Playlist> demoPlaylists = [
  Playlist(
    playlistId: 1,
    playlistName: '추석 관련 뉴스 모음',
    description: '추석 연휴를 앞두고 정치 및 사회 관련 뉴스를 한 곳에 모았습니다.',
    userId: 'user123',
    news: politicsNewsData, // 정치 뉴스 데이터
  ),
  Playlist(
    playlistId: 2,
    playlistName: '사회 핫이슈',
    description: '최근 사회적으로 논의되고 있는 주요 이슈를 모았습니다.',
    userId: 'user456',
    news: societyNewsData, // 사회 뉴스 데이터
  ),
  Playlist(
    playlistId: 3,
    playlistName: '경제 트렌드',
    description: '최신 경제 동향과 관련된 뉴스를 확인해보세요.',
    userId: 'user789',
    news: economyNewsData, // 경제 뉴스 데이터
  ),
];
