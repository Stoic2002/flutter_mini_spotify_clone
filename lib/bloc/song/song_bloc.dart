import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_spotify_clone/models/song.dart';
import 'package:flutter_spotify_clone/repositories/song_repository.dart';
import 'package:flutter_spotify_clone/services/audio_handler.dart';

part 'song_event.dart';
part 'song_state.dart';

class SongBloc extends Bloc<SongEvent, SongState> {
  final SongRepository repository;
  AudioPlayerHandler audioHandler = AudioPlayerHandler();

  SongBloc(this.repository) : super(SongInitial()) {
    on<FetchSongs>(_onFetchSongs);
    on<SearchSongs>(_onSearchSongs);
  }

  Future<void> _onFetchSongs(FetchSongs event, Emitter<SongState> emit) async {
    emit(SongLoading());
    try {
      final songs = await repository.fetchSongs();
      emit(SongLoaded(songs));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }

  Future<void> _onSearchSongs(
      SearchSongs event, Emitter<SongState> emit) async {
    emit(SongLoading());
    try {
      final songs = await repository.searchSongs(event.query);
      emit(SongLoaded(songs));
    } catch (e) {
      emit(SongError(e.toString()));
    }
  }
}
