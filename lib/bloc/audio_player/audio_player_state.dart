part of 'audio_player_bloc.dart';

sealed class AudioPlayerState extends Equatable {
  const AudioPlayerState();

  @override
  List<Object> get props => [];
}

final class AudioPlayerInitial extends AudioPlayerState {}

class AudioPlayerLoading extends AudioPlayerState {}

class AudioPlayerPlaying extends AudioPlayerState {
  final Song song;
  final Duration position;
  final Duration duration;

  const AudioPlayerPlaying(this.song, this.position, this.duration);

  @override
  List<Object> get props => [song, position, duration];
}

class AudioPlayerPaused extends AudioPlayerState {
  final Song song;
  final Duration position;
  final Duration duration;

  const AudioPlayerPaused(this.song, this.position, this.duration);

  @override
  List<Object> get props => [song, position, duration];
}

class AudioPlayerStopped extends AudioPlayerState {}

class AudioPlayerError extends AudioPlayerState {
  final String message;

  const AudioPlayerError(this.message);

  @override
  List<Object> get props => [message];
}
