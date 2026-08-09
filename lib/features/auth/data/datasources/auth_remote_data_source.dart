import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_request.dart';
import '../models/registration_receipt.dart';
import '../../domain/entities/registration_failure.dart';
import '../../domain/entities/session_user.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponse> login(LoginRequest request);
  Future<SessionUser> getCurrentUser();
  Future<RegistrationReceipt> register(RegisterRequest request);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      // The API returns ApiResponse.ok format: { "success": true, "message": "...", "data": { "token": "...", "user": {...} } }
      if (response.data['success'] == true) {
        return LoginResponse.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? e.message);
    }
  }

  @override
  Future<SessionUser> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      if (response.data['success'] == true) {
        return SessionUser.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      }
      throw Exception(response.data['message'] ?? 'Session check failed');
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) rethrow;
      throw Exception(error.response?.data['message'] ?? error.message);
    }
  }

  @override
  Future<RegistrationReceipt> register(RegisterRequest request) async {
    try {
      final extension = request.faceImagePath.split('.').last.toLowerCase();
      final imageSubtype = extension == 'png'
          ? 'png'
          : extension == 'webp'
          ? 'webp'
          : 'jpeg';
      final form = FormData.fromMap({
        ...request.toFields(),
        'faceImage': await MultipartFile.fromFile(
          request.faceImagePath,
          filename: 'face.$extension',
          contentType: DioMediaType('image', imageSubtype),
        ),
      });
      final response = await _dio.post('/users/register', data: form);

      if (response.data['success'] == true) {
        return RegistrationReceipt.fromJson(
          Map<String, dynamic>.from(response.data['data'] as Map),
        );
      } else {
        throw RegistrationFailure(
          response.data['message'] ?? 'Registration failed',
          _fieldErrors(response.data['errors']),
        );
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      throw RegistrationFailure(
        data is Map
            ? data['message']?.toString() ?? 'Registration failed'
            : e.message ?? 'Registration failed',
        data is Map ? _fieldErrors(data['errors']) : const {},
      );
    }
  }

  Map<String, String> _fieldErrors(dynamic errors) {
    if (errors is! Map) return const {};
    return errors.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }
}
