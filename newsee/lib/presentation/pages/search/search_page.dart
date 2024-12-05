import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:newsee/Api/RootUrlProvider.dart';
import 'package:newsee/presentation/pages/news/news_shorts_page.dart';
import 'package:newsee/models/playlist.dart';
import 'package:newsee/presentation/pages/playlist/playlist_detail/playlist_detail_page.dart';

late ScrollController _scrollController;

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

// SharedPreferences에서 토큰 및 유저 ID 가져오는 함수
Future<Map<String, dynamic>> getTokenAndUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  int? userId = prefs.getInt('userId');
  return {'token': token, 'userId': userId};
}

// 오류 메시지를 보여주는 함수
void _showErrorDialog(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('오류'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      );
    },
  );
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();

  bool isLoading = false;
  late List<Map<String, dynamic>> _allNewsData = [];
  late List<Playlist> _allPlayListData = [];
  bool isNewsSelected = true;
  // 플레이리스트 클릭 시 상세 페이지로 이동
  void _navigateToPlaylistDetail(Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PlaylistDetailPage(playlistId: playlist.playlistId),
      ),
    );
  }

  Future<void> loadSearchNewsData(String input) async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url =
          Uri.parse('${RootUrlProvider.baseURL}/search/news?input=$input');
      var response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          _allNewsData =
              List<Map<String, dynamic>>.from(data['data'].map((item) {
            return {
              'id': item['newsId'],
              'title': item['title'],
              'date': item['date'],
              'company': item['company'],
              'reporter': item['reporter'],
              'shorts': item['content']
            };
          }));
        });
      } else if (response.statusCode == 404) {
        _showErrorDialog('뉴스 검색 결과가 없습니다.', context);
      }
    } catch (e) {
      // print('오류 발생: $e');
      _showErrorDialog('뉴스 검색 중 오류가 발생했습니다.$e', context);
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  Future<void> loadSearchPlayListData(String input) async {
    setState(() => isLoading = true); // 로딩 상태 시작
    try {
      final credentials = await getTokenAndUserId();
      String? token = credentials['token'];

      var url =
          Uri.parse('${RootUrlProvider.baseURL}/search/playlist?input=$input');
      var response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = json.decode(utf8.decode(response.bodyBytes)); // UTF-8로 디코딩
        setState(() {
          _allPlayListData = List<Playlist>.from(
            data['data'].map((item) => Playlist.fromJson(item)),
          );
        });
      } else {
        _showErrorDialog('플레이리스트 검색 데이터를 불러오는 데 실패했습니다.', context);
      }
    } catch (e) {
      // print('오류 발생: $e');
      _showErrorDialog('플레이리스트 검색 중 오류가 발생했습니다.$e', context);
    } finally {
      setState(() => isLoading = false); // 로딩 상태 종료
    }
  }

  List<String> _recentSearches = [];
  final FocusNode _focusNode = FocusNode();
  bool isSearchOpen = false;

  // 최근 검색어를 SharedPreferences에서 불러오기
  Future<void> _loadRecentSearches() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recentSearches') ?? [];
    });
  }

