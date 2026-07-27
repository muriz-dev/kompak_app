import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/store_data.dart';
import '../../../../core/routes/app_router.dart';

@RoutePage()
class RedeemConfirmationPage extends StatelessWidget {
  final StoreItem item;

  const RedeemConfirmationPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // For mock purposes, using hardcoded user points
    const int userPoints = 1250;
    final int remainingPoints = userPoints - item.points;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => context.router.back(),
        ),
        title: const Text(
          'Konfirmasi Penukaran',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              item.imageUrlOrIcon.toString().startsWith('http') ? item.imageUrlOrIcon : 'https://images.unsplash.com/photo-1607349913338-fca6f7fc42d0?auto=format&fit=crop&w=800&q=80',
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160,
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                            ),
                          ),
                          if (item.isFeatured)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981), // Green
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'TERPOPULER',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.stars, color: Color(0xFFF59E0B), size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${item.points}',
                                      style: const TextStyle(
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Points summary row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB), // Blue
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Poin Anda',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  userPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Points',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Green
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Sisa Poin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  remainingPoints.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Points',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Location
                const Text(
                  'Lokasi Pengambilan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.storefront, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Warung Bu Harjo',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Jl. Harmoni, No. 12, Sektor Selatan',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Terms and Conditions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981), // Green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Syarat & Ketentuan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Penukaran tidak dapat dibatalkan setelah konfirmasi. Voucher berlaku selama 7 hari kalender. Tunjukkan QR Code saat pengambilan barang.',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showRedeemSuccessDialog(context, item);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Konfirmasi Penukaran',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => context.router.back(),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2), // Light red
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batalkan Penukaran',
                    style: TextStyle(
                      color: Color(0xFFEF4444), // Red 500
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRedeemSuccessDialog(BuildContext context, StoreItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981), // Green
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 40),
                  ),
                  const SizedBox(height: 16),
                  
                  // Title
                  const Text(
                    'Penukaran Berhasil!',
                    style: TextStyle(
                      color: Color(0xFF2563EB), // Blue
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Selamat! Penukaran poin Anda\ntelah berhasil.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Item Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.imageUrlOrIcon.toString().startsWith('http') ? item.imageUrlOrIcon : 'https://images.unsplash.com/photo-1607349913338-fca6f7fc42d0?auto=format&fit=crop&w=800&q=80',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 120,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Item Name
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Dashed divider
                  Row(
                    children: List.generate(
                      40,
                      (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade300,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ID Referensi', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                          const Text('#KP-8829103', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 12),
                          Text('Lokasi Penukaran', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                          const Text('Posko RW 05', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Waktu', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                          const Text('24 Okt 2023, 14:20', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 12),
                          Text('Status', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text('Berhasil', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // QR Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF), // Indigo 50
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tunjukkan QR Code di bawah ini\npada Admin saat pengambilan\nbarang di lokasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.qr_code_2, size: 100, color: Colors.black87),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download, color: Colors.white, size: 18),
                            label: const Text('Unduh QR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981), // Green
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(
                              'Berlaku hingga: 31 Okt 2023',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.router.replaceAll([const MainRoute()]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Kembali ke Beranda', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        context.router.push(PointHistoryRoute()); // go to history
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFEEF2FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Lihat Riwayat Poin', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
