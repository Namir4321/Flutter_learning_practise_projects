import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_state.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/di/service_locator.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/upload_repository.dart';
import 'package:basic_widget/router/go_router_refresh_stream.dart';
import 'package:basic_widget/screen/about_screen.dart';
import 'package:basic_widget/screen/auth_gate.dart';
import 'package:basic_widget/screen/login_screen.dart';
import 'package:basic_widget/screen/test_screen.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:basic_widget/widgets/protected_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<UserBloc>()..add(UserLoadRequest()),
            child: const AuthGate(),
          );
        },
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) {
          return ProtectedRoute(child: const AboutScreen());
        },
      ),
      GoRoute(
        path: '/user-details',
        builder: (context, state) {
          final arguments = state.extra;

          if (arguments is! User) {
            return const Scaffold(
              body: Center(child: Text('User details are unavailable')),
            );
          }

          return ProtectedRoute(child: UserDetailScreen(user: arguments));
        },
      ),
      GoRoute(
        path: '/file-test',
        builder: (context, state) {
          return ProtectedRoute(
            child: FileTestScreen(uploadRepository: getIt<UploadRepository>()),
          );
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),
    ],
    redirect: (context, state) {
      final status = authBloc.state.status;
      final isLoginRoute = state.matchedLocation == '/login';

      if (status == AuthStatus.unauthenticated && !isLoginRoute) {
        return '/login';
      }

      if (status == AuthStatus.authenticated && isLoginRoute) {
        return '/';
      }

      return null;
    },
  );
}
