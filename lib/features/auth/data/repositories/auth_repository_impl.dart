import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepositoryImpl(this._remoteDataSource, this._prefs);

  @override
  Future<void> login(LoginRequest request) async {
    final data = await _remoteDataSource.login(request);
    
    final token = data['token'] as String?;
    if (token != null) {
      await _prefs.setString('jwt_token', token);
    } else {
      throw Exception('Token not found in response');
    }
  }

  @override
  Future<void> register(RegisterRequest request) async {
    await _remoteDataSource.register(request);
  }

  @override
  Future<void> logout() async {
    await _prefs.remove('jwt_token');
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = _prefs.getString('jwt_token');
    return token != null && token.isNotEmpty;
  }
}
