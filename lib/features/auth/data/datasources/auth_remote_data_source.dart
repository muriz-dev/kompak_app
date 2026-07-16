import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(LoginRequest request);
  Future<Map<String, dynamic>> register(RegisterRequest request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<Map<String, dynamic>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      
      // The API returns ApiResponse.ok format: { "success": true, "message": "...", "data": { "token": "...", "user": {...} } }
      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  @override
  Future<Map<String, dynamic>> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/users/register',
        data: request.toJson(),
      );
      
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      } else {
        throw Exception(response.data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }
}
