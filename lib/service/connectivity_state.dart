enum ConnectivityStatus { initial, connectd, disconnected }

class ConnectivityState {
  final ConnectivityStatus status;

  const ConnectivityState({this.status = ConnectivityStatus.initial});

  ConnectivityState copyWith({ConnectivityStatus? status}) {
    return ConnectivityState(status: status ?? this.status);
  }
}
