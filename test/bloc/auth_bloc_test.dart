import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/auth_state.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/model/auth_response.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepositry extends Mock implements AuthRepository {}

class MockSecureStorage extends Mock implements SecureStorage {}

void main() {
  late MockAuthRepositry mockAuthRepository;
  late MockSecureStorage mockSecureStorage;
  setUp(() {
    mockAuthRepository = MockAuthRepositry();
    mockSecureStorage = MockSecureStorage();
  });

  blocTest<AuthBloc, AuthState>(
    "emits loading then authenticated when access token exists",
    build: () {
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => 'fake_access_token');

      return AuthBloc(
        repository: mockAuthRepository,
        secureStorage: mockSecureStorage,
      );
    },
    act: (bloc) {
      bloc.add(AuthCheckRequested());
    },

    expect: () => [
      isA<AuthState>().having(
        (state) => state.status,
        "status",
        AuthStatus.loading,
      ),
      isA<AuthState>().having(
        (state) => state.status,
        "status",
        AuthStatus.authenticated,
      ),
    ],
    verify: (_) {
      verify(() => mockSecureStorage.getAccessToken()).called(1);
    },
  );
  blocTest(
    "emits laoding the unauthenticated when access tiken does not exists",
    build: () {
      when(
        () => mockSecureStorage.getAccessToken(),
      ).thenAnswer((_) async => null);

      return AuthBloc(
        repository: mockAuthRepository,
        secureStorage: mockSecureStorage,
      );
    },
    act: (bloc) {
      bloc.add(AuthCheckRequested());
    },
    expect: () => [
      isA<AuthState>().having(
        (state) => state.status,
        "Status",
        AuthStatus.loading,
      ),
      isA<AuthState>().having(
        (state) => state.status,
        "status",
        AuthStatus.unauthenticated,
      ),
    ],
    verify: (_) {
      verify(() => mockSecureStorage.getAccessToken()).called(1);
    },
  );
  blocTest<AuthBloc, AuthState>(
    'emits loading then authenticated and saves tokens when login succeeds',

    build: () {
      when(
        () => mockAuthRepository.login(
          email: 'namir@example.com',
          password: '123456',
        ),
      ).thenAnswer(
        (_) async => const AuthResponse(
          accessToken: 'fake_access_token',
          refreshToken: 'fake_refresh_token',
        ),
      );

      when(
        () => mockSecureStorage.saveAccessToken('fake_access_token'),
      ).thenAnswer((_) async {});

      when(
        () => mockSecureStorage.saveRefreshToken('fake_refresh_token'),
      ).thenAnswer((_) async {});

      return AuthBloc(
        repository: mockAuthRepository,
        secureStorage: mockSecureStorage,
      );
    },

    act: (bloc) {
      bloc.add(
        AuthLoginRequested(email: 'namir@example.com', password: '123456'),
      );
    },

    expect: () => [
      isA<AuthState>().having(
        (state) => state.status,
        'status',
        AuthStatus.loading,
      ),

      isA<AuthState>().having(
        (state) => state.status,
        'status',
        AuthStatus.authenticated,
      ),
    ],

    verify: (_) {
      verify(
        () => mockAuthRepository.login(
          email: 'namir@example.com',
          password: '123456',
        ),
      ).called(1);

      verify(
        () => mockSecureStorage.saveAccessToken('fake_access_token'),
      ).called(1);

      verify(
        () => mockSecureStorage.saveRefreshToken('fake_refresh_token'),
      ).called(1);
    },
  );
  blocTest<AuthBloc, AuthState>(
    'emits loading then failure when login fails',

    build: () {
      when(
        () => mockAuthRepository.login(
          email: 'namir@example.com',
          password: 'wrong',
        ),
      ).thenThrow(Exception('Invalid credentials'));

      return AuthBloc(
        repository: mockAuthRepository,
        secureStorage: mockSecureStorage,
      );
    },

    act: (bloc) {
      bloc.add(
        AuthLoginRequested(email: 'namir@example.com', password: 'wrong'),
      );
    },

    expect: () => [
      isA<AuthState>().having(
        (state) => state.status,
        'status',
        AuthStatus.loading,
      ),

      isA<AuthState>()
          .having((state) => state.status, 'status', AuthStatus.failure)
          .having(
            (state) => state.errorMessage,
            'errorMessage',
            'Exception: Invalid credentials',
          ),
    ],

    verify: (_) {
      verify(
        () => mockAuthRepository.login(
          email: 'namir@example.com',
          password: 'wrong',
        ),
      ).called(1);

      verifyNever(() => mockSecureStorage.saveAccessToken(any()));

      verifyNever(() => mockSecureStorage.saveRefreshToken(any()));
    },
  );
  blocTest<AuthBloc, AuthState>(
    'clears tokens and emits unauthenticated when logout is requested',

    build: () {
      when(() => mockSecureStorage.clearTokens()).thenAnswer((_) async {});

      return AuthBloc(
        repository: mockAuthRepository,
        secureStorage: mockSecureStorage,
      );
    },

    act: (bloc) {
      bloc.add(AuthLogoutRequested());
    },

    expect: () => [
      isA<AuthState>().having(
        (state) => state.status,
        'status',
        AuthStatus.unauthenticated,
      ),
    ],

    verify: (_) {
      verify(() => mockSecureStorage.clearTokens()).called(1);
    },
  );
}
