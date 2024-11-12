import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';

class NewsSummaryPage extends StatelessWidget {
  final News news;

  NewsSummaryPage({required this.news});

  String _getCategoryName(int categoryId) {
    switch (categoryId) {
      case 1:
        return '정치';
      case 2:
        return '사회';
      case 3:
        return '경제';
      default:
        return '기타';
    }
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
                    icon: Icon(Icons.arrow_back),
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
            // News Summary Display
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // company, Title, and Info Section
                    Container(
                      width: screenWidth,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // company
                          Text(
                            news.company,
                            style: TextStyle(
                              fontSize: screenWidth * 0.035,
                              color: Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),

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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
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
                                SizedBox(height: 4),
                              ],
                            ),
                          ),
                          // Buttons Row
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.share),
                                onPressed: () {
                                  // Add share functionality here
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.bookmark_border),
                                onPressed: () {
                                  // Add favorite functionality here
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert),
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
                      // margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors
                            .white, // Background color for the content frame
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        news.content,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: screenWidth * 0.04,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ElevatedButton(
                onPressed: () {
                  // Implement action for "원본 보기"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0XFF0038FF),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '원본 보기',
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
