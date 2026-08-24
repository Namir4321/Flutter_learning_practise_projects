import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basic_widget/repository/user_repository.dart';

abstract class UserEvent {}

class UserLoadRequest extends UserEvent {}

class UserCreateRequest extends UserEvent {
  final String name;
  final String email;

  UserCreateRequest({required this.name, required this.email});
}

class UserDeleteRequest extends UserEvent {
  final int id;
  UserDeleteRequest({required this.id});
}

class UserUpdateRequest extends UserEvent {
  final int id;
  final String name;
  final String email;

  UserUpdateRequest({
    required this.id,
    required this.name,
    required this.email,
  });
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  UserBloc(this.repository) : super(const UserState()) {
    on<UserLoadRequest>((event, emit) async {
      emit(state.copyWith(status: Status.loading, clearError: true));
      try {
        final users = await repository.getUsers();

        emit(state.copyWith(status: Status.success, users: users));
      } catch (er) {
        emit(
          state.copyWith(status: Status.failure, errorMessage: er.toString()),
        );
      }
    });

    on<UserCreateRequest>((event, emit) async {
      emit(state.copyWith(status: Status.creating, clearError: true));

      try {
        final user = await repository.createUser(
          name: event.name,
          email: event.email,
        );
        emit(
          state.copyWith(status: Status.success, users: [...state.users, user]),
        );
      } catch (err) {
        emit(
          state.copyWith(
            status: Status.createFailure,
            errorMessage: err.toString(),
          ),
        );
      }
    });
    on<UserDeleteRequest>((event, emit) async {
      try {
        await repository.deleteUser(event.id);
        final updatedUser = state.users
            .where((user) => user.id != event.id)
            .toList();
        emit(state.copyWith(status: Status.success, users: updatedUser));
      } catch (err) {
        emit(
          state.copyWith(
            status: Status.createFailure,
            errorMessage: err.toString(),
          ),
        );
      }
    });

    on<UserUpdateRequest>((event, emit) async {
      try {
        final updatedUser = await repository.updateUser(
          id: event.id,
          name: event.name,
          email: event.email,
        );
        final updatedUsers = state.users.map((user) {
          if (user.id == event.id) {
            return updatedUser;
          }
          return user;
        }).toList();
        emit(state.copyWith(status: Status.success, users: updatedUsers));
      } catch (err) {
        emit(
          state.copyWith(status: Status.failure, errorMessage: err.toString()),
        );
      }
    });
  }
}
