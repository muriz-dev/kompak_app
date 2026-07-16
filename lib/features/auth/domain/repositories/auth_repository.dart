import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<void> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
