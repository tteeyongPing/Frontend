import 'package:flutter/material.dart';
import 'package:newsee/models/news.dart';
import 'package:newsee/presentation/pages/news/news_shorts_page.dart';

class NewsCard extends StatelessWidget {
  final News news;
  final ValueChanged<bool> onSelected;
  final bool isEditing;

  const NewsCard({
    required this.news,
    required this.onSelected,
    required this.isEditing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsShortsPage(newsId: news.newsId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10, left: 24, right: 24, bottom: 10),
        padding:
            const EdgeInsets.only(top: 12, left: 18, right: 18, bottom: 12),
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
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    news.company,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54),
                  ),
                  if (isEditing)
                    GestureDetector(
                      onTap: () {
                        onSelected(!news.selected);
                      },
                      child: Icon(
                        news.selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: news.selected
                            ? const Color(0xFF4D71F6)
                            : Colors.grey,
                      ),
                    )
                  else
                    Text(
                      news.categoryId ?? ' ',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0038FF)),
                    ),
                ],
              ),
              // const SizedBox(height: 8),
              Text(
                news.title,
                style: const TextStyle(fontSize: 20, color: Colors.black),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              Text(
                news.content,
                style: const TextStyle(
                    fontSize: 12, color: Colors.grey, height: 1.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
