import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;

  const AuthState({
    this.status = AuthStatus.initial,
  });

  AuthState copyWith({
    AuthStatus? status,
  }) {
    return AuthState(
      status: status ?? this.status,
    );
  }

  @override
  List<Object> get props => [status];
}