import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spotify_clone/bloc/song/song_bloc.dart';
import 'package:flutter_spotify_clone/repositories/song_repository.dart';
import 'package:flutter_spotify_clone/widgets/connectivity_listener.dart';
import 'package:flutter_spotify_clone/widgets/mini_player.dart';
import 'package:flutter_spotify_clone/widgets/search_delegate.dart';
import 'package:flutter_spotify_clone/widgets/song_list.dart';
import 'song_player_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongRepository songRepo = SongRepository();

  @override
  void initState() {
    super.initState();
    context.read<SongBloc>().add(FetchSongs());
  }

  @override
  Widget build(BuildContext context) {
    return ConnectivityListener(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mini Spotify'),
          actions: [
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: SongSearchDelegate(),
                );
              },
            ),
          ],
        ),
        body: Container(
          child: BlocBuilder<SongBloc, SongState>(
            builder: (context, state) {
              if (state is SongLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is SongLoaded) {
                return SongList(
                  songs: state.songs,
                  onTap: (song) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerPage(),
                      ),
                    );
                  },
                );
              } else if (state is SongError) {
                return Center(child: Text(state.message));
              }
              return Container();
            },
          ),
        ),
        bottomNavigationBar: MiniPlayer(),
      ),
    );
  }
}
