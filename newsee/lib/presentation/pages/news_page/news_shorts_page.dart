import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'news_origin_page.dart';
import 'package:newsee/models/news_counter.dart';

class NewsShortsPage extends StatelessWidget {
  final News news;

  const NewsShortsPage({super.key, required this.news});

  Future<void> _recordViewCount() async {
    await NewsCounter.recordNewsCount(news.newsId);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return FutureBuilder(
      future: _recordViewCount(),
      builder: (context, snapshot) {
        // 조회수 기록 중 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

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
                            '뉴스 요약',
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
                // News Shorts Display
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Newspaper, Title, and Info Section
                        Container(
                          width: screenWidth,
                          padding: const EdgeInsets.only(
                              left: 20, right: 20, bottom: 4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Newspaper
                              Text(
                                news.company,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.035,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),

                              // Title
                              Text(
                                news.title,
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
                                      news.date,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.035,
                                        color: Colors.black,
                                      ),
                                    ),
                                    // Reporter Name
                                    Text(
                                      news.reporter,
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
                                      // Add share functionality here
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.bookmark_border),
                                    onPressed: () {
                                      // Add favorite functionality here
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.more_vert),
                                    onPressed: () {
                                      // Add more options functionality here
                                    },
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
                            news.shorts,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: screenWidth * 0.04,
                              height: 1.5,
                            ),
                          ),
                        ),

                        // Increased spacing between the news Shorts and the button
                        SizedBox(
                            height: screenWidth *
                                0.08), // Adjusted for tighter spacing

                        // Button to navigate to News Origin Page
                        Center(
                          child: Container(
                            width: screenWidth * 0.84,
                            height: screenWidth * 0.14,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.25), // 25% opacity for #000000
                                  offset: const Offset(0, 4), // x: 0, y: 4
                                  blurRadius: 4, // blur radius of 4
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        NewsOriginPage(news: news),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF333333),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.0),
                                ),
                              ),
                              child: Text(
                                '원본 보기',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.032,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Additional bottom spacing for scroll padding
                        SizedBox(height: screenWidth * 0.1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
