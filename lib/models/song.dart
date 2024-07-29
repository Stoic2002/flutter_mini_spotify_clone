import 'package:audio_service/audio_service.dart';

class Song {
  final String title;
  final String artist;
  final String albumArt;
  final String audioUrl;

  Song({
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'],
      artist: json['artist'],
      albumArt: json['album_art'],
      audioUrl: json['audio_url'],
    );
  }

  MediaItem toMediaItem() => MediaItem(
        id: audioUrl,
        artUri: Uri.parse(albumArt),
        artist: artist,
        title: title,
      );
}
