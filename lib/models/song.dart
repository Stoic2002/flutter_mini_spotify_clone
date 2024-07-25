class Song {
  final int id;
  final String title;
  final String artist;
  final String albumArt;
  final String audioUrl;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.albumArt,
    required this.audioUrl,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      albumArt: json['album_art'],
      audioUrl: json['audio_url'],
    );
  }
}
