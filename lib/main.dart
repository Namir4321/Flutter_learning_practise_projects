import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/auth_event.dart';
import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/model/user.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:basic_widget/repository/upload_repository.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:basic_widget/screen/about_screen.dart';
import 'package:basic_widget/screen/auth_gate.dart';
import 'package:basic_widget/screen/user_detail_screen.dart';
import 'package:basic_widget/service/connectivity_bloc.dart';
import 'package:basic_widget/service/connectivity_event.dart';
import 'package:basic_widget/service/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:basic_widget/screen/test_screen.dart';

void main() {
  final secureStorage = SecureStorage();
  final apiClient = ApiClient(secureStorage: secureStorage);
  final authRepository = AuthRepository(apiClient: apiClient);
  final connectivityService = ConnectivityService();
  final authBloc = AuthBloc(
    repository: authRepository,
    secureStorage: secureStorage,
  );
  final connectivityBloc = ConnectivityBloc(
    connectivityService: connectivityService,
  );
  connectivityBloc.add(ConnectivityStarted());

  apiClient.onSessionExpired = () {
    authBloc.add(AuthLogoutRequested());
  };
  authBloc.add(AuthCheckRequested());
  final uploadRepository = UploadRepository(apiClient: apiClient);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: connectivityBloc),
      ],
      child: MyApp(apiClient: apiClient, uploadRepository: uploadRepository),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ApiClient apiClient;
  final UploadRepository uploadRepository;

  const MyApp({
    super.key,
    required this.apiClient,
    required this.uploadRepository,
  });

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
        '/file-test': (context) =>
            FileTestScreen(uploadRepository: uploadRepository),
      },
    );
  }
}
