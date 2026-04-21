import 'package:dio/dio.dart';
import '../../../../core/utils/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_tokens.dart';

class AuthRemoteSource {
  final Dio dio;
  AuthRemoteSource(this.dio);

  Future<Map<String, dynamic>> register({
    required String phone,
    required String name,
    required String password,
    Map<String, dynamic>? vehicle,
  }) async {
    try {
      final body = <String, dynamic>{
        'phone_number': phone,
        'full_name': name,
        'password': password,
      };
      if (vehicle != null) body['vehicle'] = vehicle;

      final response = await dio.post('auth/register', data: body);
      return response.data;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<AuthTokens> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        'auth/verify-otp',
        data: {'phone_number': phone, 'otp': otp},
      );
      final data = response.data['data'] ?? response.data;
      final tokens = AuthTokens.fromJson(data);
      await LocalStorage.saveTokens(
        access: tokens.access,
        refresh: tokens.refresh,
      );
      return tokens;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<AuthTokens> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        'auth/login',
        data: {'phone_number': phone, 'password': password},
      );
      final data = response.data['data'] ?? response.data;
      final tokens = AuthTokens.fromJson(data);
      await LocalStorage.saveTokens(
        access: tokens.access,
        refresh: tokens.refresh,
      );
      return tokens;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> logout() async {
    try {
      final refresh = await LocalStorage.getRefreshToken();
      await dio.post('auth/logout', data: {'refresh': refresh});
    } catch (_) {
      // Logout is best-effort
    } finally {
      await LocalStorage.clearTokens();
    }
  }

  Future<void> forgotPassword({required String phone}) async {
    try {
      await dio.post('auth/forgot-password', data: {'phone_number': phone});
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> resetPassword({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await dio.post(
        'auth/reset-password',
        data: {'phone_number': phone, 'otp': otp, 'new_password': newPassword},
      );
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  ServerException _extractError(DioException e) {
    print("🚨 SERVER ERROR DETAILS: ${e.response?.data}");
    print("🚨 STATUS CODE: ${e.response?.statusCode}");
    String msg = 'Request failed. Please try again.';
    if (e.response?.data is Map) {
      msg = e.response?.data['message'] ?? msg;
    }
    if (e.error is ServerException) return e.error as ServerException;
    AppLogger.error('Auth API Error', e);
    return ServerException(msg, statusCode: e.response?.statusCode);
  }
}
