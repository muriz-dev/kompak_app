import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../domain/entities/registration_failure.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase _registerUseCase;

  AuthBloc(this._registerUseCase) : super(AuthInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final receipt = await _registerUseCase(event.request);
      emit(RegisterSuccess(receipt));
    } on RegistrationFailure catch (error) {
      emit(AuthError(error.message, error.fieldErrors));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
