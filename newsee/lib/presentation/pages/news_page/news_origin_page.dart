import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'package:share_plus/share_plus.dart';

class NewsOriginPage extends StatefulWidget {
  final News news;

  const NewsOriginPage({super.key, required this.news});

  @override
  State<NewsOriginPage> createState() => _NewsOriginPageState();
}

class _NewsOriginPageState extends State<NewsOriginPage> {
  String _note = ''; // 메모 내용을 저장할 변수

  void _editNote() {
    TextEditingController noteController =
        TextEditingController(text: _note); // 기존 메모 내용을 초기값으로 설정

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('메모 작성'),
          content: TextField(
            controller: noteController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: '뉴스 기사에 대한 메모를 작성하세요.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // 취소 버튼
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _note = noteController.text; // 메모 내용 업데이트
                });
                Navigator.pop(context); // 팝업 닫기
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
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                left: screenWidth * 0.05,
                top: screenWidth * 0.05,
                right: screenWidth * 0.05,
                bottom: screenWidth * 0.025,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '뉴스 원본',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // News Summary Display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company, Title, and Info Section
                    Container(
                      width: screenWidth,
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, bottom: 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company
                          Text(
                            widget.news.company,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Title
                          Text(
                            widget.news.title,
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Date, Reporter, and Buttons Row with Full-Width Bottom Border
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 4, bottom: 16),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey, // Color of the border
                            width: 1.0, // Thickness of the border
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Date and Reporter Text
                          Flexible(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date
                                Text(
                                  widget.news.date,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.black,
                                  ),
                                ),
                                // Reporter Name
                                Text(
                                  widget.news.reporter,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Buttons Row
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  // 공유 기능
                                  Share.share(
                                    'Check out this news from ${widget.news.company}:\n\n${widget.news.title}\n\n${widget.news.content}',
                                    subject: 'News from ${widget.news.company}',
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark_border),
                                onPressed: () {
                                  // 즐겨찾기 기능 추가
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () {
                                  // 기타 옵션 추가
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_note), // 펜 아이콘
                                onPressed: _editNote, // 메모 작성 호출
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // News Content
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.news.content,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          height: 1.5,
                        ),
                      ),
                    ),

                    // Display Notes
                    if (_note.isNotEmpty) // 메모가 있을 경우 표시
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '메모:\n$_note',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
