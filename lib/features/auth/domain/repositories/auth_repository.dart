import '../../data/models/auth_tokens.dart';

abstract class AuthRepository {
  Future<void> register({
    required String phone,
    required String name,
    required String password,
    Map<String, dynamic>? vehicle,
  });

  Future<AuthTokens> verifyOtp({required String phone, required String otp});
  Future<AuthTokens> login({required String phone, required String password});
  Future<void> logout();
  Future<void> forgotPassword({required String phone});
  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  });
  Future<bool> hasSession();
}
