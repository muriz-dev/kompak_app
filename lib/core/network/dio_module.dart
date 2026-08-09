import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(SharedPreferences prefs) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Accept': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final String? token = prefs.getString('jwt_token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await prefs.remove('jwt_token');

            // You can trigger navigation to the Login page here if needed
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(requestBody: false, responseBody: false, error: true),
    );

    return dio;
  }
}
