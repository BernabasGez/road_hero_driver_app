import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:road_hero/core/api/dio_client.dart';
import 'package:road_hero/features/auth/data/repositories/auth_remote_source.dart';
import 'package:road_hero/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:road_hero/features/auth/domain/repositories/auth_repository.dart';
import 'package:road_hero/features/auth/domain/usecases/register_usecase.dart';
import 'package:road_hero/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';

// This is the global Service Locator
final sl = GetIt.instance;

Future<void> init() async {
  // 1. External Tools
  sl.registerLazySingleton(() => DioClient().dio);

  // 2. Data Sources
  sl.registerLazySingleton(() => AuthRemoteSource(sl()));
  sl.registerLazySingleton(() => HomeRemoteSource(sl()));

  // 3. Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // 4. Use Cases
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  // 5. BLoCs
  sl.registerFactory(() => AuthBloc(registerUseCase: sl()));
}
