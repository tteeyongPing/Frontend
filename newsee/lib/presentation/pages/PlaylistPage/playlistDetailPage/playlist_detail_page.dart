import 'package:flutter/material.dart';
import 'package:newsee/models/Playlist.dart';

class PlaylistDetailPage extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.playlistName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              playlist.playlistName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              playlist.description,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text(
              '뉴스 목록 (${playlist.news.length}개)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: playlist.news.length,
                itemBuilder: (context, index) {
                  final news = playlist.news[index];
                  return ListTile(
                    title: Text(news.title),
                    subtitle: Text(news.content),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
