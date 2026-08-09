import 'package:injectable/injectable.dart';
import '../../data/models/register_request.dart';
import '../../data/models/registration_receipt.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<RegistrationReceipt> call(RegisterRequest request) {
    return _repository.register(request);
  }
}
