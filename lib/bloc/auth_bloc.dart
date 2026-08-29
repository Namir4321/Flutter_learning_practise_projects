import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final SecureStorage secureStorage;

  AuthBloc({
    required this.repository,
    required this.secureStorage,
  }) : super(const AuthState(status: AuthStatus.initial)) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));
    final token = await secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      emit(
        state.copyWith(status: AuthStatus.authenticated, errorMessage: null),
      );
    } else {
      emit(
        state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null),
      );
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
      await secureStorage.saveAccessToken(authResponse.accessToken);
      await secureStorage.saveRefreshToken(authResponse.refreshToken);
   
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
    await secureStorage.clearTokens();

    emit(
      state.copyWith(status: AuthStatus.unauthenticated, errorMessage: null),
    );
  }
}
