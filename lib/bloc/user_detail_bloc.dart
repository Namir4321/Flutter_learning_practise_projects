import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_detail_event.dart';
import 'package:basic_widget/bloc/user_detail_state.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailBloc
    extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository repository;

  UserDetailBloc(this.repository)
      : super(const UserDetailState()) {
    on<UserDetailRequested>(_onUserDetailRequested);
  }

  Future<void> _onUserDetailRequested(
    UserDetailRequested event,
    Emitter<UserDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: Status.loading,
        clearError: true,
      ),
    );

    try {
      final user = await repository.getUserById(event.id);

      emit(
        state.copyWith(
          status: Status.success,
          user: user,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: Status.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}