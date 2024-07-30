import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spotify_clone/bloc/connectivity/connectivity_bloc.dart';

import 'package:flutter_spotify_clone/bloc/song/song_bloc.dart';
import 'package:flutter_spotify_clone/repositories/song_repository.dart';
import 'package:flutter_spotify_clone/services/audio_handler.dart';

import 'package:flutter_spotify_clone/screens/home_screen.dart';
import 'package:flutter_spotify_clone/services/connectivity_service.dart';

late AudioHandler audioHandler;
final SongRepository _songRepository = SongRepository();
final ConnectivityService connectivityService = ConnectivityService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mini.app',
        androidNotificationChannelName: 'mini player',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidShowNotificationBadge: true),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SongBloc(_songRepository)),
        BlocProvider(create: (context) => ConnectivityBloc(connectivityService))
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini Spotify Clone',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomeScreen(),
      ),
    );
  }
}
