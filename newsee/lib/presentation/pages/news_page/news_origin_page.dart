import 'package:flutter/material.dart';
import 'package:newsee/models/News.dart';

class NewsOriginPage extends StatelessWidget {
  final News news;

  const NewsOriginPage({super.key, required this.news});

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
                        '뉴스 오리진 페이지', // Changed to "뉴스 오리진 페이지"
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
                    // Newspaper, Title, and Info Section
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
                          // Newspaper
                          Text(
                            news.newspaper,
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
          ],
        ),
      ),
    );
  }
}