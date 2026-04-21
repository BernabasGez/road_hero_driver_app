import 'package:dio/dio.dart';
import '../utils/local_storage.dart';
import '../utils/logger.dart';
import '../error/exceptions.dart';
import 'dart:io'; // Fixes 'HttpClient'
import 'package:flutter/foundation.dart'; // Fixes 'kIsWeb' and 'kDebugMode'
import 'package:dio/io.dart'; // Fixes 'IOHttpClientAdapter'

class AuthInterceptor extends Interceptor {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth header for public endpoints
    final publicPaths = [
      'auth/register',
      'auth/verify-otp',
      'auth/login',
      'auth/forgot-password',
      'auth/reset-password',
      'auth/token/refresh/',
      'meta/',
    ];

    final isPublic = publicPaths.any((p) => options.path.contains(p));

    if (!isPublic) {
      final token = await LocalStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    AppLogger.network(options.method, options.path);
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.network(
      response.requestOptions.method,
      response.requestOptions.path,
      statusCode: response.statusCode,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Attempt token refresh
      try {
        final refreshToken = await LocalStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          await LocalStorage.clearTokens();
          handler.reject(err);
          return;
        }

        // ... inside onError method
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: dio.options.baseUrl,
            connectTimeout: dio.options.connectTimeout,
            receiveTimeout: dio.options.receiveTimeout,
          ),
        );

        // ADD THIS BLOCK TO FIX THE HANDSHAKE ERROR
        if (!kIsWeb && kDebugMode) {
          refreshDio.httpClientAdapter = IOHttpClientAdapter(
            createHttpClient: () {
              final client = HttpClient();
              client.badCertificateCallback = (cert, host, port) => true;
              return client;
            },
          );
        }
        // ... rest of the code
        final refreshResponse = await refreshDio.post(
          'auth/token/refresh/',
          data: {'refresh': refreshToken},
        );

        final data = refreshResponse.data['data'] ?? refreshResponse.data;
        final newAccess = data['access'] ?? data['token'];
        final newRefresh = data['refresh'] ?? refreshToken;

        if (newAccess != null) {
          await LocalStorage.saveTokens(access: newAccess, refresh: newRefresh);

          // Retry the original request with the new token
          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccess';

          final retryResponse = await dio.fetch(retryOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (e) {
        AppLogger.error('Token refresh failed', e);
        await LocalStorage.clearTokens();
      }
    }

    // Parse error message from API
    String message = 'Something went wrong. Please try again.';
    if (err.response?.data is Map) {
      message = err.response?.data['message'] ?? message;
    } else if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Connection timed out. Please check your network.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'No internet connection.';
    }

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: ServerException(message, statusCode: err.response?.statusCode),
      ),
    );
  }
}
