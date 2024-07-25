part of 'audio_player_bloc.dart';

sealed class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object> get props => [];
}

class PlaySong extends AudioPlayerEvent {
  final Song song;
  final List<Song> playlist;

  const PlaySong(this.song, this.playlist);

  @override
  List<Object> get props => [song, playlist];
}

class PauseSong extends AudioPlayerEvent {}

class ResumeSong extends AudioPlayerEvent {}

class StopSong extends AudioPlayerEvent {}

class UpdateProgress extends AudioPlayerEvent {
  final Duration position;
  final Duration duration;

  const UpdateProgress(this.position, this.duration);

  @override
  List<Object> get props => [position, duration];
}

class SeekTo extends AudioPlayerEvent {
  final Duration position;

  const SeekTo(this.position);

  @override
  List<Object> get props => [position];
}

class SkipToPrevious extends AudioPlayerEvent {}

class SkipToNext extends AudioPlayerEvent {}
