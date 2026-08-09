import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/registration_receipt.dart';
import '../entities/session_user.dart';

abstract class AuthRepository {
  Future<SessionUser> login(LoginRequest request);
  Future<SessionUser?> restoreSession();
  Future<SessionUser?> refreshSession();
  Future<RegistrationReceipt> register(RegisterRequest request);
  Future<void> logout();
}
