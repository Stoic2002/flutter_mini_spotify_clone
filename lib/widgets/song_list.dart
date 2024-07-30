import 'package:flutter/material.dart';
import '../models/song.dart';
import '../main.dart';

class SongList extends StatelessWidget {
  final List<Song> songs;
  final Function(Song) onTap;

  SongList({required this.songs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return ListTile(
          leading: Image.network(song.albumArt),
          title: Text(song.title),
          subtitle: Text(song.artist),
          onTap: () async {
            // Jika playlist kosong, tambahkan semua lagu
            if (audioHandler.queue.value.isEmpty) {
              await audioHandler
                  .addQueueItems(songs.map((s) => s.toMediaItem()).toList());
            }

            // Cari indeks lagu yang diklik dalam antrian
            final queueIndex = audioHandler.queue.value
                .indexWhere((item) => item.id == song.audioUrl);
            onTap(song);

            if (queueIndex != -1) {
              // Jika lagu ditemukan dalam antrian, putar lagu tersebut
              await audioHandler.skipToQueueItem(queueIndex);
            } else {
              // Jika lagu tidak ditemukan, tambahkan ke antrian dan putar
              await audioHandler.addQueueItem(song.toMediaItem());
              await audioHandler
                  .skipToQueueItem(audioHandler.queue.value.length - 1);
            }

            audioHandler.play();
          },
        );
      },
    );
  }
}
