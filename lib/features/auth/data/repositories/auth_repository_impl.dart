import '../../../../core/utils/local_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_source.dart';
import '../models/auth_tokens.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  AuthRepositoryImpl(this.remoteSource);

  @override
  Future<void> register({
    required String phone,
    required String name,
    required String password,
    Map<String, dynamic>? vehicle,
  }) async {
    await remoteSource.register(
      phone: phone,
      name: name,
      password: password,
      vehicle: vehicle,
    );
  }

  @override
  Future<AuthTokens> verifyOtp({required String phone, required String otp}) {
    return remoteSource.verifyOtp(phone: phone, otp: otp);
  }

  @override
  Future<AuthTokens> login({required String phone, required String password}) {
    return remoteSource.login(phone: phone, password: password);
  }

  @override
  Future<void> logout() => remoteSource.logout();

  @override
  Future<void> forgotPassword({required String phone}) {
    return remoteSource.forgotPassword(phone: phone);
  }

  @override
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) {
    return remoteSource.resetPassword(phone: phone, otp: otp, newPassword: newPassword);
  }

  @override
  Future<bool> hasSession() => LocalStorage.hasTokens();
}
