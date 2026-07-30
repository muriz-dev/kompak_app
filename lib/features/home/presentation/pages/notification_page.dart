import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.router.back(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Buttons
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Semua',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5), // Light green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Belum dibaca',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Hari Ini Section
              const Text(
                'Hari ini',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.event_available,
                iconColor: const Color(0xFF10B981),
                title: 'Kegiatan Baru: Kerja Bakti Minggu Ini',
                subtitle:
                    'Ayo bersihkan lingkungan RT 04 mulai jam 07:00 pagi. Titik kumpul di balai warga.',
                time: '2j lalu',
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.stars,
                iconColor: const Color(0xFFF59E0B), // Orange
                title: 'Poin Masuk: +50 dari Absensi',
                subtitle:
                    'Selamat! Kamu mendapatkan poin karena telah hadir tepat waktu di rapat warga tadi malam.',
                time: '5j lalu',
              ),

              const SizedBox(height: 24),

              // Kemarin Section
              const Text(
                'Kemarin',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.campaign,
                iconColor: const Color(0xFF2563EB), // Blue
                title: 'Pengumuman: Jadwal Ronda Baru',
                subtitle:
                    'Mohon periksa jadwal siskamling terbaru untuk periode bulan Oktober 2023.',
                time: '1h lalu',
              ),
              const SizedBox(height: 12),
              _buildNotificationCard(
                icon: Icons.people,
                iconColor: const Color(0xFF2563EB), // Blue
                title: 'Warga Baru Terdaftar',
                subtitle:
                    'Sambut Pak Andi yang baru saja bergabung di Blok C No. 12 sebagai tetangga baru.',
                time: '1h lalu',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
