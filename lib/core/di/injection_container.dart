import 'package:get_it/get_it.dart';
import 'package:road_hero/core/api/dio_client.dart';
import 'package:road_hero/features/auth/data/repositories/auth_remote_source.dart';
import 'package:road_hero/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:road_hero/features/auth/domain/repositories/auth_repository.dart';
import 'package:road_hero/features/auth/domain/usecases/register_usecase.dart';
import 'package:road_hero/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:road_hero/features/home/data/repositories/home_remote_source.dart';
import 'package:road_hero/features/home/data/repositories/profile_remote_source.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton(() => DioClient().dio);
  sl.registerLazySingleton(() => AuthRemoteSource(sl()));
  sl.registerLazySingleton(() => HomeRemoteSource(sl()));
  sl.registerLazySingleton(() => ProfileRemoteSource(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerFactory(() => AuthBloc(registerUseCase: sl()));
}
