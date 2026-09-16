import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basic_widget/repository/user_repository.dart';

abstract class UserEvent {}

class UserLoadRequest extends UserEvent {}

class UserLoadMoreRequest extends UserEvent {}

class UserCreateRequest extends UserEvent {
  final String name;
  final String email;

  UserCreateRequest({required this.name, required this.email});
}

class UserDeleteRequest extends UserEvent {
  final int id;
  UserDeleteRequest({required this.id});
}

class UserSearchChanged extends UserEvent {
  final String query;
  UserSearchChanged({required this.query});
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
  CancelToken? _searchCancelToken;
  UserBloc(this.repository) : super(const UserState()) {
    on<UserLoadRequest>((event, emit) async {
      emit(state.copyWith(status: Status.loading, clearError: true));
      try {
        final users = await repository.getUsers(page: 1, limit: 5);

        emit(state.copyWith(status: Status.success, users: users));
      } catch (er) {
        emit(
          state.copyWith(
            status: Status.failure,
            errorMessage: er.toString(),
            isLoadingMore: false,
          ),
        );
      }
    });
    on<UserLoadMoreRequest>((event, emit) async {
      if (!state.hasMore || state.isLoadingMore) return;

      try {
        final nextPage = state.currentPage + 1;

        final newUsers = await repository.getUsers(
          page: nextPage,
          limit: 5,
          search: state.searchQuery,
        );

        emit(
          state.copyWith(
            users: [...state.users, ...newUsers],
            currentPage: nextPage,
            hasMore: newUsers.length == 5,
            isLoadingMore: false,
          ),
        );
      } catch (err) {
        emit(
          state.copyWith(
            status: Status.failure,
            errorMessage: err.toString(),
            isLoadingMore: false,
          ),
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

    on<UserSearchChanged>((event, emit) async {
      try {
        _searchCancelToken?.cancel("New search started");
        _searchCancelToken = CancelToken();
        emit(
          state.copyWith(
            status: Status.loading,
            searchQuery: event.query,
            clearError: true,
          ),
        );
        final users = await repository.getUsers(
          page: 1,
          limit: 5,
          search: event.query,
          cancelToken: _searchCancelToken,
        );
        emit(
          state.copyWith(
            status: Status.success,
            users: users,
            currentPage: 1,
            hasMore: users.length == 5,
            searchQuery: event.query,
          ),
        );
      } on DioException catch (err) {
        if (err.type == DioExceptionType.cancel) {
          debugPrint('OLD SEARCH CANCELLED: ${err.error}');

          return;
        }
        emit(
          state.copyWith(status: Status.failure, errorMessage: err.toString()),
        );
      } catch (err) {
        emit(
          state.copyWith(status: Status.failure, errorMessage: err.toString()),
        );
      }
    });
  }
}
