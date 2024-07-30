part of 'connectivity_bloc.dart';

sealed class ConnectivityEvent extends Equatable {
  const ConnectivityEvent();

  @override
  List<Object> get props => [];
}

class Changed extends ConnectivityEvent {
  final bool isConnected;

  const Changed(this.isConnected);

  @override
  List<Object> get props => [isConnected];
}
