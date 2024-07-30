import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_spotify_clone/screens/song_player_page.dart';
import '../main.dart';
import 'player_controls.dart';

class MiniPlayer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, snapshot) {
        final mediaItem = snapshot.data;
        if (mediaItem == null) return SizedBox.shrink();

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PlayerPage()),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Durasi line
              StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = mediaItem.duration ?? Duration.zero;
                  return LinearProgressIndicator(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    minHeight: 3, // Atur ketebalan garis sesuai kebutuhan
                  );
                },
              ),
              Container(
                height: 70,
                color: Colors.grey[200],
                child: Row(
                  children: [
                    Image.network(
                      mediaItem.artUri.toString(),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              mediaItem.title,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              mediaItem.artist ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_previous),
                      onPressed: audioHandler.skipToPrevious,
                    ),
                    PlayerControls(),
                    IconButton(
                      icon: Icon(Icons.skip_next),
                      onPressed: audioHandler.skipToNext,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
