import 'package:injectable/injectable.dart';
import '../../data/models/login_request.dart';
import '../repositories/auth_repository.dart';
import '../entities/session_user.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<SessionUser> call(LoginRequest request) {
    return _repository.login(request);
  }
}
