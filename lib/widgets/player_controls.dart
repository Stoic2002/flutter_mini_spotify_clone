import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import '../main.dart';

class PlayerControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackState>(
      stream: audioHandler.playbackState,
      builder: (context, snapshot) {
        final playbackState = snapshot.data;
        final processingState = playbackState?.processingState;
        final playing = playbackState?.playing;
        if (processingState == AudioProcessingState.loading ||
            processingState == AudioProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 32.0,
            height: 32.0,
            child: CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return IconButton(
            icon: Icon(Icons.play_arrow),
            iconSize: 40,
            onPressed: audioHandler.play,
          );
        } else {
          return IconButton(
            icon: Icon(Icons.pause),
            iconSize: 40,
            onPressed: audioHandler.pause,
          );
        }
      },
    );
  }
}
