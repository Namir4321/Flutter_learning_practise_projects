import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basic_widget/data/shared_prefs.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SharedPrefs sharedPrefs;

  AuthBloc(this.sharedPrefs) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequest>(_onAuthLoginRequested);
    on<AuthLogoutkRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final isLoggedIn = await sharedPrefs.getLoggedIn();

    if (isLoggedIn == true) {
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
        ),
      );
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequest event,
    Emitter<AuthState> emit,
  ) async {
    await sharedPrefs.saveLoggedIn(true);

    emit(
      state.copyWith(
        status: AuthStatus.authenticated,
      ),
    );
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutkRequested event,
    Emitter<AuthState> emit,
  ) async {
    await sharedPrefs.saveLoggedIn(false);

    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
      ),
    );
  }
}