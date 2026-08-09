import '../../data/models/login_request.dart';
import '../../data/models/register_request.dart';
import '../../data/models/registration_receipt.dart';

abstract class AuthRepository {
  Future<void> login(LoginRequest request);
  Future<RegistrationReceipt> register(RegisterRequest request);
  Future<void> logout();
  Future<bool> isLoggedIn();
}
