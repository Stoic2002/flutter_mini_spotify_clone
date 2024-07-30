import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spotify_clone/bloc/song/song_bloc.dart';
import 'package:flutter_spotify_clone/main.dart';
import 'package:flutter_spotify_clone/screens/song_player_page.dart';
import '../models/song.dart';

class SongSearchDelegate extends SearchDelegate<Song?> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
        context.read<SongBloc>().add(FetchSongs());
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return BlocConsumer<SongBloc, SongState>(
      listener: (context, state) {
        // TODO: implement listener
      },
      builder: (context, state) {
        if (state is SongLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is SongLoaded) {
          return ListView.builder(
            itemCount: state.songs.length,
            itemBuilder: (context, index) {
              final song = state.songs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(song.albumArt),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () async {
                  close(context, song);
                  context.read<SongBloc>().add(FetchSongs());
                  audioHandler.stop();
                  // audioHandler.addQueueItems([song.toMediaItem()]);
                  // Jika playlist kosong, tambahkan semua lagu
                  if (audioHandler.queue.value.isEmpty) {
                    await audioHandler.addQueueItems(
                        state.songs.map((s) => s.toMediaItem()).toList());
                  }

                  // Cari indeks lagu yang diklik dalam antrian
                  final queueIndex = audioHandler.queue.value
                      .indexWhere((item) => item.id == song.audioUrl);

                  if (queueIndex != -1) {
                    // Jika lagu ditemukan dalam antrian, putar lagu tersebut
                    await audioHandler.skipToQueueItem(queueIndex);
                  } else {
                    // Jika lagu tidak ditemukan, tambahkan ke antrian dan putar
                    await audioHandler.addQueueItem(song.toMediaItem());
                    await audioHandler
                        .skipToQueueItem(audioHandler.queue.value.length - 1);
                  }
                  audioHandler.play();
                  // Navigator.of(context).push(MaterialPageRoute(builder: (context) => PlayerPage()));
                },
              );
            },
          );
        } else if (state is SongError) {
          return Center(child: Text(state.message));
        }
        return Container();
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 1) {
      return Center(child: Text('Type at least 1 characters to search'));
    }
    context.read<SongBloc>().add(SearchSongs(query));
    return buildResults(context);
  }
}
