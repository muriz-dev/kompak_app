import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_provider.dart';
import '../../domain/repositories/admin_providers_repository.dart';
import 'admin_provider_detail_state.dart';

@injectable
class AdminProviderDetailCubit extends Cubit<AdminProviderDetailState> {
  AdminProviderDetailCubit(this._repository)
    : super(AdminProviderDetailLoading());

  final AdminProvidersRepository _repository;
  String? _providerId;

  Future<void> load(String providerId, {bool showLoading = true}) async {
    _providerId = providerId;
    if (showLoading) emit(AdminProviderDetailLoading());
    try {
      emit(
        AdminProviderDetailLoaded(
          detail: await _repository.getProviderDetail(providerId),
        ),
      );
    } catch (error) {
      emit(AdminProviderDetailFailure(_message(error)));
    }
  }

  Future<void> refresh() async {
    final providerId = _providerId;
    if (providerId != null) await load(providerId, showLoading: false);
  }

  Future<bool> updateStatus(AdminProviderStatus status) async {
    final current = state;
    final providerId = _providerId;
    if (current is! AdminProviderDetailLoaded ||
        current.updating ||
        providerId == null) {
      return false;
    }

    emit(current.copyWith(updating: true, clearActionError: true));
    try {
      await _repository.updateStatus(providerId, status);
      final detail = await _repository.getProviderDetail(providerId);
      emit(AdminProviderDetailLoaded(detail: detail));
      return true;
    } catch (error) {
      emit(current.copyWith(updating: false, actionError: _message(error)));
      return false;
    }
  }

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
