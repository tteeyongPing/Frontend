import 'package:flutter/material.dart';
import 'package:newsee/data/SampleNews.dart'; // Import news data
import 'package:newsee/models/News.dart';

class BookmarkPage extends StatefulWidget {
  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<News> _displayedNews = [];
  bool _isLoading = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadMoreNews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreNews();
      }
    });
  }

  void _loadMoreNews() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        if (_displayedNews.length < allNewsData.length) {
          _displayedNews.addAll(allNewsData.sublist(
              _displayedNews.length,
              (_displayedNews.length + 4) > allNewsData.length
                  ? allNewsData.length
                  : _displayedNews.length + 4));
        }
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      body: Column(
        children: [
          Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0,
                    blurRadius: 4,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: SizedBox(
                  width: screenWidth,
                  height: 40,
                  child: Center(child: Text("나의 북마크")))),
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  ClipRect(
                    child: Container(
                      width: screenWidth,
                      child: Column(
                        children: _displayedNews.map(
                          (news) {
                            return Container(
                              width: screenWidth * 0.9,
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        news.newspaper,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                        ),
                                      ),
                                      Text(
                                        news.reporter,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: Color(0xFF0038FF),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    news.title,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.05,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    news.summary.length > 43
                                        ? '${news.summary.substring(0, 43)}...'
                                        : news.summary,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: screenWidth * 0.025,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(),
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
