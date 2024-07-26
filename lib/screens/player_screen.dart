import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import '../models/song.dart';

class PlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AudioPlayerBloc, AudioPlayerState>(
      listener: (context, state) {
        if (state is AudioPlayerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AudioPlayerLoading) {
          return Scaffold(
            appBar: AppBar(title: Text('Now Playing')),
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
          Song currentSong;
          Duration position;
          Duration duration;

          if (state is AudioPlayerPlaying) {
            currentSong = state.song;
            position = state.position;
            duration = state.duration;
          } else {
            currentSong = (state as AudioPlayerPaused).song;
            position = state.position;
            duration = state.duration;
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Now Playing'),
              leading: IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(currentSong.albumArt, height: 300, width: 300),
                  SizedBox(height: 20),
                  Text(currentSong.title,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(currentSong.artist, style: TextStyle(fontSize: 18)),
                  SizedBox(height: 20),
                  Slider(
                    value: position.inSeconds.toDouble(),
                    max: duration.inSeconds.toDouble(),
                    onChanged: (value) {
                      context
                          .read<AudioPlayerBloc>()
                          .add(SeekTo(Duration(seconds: value.toInt())));
                    },
                  ),
                  Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous,
                          size: 35,
                        ),
                        onPressed: () {
                          context.read<AudioPlayerBloc>().add(SkipToPrevious());
                        },
                      ),
                      IconButton(
                        icon: Icon(
                            state is AudioPlayerPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 35),
                        onPressed: () {
                          if (state is AudioPlayerPlaying) {
                            context.read<AudioPlayerBloc>().add(PauseSong());
                          } else {
                            context.read<AudioPlayerBloc>().add(ResumeSong());
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.stop,
                          size: 35,
                        ),
                        onPressed: () {
                          context.read<AudioPlayerBloc>().add(StopSong());
                          // Navigator.pushReplacement(
                          //     context,
                          //     MaterialPageRoute(
                          //         builder: (context) => HomeScreen()));
                          Navigator.pop(context);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.skip_next,
                          size: 35,
                        ),
                        onPressed: () {
                          context.read<AudioPlayerBloc>().add(SkipToNext());
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(title: Text('Now Playing')),
          body: Center(child: Text('No song playing')),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
