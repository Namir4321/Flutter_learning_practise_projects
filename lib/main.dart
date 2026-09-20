import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/di/service_locator.dart';
import 'package:basic_widget/router/app_router.dart';
import 'package:basic_widget/service/connectivity_bloc.dart';
import 'package:basic_widget/service/connectivity_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  setupDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) {
            final authBloc = getIt<AuthBloc>();

            getIt<ApiClient>().onSessionExpired = () {
              authBloc.add(AuthLogoutRequested());
            };
            authBloc.add(AuthCheckRequested());
            return authBloc;
          },
        ),
        BlocProvider<ConnectivityBloc>(
          create: (_) => getIt<ConnectivityBloc>()..add(ConnectivityStarted()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final router = createRouter(authBloc);
    return MaterialApp.router(
      routerConfig: router,
      // routes: {
      //   '/': (context) => BlocProvider(
      //     create: (_) => getIt<UserBloc>()..add(UserLoadRequest()),
      //     child: const AuthGate(),
      //   ),
      //   '/about': (context) => ProtectedRoute(child: const AboutScreen()),
      //   '/user-details': (context) {
      //     final arguments = ModalRoute.of(context)?.settings.arguments;
      //     if (arguments is! User) {
      //       return const Scaffold(
      //         body: Center(child: Text('User details are unavailable')),
      //       );
      //     }

      //     final user = arguments;
      //     return ProtectedRoute(child: UserDetailScreen(user: user));
      //   },
      //   '/file-test': (context) => ProtectedRoute(
      //     child: FileTestScreen(uploadRepository: getIt<UploadRepository>()),
      //   ),
      // },
    );
  }
}
