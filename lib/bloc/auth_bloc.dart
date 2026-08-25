import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basic_widget/data/shared_prefs.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPrefs sharedPrefs;
  final AuthRepository repository;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.sharedPrefs,
    required this.repository,
    required this.secureStorage,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await sharedPrefs.getLoggedIn();

    if (isLoggedIn == true) {
      emit(state.copyWith(status: AuthStatus.authenticated));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
      final authResponse = await repository.login(
        email: event.email,
        password: event.password,
      );
      final token = await secureStorage.getAccessToken();
      print('TOKEN: $token');
      await secureStorage.saveAccessToken(authResponse.accessToken);
      await secureStorage.saveRefreshToken(authResponse.refreshToken);
      final refreshToken = await secureStorage.getRefreshToken();

      print('REFRESH: $refreshToken');
      await sharedPrefs.saveLoggedIn(true);
      emit(
        state.copyWith(status: AuthStatus.authenticated, errorMessage: null),
      );
    } catch (err) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: err.toString(),
        ),
      );
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await sharedPrefs.saveLoggedIn(false);

    emit(state.copyWith(status: AuthStatus.unauthenticated));
  }
}
