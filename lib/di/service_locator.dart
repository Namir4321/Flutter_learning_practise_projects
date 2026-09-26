import 'package:basic_widget/bloc/auth_bloc.dart';
import 'package:basic_widget/bloc/network/api_client.dart';
import 'package:basic_widget/bloc/user_bloc.dart';
import 'package:basic_widget/data/secure_storage.dart';
import 'package:basic_widget/repository/auth_repository.dart';
import 'package:basic_widget/repository/upload_repository.dart';
import 'package:basic_widget/repository/user_repository.dart';
import 'package:basic_widget/service/connectivity_bloc.dart';
import 'package:basic_widget/service/connectivity_service.dart';
import 'package:basic_widget/service/user_cache_service.dart';
import 'package:get_it/get_it.dart';
import 'package:basic_widget/bloc/user_detail_bloc.dart';
final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<SecureStorage>(() => SecureStorage());
  getIt.registerLazySingleton<ApiClient>(
    () => ApiClient(secureStorage: getIt<SecureStorage>()),
  );

  getIt.registerLazySingleton<UserCacheService>(() => UserCacheService());
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ConnectivityService>(() => ConnectivityService());

  getIt.registerLazySingleton<UploadRepository>(
    () => UploadRepository(apiClient: getIt<ApiClient>()),
  );

  getIt.registerFactory<ConnectivityBloc>(
    () => ConnectivityBloc(connectivityService: getIt<ConnectivityService>()),
  );
  getIt.registerFactory<UserDetailBloc>(
  () => UserDetailBloc(
    getIt<UserRepository>(),
  ),
);

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      repository: getIt<AuthRepository>(),
      secureStorage: getIt<SecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(
      apiClient: getIt<ApiClient>(),
      userCacheService: getIt<UserCacheService>(),
    ),
  );
  getIt.registerFactory<UserBloc>(() => UserBloc(getIt<UserRepository>()));
}
