import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spotify_clone/bloc/audio_player/audio_player_bloc.dart';
import 'package:flutter_spotify_clone/screens/player_screen.dart';
import '../repositories/song_repository.dart';
import '../models/song.dart';
import '../widgets/song_list_item.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SongRepository songRepository = SongRepository();
  List<Song> songs = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  void _loadSongs() async {
    try {
      final loadedSongs = await songRepository.fetchSongs();
      setState(() {
        songs = loadedSongs;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load songs: ${e.toString()}')),
      );
    }
  }

  void _searchSongs(String query) async {
    if (query.isEmpty) {
      _loadSongs(); // Load all songs if query is empty
      return;
    }

    setState(() {
      isLoading = true;
      searchQuery = query;
    });

    try {
      final searchResults = await songRepository.searchSongs(query);
      setState(() {
        songs = searchResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search songs: ${e.toString()}')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Spotify'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SongSearchDelegate(searchSongs: _searchSongs),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return SongListItem(
                  song: songs[index],
                  onTap: () {
                    context
                        .read<AudioPlayerBloc>()
                        .add(PlaySong(songs[index], songs));
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlayerScreen()),
                    );
                  },
                );
              },
            ),
      bottomNavigationBar: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          if (state is AudioPlayerPlaying || state is AudioPlayerPaused) {
            Song currentSong;
            Duration position;
            Duration duration;

            if (state is AudioPlayerPlaying) {
              currentSong = state.song;
              position = state.position;
              duration = state.duration;
            } else if (state is AudioPlayerPaused) {
              currentSong = state.song;
              position = state.position;
              duration = state.duration;
            } else {
              return SizedBox.shrink();
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlayerScreen()),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(
                    value: duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0,
                  ),
                  BottomAppBar(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${currentSong.title} - ${currentSong.artist}',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_previous),
                            onPressed: () {
                              context
                                  .read<AudioPlayerBloc>()
                                  .add(SkipToPrevious());
                            },
                          ),
                          IconButton(
                            icon: Icon(context
                                    .read<AudioPlayerBloc>()
                                    .audioPlayer
                                    .playing
                                ? Icons.pause
                                : Icons.play_arrow),
                            onPressed: () {
                              if (state is AudioPlayerPlaying) {
                                context
                                    .read<AudioPlayerBloc>()
                                    .add(PauseSong());
                              } else {
                                context
                                    .read<AudioPlayerBloc>()
                                    .add(ResumeSong());
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.stop),
                            onPressed: () {
                              context.read<AudioPlayerBloc>().add(StopSong());
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.skip_next),
                            onPressed: () {
                              context.read<AudioPlayerBloc>().add(SkipToNext());
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}

class SongSearchDelegate extends SearchDelegate {
  final Function(String) searchSongs;

  SongSearchDelegate({required this.searchSongs});

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
      future: SongRepository().searchSongs(query),
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
              return SongListItem(
                song: snapshot.data![index],
                onTap: () {
                  context
                      .read<AudioPlayerBloc>()
                      .add(PlaySong(snapshot.data![index], snapshot.data!));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlayerScreen()),
                  );
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
    if (query.length < 2) {
      return Center(child: Text('Type at least 2 characters to search'));
    }
    return buildResults(context);
  }
}
