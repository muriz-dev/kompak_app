import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../../../core/auth/session_token_store.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/session_user.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/registration_receipt.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SessionTokenStore _tokenStore;

  AuthRepositoryImpl(this._remoteDataSource, this._tokenStore);

  @override
  Future<SessionUser> login(LoginRequest request) async {
    final response = await _remoteDataSource.login(request);
    await _tokenStore.write(response.token);
    return response.user;
  }

  @override
  Future<RegistrationReceipt> register(RegisterRequest request) {
    return _remoteDataSource.register(request);
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clear();
  }

  @override
  Future<SessionUser?> restoreSession() async {
    final token = await _tokenStore.read();
    if (token == null || token.isEmpty) return null;
    return _getCurrentUserOrNullOnUnauthorized();
  }

  @override
  Future<SessionUser?> refreshSession() =>
      _getCurrentUserOrNullOnUnauthorized();

  Future<SessionUser?> _getCurrentUserOrNullOnUnauthorized() async {
    try {
      return await _remoteDataSource.getCurrentUser();
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        await _tokenStore.clear();
        return null;
      }
      rethrow;
    } catch (_) {
      if (await _tokenStore.read() == null) return null;
      rethrow;
    }
  }
}
