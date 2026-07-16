import 'package:injectable/injectable.dart';
import '../../data/models/login_request.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<void> call(LoginRequest request) {
    return _repository.login(request);
  }
}
