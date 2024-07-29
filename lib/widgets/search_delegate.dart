import 'package:flutter/material.dart';
import 'package:flutter_spotify_clone/services/audio_handler.dart';
import '../models/song.dart';
import '../repositories/song_repository.dart';

class SongSearchDelegate extends SearchDelegate<Song?> {
  final SongRepository repository;
  AudioPlayerHandler audioHandler = AudioPlayerHandler();

  SongSearchDelegate(this.repository);

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
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Song>>(
      future: repository.searchSongs(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No songs found'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final song = snapshot.data![index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(song.albumArt),
                ),
                title: Text(song.title),
                subtitle: Text(song.artist),
                onTap: () {
                  // close(context, song);
                  // audioHandler.addQueueItems([song.toMediaItem()]);
                  // audioHandler.play();
                },
              );
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.length < 1) {
      return Center(child: Text('Type at least 1 characters to search'));
    }
    return buildResults(context);
  }
}
