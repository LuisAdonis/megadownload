import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final generalDioProvider = Provider<Dio>((ref) {
  return DioProvider.createUnauthenticatedClient();
});

class DioProvider {
  static Dio createUnauthenticatedClient() {
    final dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment('API_URL', defaultValue: "http://192.168.123.40:3000"),
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        // sendTimeout: const Duration(seconds: 30),
      ),
    );
    return dio;
  }
}
