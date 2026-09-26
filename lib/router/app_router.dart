import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_state.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/di/service_locator.dart';
import 'package:basic_widget/repository/upload_repository.dart';
import 'package:basic_widget/router/go_router_refresh_stream.dart';
import 'package:basic_widget/screen/about_screen.dart';
import 'package:basic_widget/screen/login_screen.dart';
import 'package:basic_widget/screen/test_screen.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:basic_widget/screen/userscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:basic_widget/bloc/user_detail_bloc.dart';
import 'package:basic_widget/bloc/user_detail_event.dart';

GoRouter createRouter(AuthBloc authBloc) {
  // Routes that require authentication.
  final protectedRoutes = <String>{'/about', '/users/:id', '/file-test', '/'};

  return GoRouter(
    initialLocation: '/',

    // Re-evaluate redirect whenever AuthBloc emits a new state.
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    redirect: (context, state) {
      final status = authBloc.state.status;
      final location = state.matchedLocation;

      final isLoginRoute = location == '/login';

      // Example:
      // /login?from=/file-test
      //
      // This gives us:
      // from = '/file-test'
      final from = state.uri.queryParameters['from'];

      // Authentication is still being checked.
      // Don't make a routing decision yet.
      if (status == AuthStatus.initial || status == AuthStatus.loading) {
        return null;
      }

      // User is logged out and trying to access
      // a protected route.
      if (status == AuthStatus.unauthenticated &&
          protectedRoutes.contains(location)) {
        final requestedLocation = state.uri.toString();

        return '/login?from=${Uri.encodeComponent(requestedLocation)}';
      }

      // User has successfully logged in while on /login.
      //
      // If they originally wanted another page,
      // return them there.
      //
      // Otherwise go to home.
      if (status == AuthStatus.authenticated && isLoginRoute) {
        return from ?? '/';
      }

      // No redirect required.
      return null;
    },

    routes: [
      // HOME
      GoRoute(
        path: '/',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<UserBloc>()..add(UserLoadRequest()),
            child: const UserScreen(),
          );
        },
      ),

      // LOGIN - public
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      // ABOUT - protected by centralized redirect
      GoRoute(
        path: '/about',
        builder: (context, state) {
          return const AboutScreen();
        },
      ),

      // USER DETAILS - protected by centralized redirect
      GoRoute(
        path: '/users/:id',
        builder: (context, state) {
          final idString = state.pathParameters['id'];
          final id = int.tryParse(idString ?? '');
          if (id == null) {
            return const Scaffold(body: Center(child: Text('Invalid user Id')));
          }
          return BlocProvider<UserDetailBloc>(
            create: (_) =>
                getIt<UserDetailBloc>()..add(UserDetailRequested(id)),
            child: const UserDetailScreen(),
          );
        },
      ),

      // FILE UPLOAD - protected by centralized redirect
      GoRoute(
        path: '/file-test',
        builder: (context, state) {
          return FileTestScreen(uploadRepository: getIt<UploadRepository>());
        },
      ),
    ],
  );
}
