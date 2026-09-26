import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/model/user.dart';
import 'package:equatable/equatable.dart';

class UserDetailState extends Equatable {
  final Status status;
  final User? user;
  final String? errorMessage;

  const UserDetailState({
    this.status = Status.initial,
    this.user,
    this.errorMessage,
  });

  UserDetailState copyWith({
    Status? status,
    User? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserDetailState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    errorMessage,
  ];
}