import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/admin_point_shop_product.dart';
import '../../domain/repositories/admin_point_shop_repository.dart';
import 'admin_point_shop_state.dart';

@injectable
class AdminPointShopCubit extends Cubit<AdminPointShopState> {
  AdminPointShopCubit(this._repository) : super(AdminPointShopLoading());

  static const pageSize = 3;
  final AdminPointShopRepository _repository;

  late AdminPointShopProductStatus _status;
  String _query = '';
  AdminPointShopProductType? _type;
  String? _providerId;
  int _page = 1;

  Future<void> initialize({
    required AdminPointShopProductStatus status,
    String? providerId,
  }) async {
    _status = status;
    _providerId = providerId;
    await load();
  }

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) emit(AdminPointShopLoading());
    try {
      final data = await _repository.getProducts(
        status: _status,
        query: _query,
        type: _type,
        providerId: _providerId,
        page: _page,
        pageSize: pageSize,
      );
      emit(
        AdminPointShopLoaded(
          data: data,
          status: _status,
          query: _query,
          type: _type,
        ),
      );
    } catch (error) {
      emit(AdminPointShopFailure(_message(error)));
    }
  }

  Future<void> search(String query) async {
    final normalized = query.trim();
    if (normalized == _query && _page == 1) return;
    _query = normalized;
    _page = 1;
    await load();
  }

  Future<void> filter(AdminPointShopProductType? type) async {
    if (type == _type && _page == 1) return;
    _type = type;
    _page = 1;
    await load();
  }

  Future<void> goToPage(int page) async {
    final current = state;
    if (current is! AdminPointShopLoaded) return;
    final maxPage = current.data.pagination.totalPages;
    if (maxPage == 0) return;
    final nextPage = page.clamp(1, maxPage);
    if (nextPage == _page) return;
    _page = nextPage;
    await load();
  }

  Future<void> toggleProduct(AdminPointShopProduct product) async {
    final current = state;
    if (current is! AdminPointShopLoaded || current.updatingProductId != null) {
      return;
    }
    final nextStatus = _status == AdminPointShopProductStatus.active
        ? AdminPointShopProductStatus.inactive
        : AdminPointShopProductStatus.active;
    emit(
      current.copyWith(updatingProductId: product.id, clearActionMessage: true),
    );
    try {
      await _repository.updateProductStatus(product.id, nextStatus);
      final page = await _repository.getProducts(
        status: _status,
        query: _query,
        type: _type,
        providerId: _providerId,
        page: _page,
        pageSize: pageSize,
      );
      if (page.items.isEmpty && _page > 1) {
        _page -= 1;
        return load(showLoading: false);
      }
      emit(
        AdminPointShopLoaded(
          data: page,
          status: _status,
          query: _query,
          type: _type,
          actionMessage: nextStatus == AdminPointShopProductStatus.active
              ? 'Produk ditambahkan ke Toko Poin.'
              : 'Produk dihapus dari Toko Poin.',
        ),
      );
    } catch (error) {
      emit(
        current.copyWith(
          clearUpdatingProduct: true,
          actionMessage: _message(error),
        ),
      );
    }
  }

  Future<void> refresh() => load(showLoading: false);

  String _message(Object error) => error.toString().replaceFirst(
    RegExp(r'^(Exception|FormatException):\s*'),
    '',
  );
}
