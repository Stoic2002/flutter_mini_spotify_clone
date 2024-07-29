import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_spotify_clone/screens/song_player_page.dart';
import '../main.dart';
import 'player_controls.dart';

class MiniPlayer extends StatelessWidget {
  String _formatDuration(Duration? duration) {
    if (duration == null) return '--:--';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

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
          child: Container(
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
                        StreamBuilder<Duration>(
                          stream: AudioService.position,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            return Text(
                              '${_formatDuration(position)} / ${_formatDuration(mediaItem.duration)}',
                              style: TextStyle(fontSize: 12),
                            );
                          },
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
        );
      },
    );
  }
}
