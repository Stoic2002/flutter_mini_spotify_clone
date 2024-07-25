import 'package:flutter/material.dart';
import '../models/song.dart';

class SongListItem extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;

  const SongListItem({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(song.albumArt),
      title: Text(song.title),
      subtitle: Text(song.artist),
      onTap: onTap,
    );
  }
}
