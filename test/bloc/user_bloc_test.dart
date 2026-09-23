import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  blocTest<UserBloc, UserState>(
    "emits loading then success when user details loads successfully",
    build: () {
      when(() => mockUserRepository.getUserById(5)).thenAnswer(
        (_) async =>
            const User(id: 5, email: "namir@example.com", name: "Namir"),
      );
      return UserBloc(mockUserRepository);
    },
    act: (bloc) {
      bloc.add(UserDetailRequested(5));
    },
    expect: () => [
      isA<UserState>().having(
        (state) => state.status,
        'status',
        Status.loading,
      ),
      isA<UserState>()
          .having((state) => state.status, "status", Status.success)
          .having((state) => state.selectedUser?.id, "selectedUser.id", 5),
    ],
  );
  blocTest(
    "emits loading then failure when user detail loading fails",
    build: () {
      when(
        () => mockUserRepository.getUserById(5),
      ).thenThrow(Exception("Network error"));
      return UserBloc(mockUserRepository);
    },
    act: (bloc) {
      bloc.add(UserDetailRequested(5));
    },
    expect: () => [
      isA<UserState>().having(
        (state) => state.status,
        'status',
        Status.loading,
      ),
      isA<UserState>()
          .having((state) => state.status, "status", Status.failure)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'Exception: Network error',
          ),
    ],
    verify: (_) {
      verify(() => mockUserRepository.getUserById(5)).called(1);
    },
  );
  
}
