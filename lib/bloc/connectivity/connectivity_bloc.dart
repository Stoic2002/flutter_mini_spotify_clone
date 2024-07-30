import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_spotify_clone/services/connectivity_service.dart';

part 'connectivity_event.dart';
part 'connectivity_state.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService _connectivityService;
  late StreamSubscription<bool> _connectivitySubscription;
  bool _lastConnectionStatus = true; // Asumsi awal terhubung

  ConnectivityBloc(this._connectivityService) : super(ConnectivityInitial()) {
    on<Changed>((event, emit) {
      if (event.isConnected != _lastConnectionStatus) {
        _lastConnectionStatus = event.isConnected;
        emit(ConnectivityChanged(event.isConnected));
      }
      if (event.isConnected) {
        emit(ConnectivityConnected());
      } else {
        emit(ConnectivityDisconnected());
      }
    });

    _connectivitySubscription =
        _connectivityService.connectivityStream.stream.listen(
      (isConnected) => add(Changed(isConnected)),
    );
  }

  @override
  Future<void> close() {
    _connectivitySubscription.cancel();
    return super.close();
  }
}
