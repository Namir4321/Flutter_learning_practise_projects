import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/data/shared_prefs.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:basic_widget/screen/about_screen.dart';
import 'package:basic_widget/screen/auth_gate.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    BlocProvider(
      create: (_) => AuthBloc(
        sharedPrefs: SharedPrefs(),
        repository: AuthRepository(),
        secureStorage: SecureStorage(),
      )..add(AuthCheckRequested()),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => BlocProvider(
          create: (_) => UserBloc(UserRepository())..add(UserLoadRequest()),
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
