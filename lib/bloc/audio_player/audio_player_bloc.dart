import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_spotify_clone/models/song.dart';
import 'package:just_audio/just_audio.dart';

part 'audio_player_event.dart';
part 'audio_player_state.dart';

class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayer audioPlayer = AudioPlayer();
  List<Song> playlist = [];
  int currentIndex = 0;

  AudioPlayerBloc() : super(AudioPlayerInitial()) {
    on<PlaySong>(_onPlaySong);
    on<PauseSong>(_onPauseSong);
    on<ResumeSong>(_onResumeSong);
    on<StopSong>(_onStopSong);
    on<UpdateProgress>(_onUpdateProgress);
    on<SeekTo>(_onSeekTo);
    on<SkipToPrevious>(_onSkipToPrevious);
    on<SkipToNext>(_onSkipToNext);

    audioPlayer.playerStateStream.listen((playerState) {
      if (playerState.playing) {
        add(UpdateProgress(
            audioPlayer.position, audioPlayer.duration ?? Duration.zero));
      }
    });
  }

  void _onPlaySong(PlaySong event, Emitter<AudioPlayerState> emit) async {
    emit(AudioPlayerLoading());
    try {
      playlist = event.playlist ?? [event.song];
      currentIndex = event.playlist?.indexOf(event.song) ?? 0;
      await audioPlayer.setUrl(event.song.audioUrl);
      await audioPlayer.play();

      await audioPlayer.playingStream.firstWhere((playing) => playing == true);

      emit(AudioPlayerPlaying(
          event.song, Duration.zero, audioPlayer.duration ?? Duration.zero));

      audioPlayer.positionStream.listen((position) {
        add(UpdateProgress(position, audioPlayer.duration ?? Duration.zero));
      });
    } catch (e) {
      emit(AudioPlayerError('Failed to play song: ${e.toString()}'));
    }
  }

  void _onPauseSong(PauseSong event, Emitter<AudioPlayerState> emit) async {
    if (audioPlayer.playing && state is AudioPlayerPlaying) {
      final currentState = state as AudioPlayerPlaying;
      await audioPlayer.pause();
      emit(AudioPlayerPaused(
          currentState.song, currentState.position, currentState.duration));
    }
  }

  void _onResumeSong(ResumeSong event, Emitter<AudioPlayerState> emit) async {
    if (state is AudioPlayerPaused) {
      final currentState = state as AudioPlayerPaused;
      await audioPlayer.play();
      emit(AudioPlayerPlaying(
          currentState.song, currentState.position, currentState.duration));
    }
  }

  void _onStopSong(StopSong event, Emitter<AudioPlayerState> emit) async {
    await audioPlayer.stop();
    emit(AudioPlayerStopped());
  }

  void _onUpdateProgress(UpdateProgress event, Emitter<AudioPlayerState> emit) {
    if (state is AudioPlayerPlaying) {
      final currentState = state as AudioPlayerPlaying;
      emit(AudioPlayerPlaying(
          currentState.song, event.position, event.duration));
    }
  }

  void _onSeekTo(SeekTo event, Emitter<AudioPlayerState> emit) async {
    await audioPlayer.seek(event.position);
    if (state is AudioPlayerPlaying) {
      final currentState = state as AudioPlayerPlaying;
      emit(AudioPlayerPlaying(
          currentState.song, event.position, currentState.duration));
    } else if (state is AudioPlayerPaused) {
      final currentState = state as AudioPlayerPaused;
      emit(AudioPlayerPaused(
          currentState.song, event.position, currentState.duration));
    }
  }

  void _onSkipToPrevious(
      SkipToPrevious event, Emitter<AudioPlayerState> emit) async {
    if (currentIndex > 0) {
      currentIndex--;
      add(PlaySong(playlist[currentIndex], playlist));
    }
  }

  void _onSkipToNext(SkipToNext event, Emitter<AudioPlayerState> emit) async {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      add(PlaySong(playlist[currentIndex], playlist));
    }
  }

  @override
  Future<void> close() {
    audioPlayer.dispose();
    return super.close();
  }
}
