import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../auth/session_invalidation_bus.dart';
import '../auth/session_token_store.dart';
import '../config/app_config.dart';

@module
abstract class DioModule {
  @lazySingleton
  Dio dio(
    SessionTokenStore tokenStore,
    SessionInvalidationBus invalidationBus,
  ) {
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
        onRequest: (options, handler) async {
          final token = await tokenStore.read();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            await tokenStore.clear();
            invalidationBus.invalidate();
          }
          return handler.next(e);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
        requestBody: false,
        responseBody: false,
        error: true,
      ),
    );

    return dio;
  }
}
