import 'package:injectable/injectable.dart';
import '../../data/models/register_request.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> call(RegisterRequest request) {
    return _repository.register(request);
  }
}
