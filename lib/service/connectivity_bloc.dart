import 'dart:async';

import 'package:basic_widget/service/connectivity_event.dart';
import 'package:basic_widget/service/connectivity_service.dart';
import 'package:basic_widget/service/connectivity_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ConnectivityBloc extends Bloc<ConnectivityEvent, ConnectivityState> {
  final ConnectivityService connectivityService;

  StreamSubscription<bool>? _connectivitySubscription;

  ConnectivityBloc({required this.connectivityService})
    : super(const ConnectivityState()) {
    on<ConnectivityStarted>((event, emit) async {
      final isConnected = await connectivityService.hasNetworkConnection();

      add(ConnectivityChanged(isConnected));

      _connectivitySubscription = connectivityService.onConnectivityChanged
          .listen((isConnected) {
            add(ConnectivityChanged(isConnected));
          });
    });
    on<ConnectivityChanged>((event, emit) {
      emit(
        state.copyWith(
          status: event.isConnected
              ? ConnectivityStatus.connectd
              : ConnectivityStatus.disconnected,
        ),
      );
    });
  }

  @override
  Future<void> close() async {
    await _connectivitySubscription?.cancel();
    return super.close();
  }
}
