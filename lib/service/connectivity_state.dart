import 'package:basic_widget/bloc/status.dart';
import 'package:flutter/cupertino.dart';

enum ConnectivityStatus { initial, connectd, disconnected }

class ConnectivityState {
  final ConnectivityStatus status;

  const ConnectivityState({this.status = ConnectivityStatus.initial});

  ConnectivityState copyWith({ConnectivityStatus? status}) {
    return ConnectivityState(status: status ?? this.status);
  }
}
