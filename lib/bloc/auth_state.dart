import 'package:equatable/equatable.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final bool clearError;

  const AuthState(
      {this.status = AuthStatus.initial,
      this.errorMessage,
      this.clearError = false});

  AuthState copyWith(
      {AuthStatus? status, String? errorMessage, bool? clearError}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage:
          (clearError ?? false) ? null : errorMessage ?? this.errorMessage,
      clearError: clearError ?? false,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, clearError];
}
