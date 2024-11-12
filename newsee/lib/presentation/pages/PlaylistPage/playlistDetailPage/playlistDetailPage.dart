import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';
import 'package:newsee/presentation/pages/NewsPage/NewsSummaryPage.dart';

class NewsListPage extends StatelessWidget {
  final List<News> news;

  NewsListPage({required this.news});

  // Helper function to get category name
  String _getCategoryName(int categoryId) {
    // Add your logic to map categoryId to category name
    // For example:
    if (categoryId == 1) return 'Politics';
    if (categoryId == 2) return 'Business';
    return 'Other';
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('뉴스 목록'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: news.map((item) {
            return GestureDetector(
              onTap: () {
                // Navigate to the news shorts page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewsSummaryPage(
                        news: item), // Pass the selected news item
                  ),
                );
              },
              child: Container(
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
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // News item UI
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.company,
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                          ),
                        ),
                        Text(
                          _getCategoryName(item
                              .categoryId), // Using the helper function to get the category name
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: const Color(0xFF0038FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.shorts.length > 43
                          ? '${item.shorts.substring(0, 43)}...'
                          : item.shorts,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: screenWidth * 0.025,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
