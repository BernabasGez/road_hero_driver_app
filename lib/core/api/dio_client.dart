import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // To check if we are on Web
import 'package:dio/io.dart';
import 'dart:io';

class DioClient {
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: 'https://34.254.56.65/api/v1/driver/',
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // Only apply the SSL bypass if we are NOT on Web (i.e., on your Phone)
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
            client.badCertificateCallback =
                (X509Certificate cert, String host, int port) => true;
            return client;
          };
    }
  }
}
