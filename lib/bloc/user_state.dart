import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/model/user.dart';
import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final Status status;
  final List<User> users;
  final String? errorMessage;
  

  const UserState({
    this.status = Status.initial,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    Status? status,
    List<User>? users,
    String? errorMessage,
    bool clearError = false,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, users, errorMessage];
}
