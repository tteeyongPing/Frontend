import 'package:flutter/material.dart';
import 'package:newsee/models/Playlist.dart';
import 'package:share_plus/share_plus.dart';

class PlaylistDetailPage extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  late String _description; // 설명을 저장하는 상태 변수

  @override
  void initState() {
    super.initState();
    _description = widget.playlist.description; // 초기 설명값 설정
  }

  void _sharePlaylist() {
    final String shareContent = '''
플레이리스트: ${widget.playlist.playlistName}
설명: $_description
작성자: ${widget.playlist.userId}
뉴스 개수: ${widget.playlist.news.length}
    
뉴스 목록:
${widget.playlist.news.map((news) => '- ${news.title}').join('\n')}
    ''';

    Share.share(shareContent, subject: '플레이리스트 공유');
  }

  void _editDescription(BuildContext context) {
    TextEditingController descriptionController =
        TextEditingController(text: _description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('설명 수정'),
          content: TextField(
            controller: descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: '새로운 설명을 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _description = descriptionController.text; // 설명 업데이트
                });
                Navigator.pop(context); // 다이얼로그 닫기
              },
              child: const Text('저장'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text(
          '나의 플레이리스트',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Title Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFD4D4D4), width: 1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Playlist Name
                Text(
                  widget.playlist.playlistName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Playlist Description
                Text(
                  _description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Playlist Info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '작성자: ${widget.playlist.userId}',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '뉴스: ${widget.playlist.news.length}개',
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Buttons Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 버튼 중앙 정렬
                  children: [
                    ElevatedButton.icon(
                      onPressed: _sharePlaylist, // 공유 기능 호출
                      icon: const Icon(Icons.share,
                          size: 18, color: Colors.white),
                      label: const Text(
                        '공유하기',
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4D71F6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16), // 버튼 간 간격
                    ElevatedButton.icon(
                      onPressed: () => _editDescription(context), // 수정 기능 호출
                      icon:
                          const Icon(Icons.edit, size: 18, color: Colors.black),
                      label: const Text(
                        '수정하기',
                        style: TextStyle(fontSize: 10, color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD6D6D6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // News Items
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.playlist.news.length,
            itemBuilder: (context, index) {
              final news = widget.playlist.news[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                height: 113, // 전체 높이를 고정
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
                    // Header (Source and Category)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          news.company,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          "카테고리: ${news.categoryId}", // Replace with actual category name if available
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0038FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),

                    // Title
                    Container(
                      height: 43, // 제목 높이를 고정
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
                        children: [
                          Text(
                            news.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              height: 1.5, // 줄 간격
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center, // 수평 중앙 정렬
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),

                    // Summary
                    Expanded(
                      child: Text(
                        news.content,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          height: 1.5, // 텍스트 줄 간격 조절
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start, // 텍스트는 왼쪽 정렬
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ]),
      ),
    );
  }
}
