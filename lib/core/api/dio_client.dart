import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:dio/io.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(AuthInterceptor(dio));

    // THIS IS THE CRITICAL PART:
    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          // This tells Android to ignore the "Not Secure" warning on YOUR IP
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }
  }
}
