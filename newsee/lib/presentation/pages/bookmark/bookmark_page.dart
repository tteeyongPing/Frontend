import 'package:flutter/material.dart';
import 'package:newsee/models/news.dart';
import 'package:newsee/presentation/widgets/news_card.dart';
import 'package:newsee/services/bookmark_service.dart';
import 'package:newsee/utils/dialog_utils.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<News> allNewsData = [];
  bool _isLoading = false;
  bool _isEditing = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadBookmarks();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 북마크 데이터 로드
  Future<void> _loadBookmarks() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    allNewsData.clear();
    try {
      final bookmarkData = await fetchBookmarks();
      if (!mounted) return;
      setState(() {
        allNewsData = bookmarkData.map((item) => News.fromJson(item)).toList();
      });
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      if (!mounted) return;
      showErrorDialog(context, '에러가 발생했습니다: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // 선택 상태 토글
  void _toggleSelection(News news) {
    setState(() {
      news.selected = !news.selected;
    });
  }

  Future<void> deleteSelectedNews() async {
    final selectedNews = allNewsData.where((news) => news.selected).toList();

    for (var news in selectedNews) {
      try {
        bool success = await deleteBookmark(news.newsId);
        if (success && mounted) {
          setState(() {
            allNewsData
                .removeWhere((newsItem) => newsItem.newsId == news.newsId);
          });
        }
      } catch (e) {
        debugPrint('Error deleting bookmark: $e');
        if (!mounted) return;
        showErrorDialog(context, '에러가 발생했습니다: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // 헤더
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 4,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              width: screenWidth,
              height: 40,
              child: const Center(
                child: Text(
                  "나의 북마크",
                  style: TextStyle(
                    fontSize: 18,
                    fontVariations: [
                      FontVariation('wght', 700), // wght 축을 사용하여 굵기 조정
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 본문
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // 상단 툴바
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("북마크한 뉴스: ${allNewsData.length}"),
                        GestureDetector(
                          onTap: () async {
                            if (_isEditing) {
                              await deleteSelectedNews();
                              setState(() => _isEditing = false);
                            } else {
                              setState(() => _isEditing = true);
                            }
                          },
                          child: Text(
                            _isEditing ? '삭제' : '편집',
                            style: const TextStyle(color: Color(0xFF4D71F6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Column(
                      children: allNewsData.map((news) {
                        return NewsCard(
                          news: news,
                          isEditing: _isEditing,
                          onSelected: (isSelected) {
                            _toggleSelection(news);
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
