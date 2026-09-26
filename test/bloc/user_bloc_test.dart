import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_detail_bloc.dart';
import 'package:basic_widget/bloc/user_detail_event.dart';
import 'package:basic_widget/bloc/user_detail_state.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
  });

  blocTest<UserDetailBloc, UserDetailState>(
    'emits loading then success when user detail loads successfully',
    build: () {
      when(
        () => mockUserRepository.getUserById(5),
      ).thenAnswer(
        (_) async => const User(
          id: 5,
          name: 'Namir',
          email: 'namir@example.com',
        ),
      );

      return UserDetailBloc(mockUserRepository);
    },
    act: (bloc) {
      bloc.add(UserDetailRequested(5));
    },
    expect: () => [
      isA<UserDetailState>().having(
        (state) => state.status,
        'status',
        Status.loading,
      ),
      isA<UserDetailState>()
          .having(
            (state) => state.status,
            'status',
            Status.success,
          )
          .having(
            (state) => state.user?.id,
            'user.id',
            5,
          ),
    ],
    verify: (_) {
      verify(
        () => mockUserRepository.getUserById(5),
      ).called(1);
    },
  );

  blocTest<UserDetailBloc, UserDetailState>(
    'emits loading then failure when user detail loading fails',
    build: () {
      when(
        () => mockUserRepository.getUserById(5),
      ).thenThrow(
        Exception('Network error'),
      );

      return UserDetailBloc(mockUserRepository);
    },
    act: (bloc) {
      bloc.add(UserDetailRequested(5));
    },
    expect: () => [
      isA<UserDetailState>().having(
        (state) => state.status,
        'status',
        Status.loading,
      ),
      isA<UserDetailState>()
          .having(
            (state) => state.status,
            'status',
            Status.failure,
          )
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'Exception: Network error',
          ),
    ],
  );
}