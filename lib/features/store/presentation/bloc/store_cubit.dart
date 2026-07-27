import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/store_data.dart';
import 'store_state.dart';

@injectable
class StoreCubit extends Cubit<StoreState> {
  StoreCubit() : super(StoreLoading());

  void loadStoreData() async {
    emit(StoreLoading());
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final stats = StoreStats(totalPoints: 1250);

      final categories = [
        StoreCategory(id: 'all', name: 'Semua Item'),
        StoreCategory(id: 'pokok', name: 'Kebutuhan Pokok'),
        StoreCategory(id: 'layanan', name: 'Layanan Warga'),
      ];

      final items = [
        StoreItem(
          id: '1',
          title: 'Voucher Sembako Premium',
          description:
              'Dapatkan paket lengkap beras 5kg, minyak 2L, dan gula 1kg di warung terdekat.',
          imageUrlOrIcon:
              'https://digibook.id/upload/produk/2403/AS-SALAM-2438174026HZKX.jpg',
          points: 500,
          isFeatured: true,
          itemType: ItemType.image,
        ),
        StoreItem(
          id: '2',
          title: 'Bebas Iuran Bulan Ini',
          description: 'Gratis iuran.',
          imageUrlOrIcon: 'delete_outline', // We'll map this to an icon in UI
          points: 250,
          itemType: ItemType.icon,
        ),
        StoreItem(
          id: '3',
          title: 'Paket Sarapan Sehat',
          description:
              'Nikmati sarapan sehat bubur ayam dan teh manis di warung mang Udin.',
          imageUrlOrIcon:
              'https://images.pexels.com/photos/1640777/pexels-photo-1640777.jpeg',
          points: 150,
          itemType: ItemType.image,
        ),
        StoreItem(
          id: '4',
          title: 'Token Listrik 20rb',
          description: 'Token listrik PLN.',
          imageUrlOrIcon: 'bolt',
          points: 250,
          itemType: ItemType.icon,
        ),
        StoreItem(
          id: '5',
          title: 'Tote Bag Ramah Lingkungan',
          description:
              'Tote bag kanvas cantik edisi khusus warga, cocok untuk belanja harian.',
          imageUrlOrIcon:
              'https://images.pexels.com/photos/3731256/pexels-photo-3731256.jpeg',
          points: 200,
          itemType: ItemType.image,
        ),
      ];

      final featuredItem = items.firstWhere((element) => element.isFeatured);
      final regularItems = items
          .where((element) => !element.isFeatured)
          .toList();

      emit(
        StoreLoaded(
          stats: stats,
          categories: categories,
          activeCategoryId: 'all',
          featuredItem: featuredItem,
          regularItems: regularItems,
        ),
      );
    } catch (e) {
      emit(StoreError(e.toString()));
    }
  }

  void changeCategory(String categoryId) {
    final currentState = state;
    if (currentState is StoreLoaded) {
      emit(currentState.copyWith(activeCategoryId: categoryId));
    }
  }
}
