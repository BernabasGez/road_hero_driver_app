import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  AuthRepositoryImpl(this.remoteSource);

  @override
  Future<void> register(RegisterParams params) async {
    await remoteSource.register(
      phone: params.phoneNumber,
      name: params.fullName,
      password: params.password,
    );
  }
}
