import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:road_hero/features/home/presentation/bloc/cart_cubit.dart';
import '../api/dio_client.dart';
import '../../features/auth/data/datasources/auth_remote_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/data/datasources/home_remote_source.dart';
import '../../features/home/presentation/bloc/home_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ─── Core ──────────────────────────────────
  final dioClient = DioClient();
  sl.registerLazySingleton<Dio>(() => dioClient.dio);

  // ─── Auth ──────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteSource(sl<Dio>()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteSource>()),
  );
  sl.registerFactory(() => AuthBloc(sl<AuthRepository>()));

  // ─── Home ──────────────────────────────────
  sl.registerLazySingleton(() => HomeRemoteSource(sl<Dio>()));
  sl.registerFactory(() => HomeCubit(sl<HomeRemoteSource>()));
  sl.registerLazySingleton(() => CartCubit()); // Added this line
}
