import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/connectivity/connectivity_bloc.dart';
import '../bloc/song/song_bloc.dart';

class ConnectivityListener extends StatefulWidget {
  final Widget child;

  const ConnectivityListener({super.key, required this.child});

  @override
  _ConnectivityListenerState createState() => _ConnectivityListenerState();
}

class _ConnectivityListenerState extends State<ConnectivityListener> {
  SnackBar? _offlineSnackBar;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityBloc, ConnectivityState>(
      listener: (context, state) {
        if (state is ConnectivityChanged) {
          if (!state.isConnected) {
            _showOfflineSnackBar(context);
          } else {
            _hideOfflineSnackBar(context);
            _showOnlineSnackBar(context);
            context.read<SongBloc>().add(FetchSongs());
          }
        }
      },
      child: widget.child,
    );
  }

  void _showOfflineSnackBar(BuildContext context) {
    _offlineSnackBar = const SnackBar(
      content: Text('You are offline. Please check your internet connection.'),
      backgroundColor: Colors.red,
      duration: Duration(days: 365), // Essentially indefinite
    );

    ScaffoldMessenger.of(context).showSnackBar(_offlineSnackBar!);
  }

  void _hideOfflineSnackBar(BuildContext context) {
    if (_offlineSnackBar != null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _offlineSnackBar = null;
    }
  }

  void _showOnlineSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Back online'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
