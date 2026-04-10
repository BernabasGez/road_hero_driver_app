import 'package:dio/dio.dart';
import '../models/register_response.dart';
import '../../../../core/utils/local_storage.dart';

class AuthRemoteSource {
  final Dio dio;
  AuthRemoteSource(this.dio);

  // 1. REGISTER
  Future<RegisterResponse> register({
    required String phone,
    required String name,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        'auth/register',
        data: {"phone_number": phone, "full_name": name, "password": password},
      );
      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 2. VERIFY OTP
  Future<void> verifyOtp({required String phone, required String otp}) async {
    try {
      final response = await dio.post(
        'auth/verify-otp',
        data: {"phone_number": phone, "otp": otp},
      );
      final data = response.data['data'];
      await LocalStorage.saveTokens(data['token'], data['refresh']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // 3. LOGIN (Added this)
  Future<void> login({required String phone, required String password}) async {
    try {
      final response = await dio.post(
        'auth/login',
        data: {"phone_number": phone, "password": password},
      );
      final data = response.data['data'];
      await LocalStorage.saveTokens(data['token'], data['refresh']);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException e) {
    print("API ERROR: ${e.response?.data}");
    final msg =
        e.response?.data['message'] ?? "Request failed. Check your connection.";
    throw Exception(msg);
  }
}
