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
        height: 140,
        margin: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
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
                      color:
                          news.selected ? const Color(0xFF4D71F6) : Colors.grey,
                    ),
                  )
                else
                  Text(
                    news.categoryId,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0038FF)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              news.title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.5),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              news.content,
              style: const TextStyle(
                  fontSize: 16, color: Colors.grey, height: 1.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
