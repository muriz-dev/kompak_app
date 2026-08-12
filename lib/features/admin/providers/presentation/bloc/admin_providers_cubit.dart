import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_provider.dart';
import '../../domain/repositories/admin_providers_repository.dart';
import 'admin_providers_state.dart';

@injectable
class AdminProvidersCubit extends Cubit<AdminProvidersState> {
  AdminProvidersCubit(this._repository) : super(AdminProvidersLoading());

  static const pageSize = 4;

  final AdminProvidersRepository _repository;
  String _query = '';
  AdminProviderStatus? _status;
  int _page = 1;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) emit(AdminProvidersLoading());
    try {
      final data = await _repository.getProviders(
        query: _query,
        status: _status,
        page: _page,
        pageSize: pageSize,
      );
      emit(AdminProvidersLoaded(data: data, query: _query, status: _status));
    } catch (error) {
      emit(AdminProvidersFailure(_message(error)));
    }
  }

  Future<void> search(String query) async {
    final normalized = query.trim();
    if (normalized == _query && _page == 1) return;
    _query = normalized;
    _page = 1;
    await load();
  }

  Future<void> filter(AdminProviderStatus? status) async {
    if (status == _status && _page == 1) return;
    _status = status;
    _page = 1;
    await load();
  }

  Future<void> goToPage(int page) async {
    final current = state;
    if (current is! AdminProvidersLoaded) return;
    final nextPage = page.clamp(1, current.data.pagination.totalPages);
    if (nextPage == _page) return;
    _page = nextPage;
    await load();
  }

  Future<void> refresh() => load(showLoading: false);

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
