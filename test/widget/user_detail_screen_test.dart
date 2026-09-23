import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/bloc/user_state.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserBloc extends MockBloc<UserEvent, UserState> implements UserBloc {}

void main() {
  late MockUserBloc mockUserBloc;

  setUp(() {
    mockUserBloc = MockUserBloc();
  });

  testWidgets('shows loading indicator when UserBloc is loading', (
    tester,
  ) async {
    when(
      () => mockUserBloc.state,
    ).thenReturn(const UserState(status: Status.loading));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserBloc>.value(
          value: mockUserBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
testWidgets(
  'shows user details when UserBloc state is success',
  (tester) async {
    // ARRANGE
    when(
      () => mockUserBloc.state,
    ).thenReturn(
      const UserState(
        status: Status.success,
        selectedUser: User(
          id: 5,
          name: 'Namir',
          email: 'namir@example.com',
        ),
      ),
    );

    // ACT
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserBloc>.value(
          value: mockUserBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );

    // ASSERT
    expect(
      find.text('Namir'),
      findsOneWidget,
    );

    expect(
      find.text('namir@example.com'),
      findsOneWidget,
    );

    expect(
      find.text('User ID: 5'),
      findsOneWidget,
    );
  },
);
testWidgets(
  'shows error message when UserBloc state is failure',
  (tester) async {
    // ARRANGE
    when(
      () => mockUserBloc.state,
    ).thenReturn(
      const UserState(
        status: Status.failure,
        errorMessage: 'Failed to load user',
      ),
    );

    // ACT
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserBloc>.value(
          value: mockUserBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );

    // ASSERT
    expect(
      find.text('Failed to load user'),
      findsOneWidget,
    );

    expect(
      find.byType(CircularProgressIndicator),
      findsNothing,
    );
  },
);
}
