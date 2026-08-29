import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:basic_widget/screen/about_screen.dart';
import 'package:basic_widget/screen/auth_gate.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage: secureStorage);

  final authRepository = AuthRepository(apiClient: apiClient);
  runApp(
    BlocProvider(
      create: (_) =>
          AuthBloc(repository: authRepository, secureStorage: secureStorage)
            ..add(AuthCheckRequested()),
      child: MyApp(apiClient: apiClient),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  const MyApp({super.key, required this.apiClient});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider(
          create: (_) =>
              UserBloc(UserRepository(apiClient: apiClient))
                ..add(UserLoadRequest()),
          child: const AuthGate(),
        ),
        '/about': (context) => const AboutScreen(),
        '/user-details': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is! User) {
            return const Scaffold(
              body: Center(child: Text('User details are unavailable')),
            );
          }

          final user = arguments;
          return UserDetailScreen(user: user);
        },
      },
    );
  }
}