// 최근 검색어를 SharedPreferences에 저장하기 (반대로 저장)
  Future<void> _saveRecentSearch(String query) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 이미 최근 검색어 목록에 포함되어 있으면 삭제
    _recentSearches.remove(query);

    // 검색어를 맨 앞에 추가
    _recentSearches.insert(0, query);

    // 최대 5개까지만 저장
    if (_recentSearches.length > 5) {
      _recentSearches.removeLast(); // 5개 이상이면 마지막 항목을 삭제
    }

    // 업데이트된 목록을 SharedPreferences에 저장
    await prefs.setStringList('recentSearches', _recentSearches);
  }

  void _searchItems(String query) {
    setState(() {
      if (isNewsSelected) {
        loadSearchNewsData(query); // 뉴스 검색 함수 호출
      } else {
        loadSearchPlayListData(query); // 플레이리스트 검색 함수 호출
      }
    });
  }

  void _addRecentSearch(String query) {
    _saveRecentSearch(query);
  }

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _scrollController = ScrollController();
    _focusNode.addListener(() {
      setState(() {
        isSearchOpen = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          // Expanded를 없애고 TextField에 직접적으로 크기 설정
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05), // 왼쪽/오른쪽 여백 설정
            child: SizedBox(
              width: screenWidth * 0.68, // TextField의 크기 조정
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: const InputDecoration(
                  hintText: '뉴스 또는 플레이리스트 검색',
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center, // 텍스트 중앙 정렬
                onTap: () {
                  setState(() {
                    isSearchOpen = true;
                  });
                },
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    _addRecentSearch(query); // 최근 검색어 저장
                  }
                  _focusNode.unfocus();
                },
                onChanged: (query) {
                  setState(() {});
                },
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              String query = _searchController.text;
              if (query.isNotEmpty) {
                _searchItems(query);
                _addRecentSearch(query);
              }
              _focusNode.unfocus();
            },
            child: Icon(
              Icons.search,
              color: const Color(0xFF0038FF),
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.05),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: Colors.grey, thickness: 1.0, height: 1.0),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          if (isSearchOpen) {
            setState(() {
              isSearchOpen = false; // 외부 클릭 시 최근 검색어 창 닫기
            });
          }
        },
        child: Stack(
          children: [
            Column(
              children: [
                // 탭을 추가하여 '뉴스'와 '플레이리스트' 선택
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNewsSelected = true;
                        });
                        _searchItems(_searchController.text); // 뉴스 검색
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            '관련된 뉴스',
                            style: TextStyle(
                              fontWeight: isNewsSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                              color: isNewsSelected
                                  ? Colors.black
                                  : const Color(0xFF707070),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isNewsSelected = false;
                        });
                        _searchItems(_searchController.text); // 플레이리스트 검색
                      },
                      child: Container(
                        width: screenWidth * 0.5,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        color: Colors.white,
                        child: Center(
                          child: Text(
                            '관련된 플레이리스트',
                            style: TextStyle(
                              fontWeight: !isNewsSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 16,
                              color: !isNewsSelected
                                  ? Colors.black
                                  : const Color(0xFF707070),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    width: screenWidth * 1, // 너비를 설정
                    alignment: Alignment.centerLeft,
                    child: isNewsSelected
                        ? Container(
                            width: screenWidth * 0.45, // 너비를 설정
                            alignment: Alignment.centerLeft,
                            child: Divider(
                              color: Colors.black, // 구분선 색상
                              height: 1.0, // 구분선의 높이
                              thickness: 2.0, // 구분선의 두께
                              indent: screenWidth * 0.05, // 왼쪽 여백
                              endIndent: 0.0, // 오른쪽 여백
                            ),
                          )
                        : Container(
                            width: screenWidth * 0.95, // 너비를 설정
                            alignment: Alignment.centerLeft,
                            child: Divider(
                              color: Colors.black, // 구분선 색상
                              height: 1.0, // 구분선의 높이
                              thickness: 2.0, // 구분선의 두께
                              indent: screenWidth * 0.55, // 왼쪽 여백
                              endIndent: 0.0, // 오른쪽 여백
                            ),
                          )),
                // 뉴스나 플레이리스트에 맞는 데이터 표시
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: isNewsSelected
                        ? _allNewsData.length
                        : _allPlayListData.length,
                    itemBuilder: (context, index) {
                      if (isNewsSelected) {
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsShortsPage(
                                      newsId: _allNewsData[index]['id']),
                                ),
                              );
                            },
                            child: Container(
                                margin: const EdgeInsets.only(
                                    top: 10, left: 24, right: 24, bottom: 10),
                                padding: const EdgeInsets.only(
                                    top: 12,
                                    left: 17,
                                    right: 17,
                                    bottom: 12), // 왼쪽, 오른쪽, 아래쪽에만 마진

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      spreadRadius: 0,
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: SizedBox(
                                  height: 113, // 원하는 고정 높이를 설정
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _allNewsData[index]['company'],
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                      Text(_allNewsData[index]['title'],
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: const TextStyle(fontSize: 20)),
                                      Text(
                                        _allNewsData[index]['shorts'],
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                )));
                      } else {
                        return GestureDetector(
                          onTap: () => _navigateToPlaylistDetail(
                              _allPlayListData[index]),
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 제목 및 카운트
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _allPlayListData[index].playlistName,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "(${_allPlayListData[index].newsList?.length ?? 0})",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // 설명
                                Text(
                                  _allPlayListData[index].description ?? ' ',
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // 게시자 정보
                                Text(
                                  "게시자: ${_allPlayListData[index].userName}",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ), // 최근 검색어 목록이 열렸을 때
              ],
            ),
            if (isSearchOpen)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _recentSearches.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              flex: 1,
                              child: Center(
                                child: Icon(
                                  Icons.access_time_outlined,
                                  color: Color(0xFF707070),
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              flex: 8,
                              child: Text(
                                _recentSearches[index],
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    // 아이콘 클릭 시 실행할 함수
                                    // print("아이콘이 클릭되었습니다!");
                                    setState(() {
                                      // 해당 검색어를 리스트에서 제거
                                      _recentSearches.removeAt(index);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.clear,
                                    color: Color(0xFF707070),
                                    size: 24.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        onTap: () {
                          _searchController.text = _recentSearches[index];
                          _searchItems(_recentSearches[index]);
                          _focusNode.unfocus(); // 검색어 클릭 후 포커스 해제
                          setState(() {
                            isSearchOpen = false; // 최근 검색어 목록 닫기
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
