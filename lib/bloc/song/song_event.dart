part of 'song_bloc.dart';

sealed class SongEvent extends Equatable {
  const SongEvent();

  @override
  List<Object> get props => [];
}

class FetchSongs extends SongEvent {}

class SearchSongs extends SongEvent {
  final String query;
  SearchSongs(this.query);
}
