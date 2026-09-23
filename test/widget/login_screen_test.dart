import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/auth_state.dart';
import 'package:basic_widget/screen/login_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();

    when(
      () => mockAuthBloc.state,
    ).thenReturn(const AuthState(status: AuthStatus.unauthenticated));
  });
  testWidgets('allows user to enter email and password', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    expect(textFields, findsNWidgets(2));

    await tester.enterText(textFields.at(0), 'namir@example.com');

    await tester.enterText(textFields.at(1), '123456');

    expect(find.text('namir@example.com'), findsOneWidget);

    expect(find.text('123456'), findsOneWidget);
  });
  testWidgets('sends AuthLoginRequested when login button is tapped', (
    tester,
  ) async {
    // ARRANGE
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    final textFields = find.byType(TextField);

    await tester.enterText(textFields.at(0), 'namir@example.com');

    await tester.enterText(textFields.at(1), '123456');

    // ACT
    await tester.tap(find.text('Login'));

    await tester.pump();

    // ASSERT
    verify(
      () => mockAuthBloc.add(
        any(
          that: isA<AuthLoginRequested>()
              .having((event) => event.email, 'email', 'namir@example.com')
              .having((event) => event.password, 'password', '123456'),
        ),
      ),
    ).called(1);
  });
  testWidgets(
  'shows loading indicator when AuthBloc is loading',
  (tester) async {
    // ARRANGE
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([
        const AuthState(
          status: AuthStatus.loading,
        ),
      ]),
      initialState: const AuthState(
        status: AuthStatus.unauthenticated,
      ),
    );

    // ACT
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    await tester.pump();

    // ASSERT
    expect(
      find.byType(CircularProgressIndicator),
      findsOneWidget,
    );

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );

    expect(button.onPressed, isNull);
  },
);
testWidgets(
  'shows error SnackBar when login fails',
  (tester) async {
    // ARRANGE
    whenListen(
      mockAuthBloc,
      Stream.fromIterable([
        const AuthState(
          status: AuthStatus.failure,
          errorMessage: 'Invalid credentials',
        ),
      ]),
      initialState: const AuthState(
        status: AuthStatus.unauthenticated,
      ),
    );

    // ACT
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Allow the failure state to be emitted
    await tester.pump();

    // ASSERT
    expect(
      find.byType(SnackBar),
      findsOneWidget,
    );

    expect(
      find.text('Invalid credentials'),
      findsOneWidget,
    );
  },
);
}
