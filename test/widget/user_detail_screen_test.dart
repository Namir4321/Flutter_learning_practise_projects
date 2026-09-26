import 'package:basic_widget/bloc/status.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/bloc/user_detail_bloc.dart';
import 'package:basic_widget/bloc/user_detail_event.dart';
import 'package:basic_widget/bloc/user_detail_state.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserDetailBloc extends MockBloc<UserDetailEvent, UserDetailState>
    implements UserDetailBloc {}

void main() {
  late MockUserDetailBloc mockUserDetailBloc;

  setUp(() {
    mockUserDetailBloc = MockUserDetailBloc();
  });

  testWidgets('shows loading indicator when UserDetailBloc is loading', (
    tester,
  ) async {
    when(
      () => mockUserDetailBloc.state,
    ).thenReturn(const UserDetailState(status: Status.loading));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserDetailBloc>.value(
          value: mockUserDetailBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
 testWidgets(
  'shows user details when UserDetailBloc state is success',
  (tester) async {
    when(
      () => mockUserDetailBloc.state,
    ).thenReturn(
      const UserDetailState(
        status: Status.success,
        user: User(
          id: 5,
          name: 'Namir',
          email: 'namir@example.com',
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserDetailBloc>.value(
          value: mockUserDetailBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );

    expect(find.text('Namir'), findsOneWidget);
    expect(find.text('namir@example.com'), findsOneWidget);
    expect(find.text('User ID: 5'), findsOneWidget);
  },
);
  testWidgets(
  'shows error message when UserDetailBloc state is failure',
  (tester) async {
    when(
      () => mockUserDetailBloc.state,
    ).thenReturn(
      const UserDetailState(
        status: Status.failure,
        errorMessage: 'Failed to load user',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<UserDetailBloc>.value(
          value: mockUserDetailBloc,
          child: const UserDetailScreen(),
        ),
      ),
    );

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
