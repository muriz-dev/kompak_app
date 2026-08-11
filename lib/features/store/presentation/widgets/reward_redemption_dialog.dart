import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/store_data.dart';
import 'reward_visuals.dart';

enum RedemptionDialogAction { home, history, close }

class RewardRedemptionDialog extends StatefulWidget {
  const RewardRedemptionDialog({
    super.key,
    required this.redemption,
    this.createdNow = false,
  });

  final RewardRedemption redemption;
  final bool createdNow;

  @override
  State<RewardRedemptionDialog> createState() => _RewardRedemptionDialogState();
}

class _RewardRedemptionDialogState extends State<RewardRedemptionDialog> {
  final _qrKey = GlobalKey();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final redemption = widget.redemption;
    final status = _statusPresentation(redemption.status);
    final claimToken = redemption.claimToken;

    return PopScope(
      canPop: !widget.createdNow,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: KompakColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: KompakColors.successSurface,
                      child: Icon(
                        Icons.check_rounded,
                        color: KompakColors.success,
                        size: 29,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.createdNow ? 'Penukaran Berhasil!' : 'QR Pengambilan',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: KompakColors.primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.createdNow
                      ? 'Permintaan penukaran poin Anda berhasil dibuat.'
                      : 'Tunjukkan QR ini kepada provider saat mengambil hadiah.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: KompakColors.mutedInk,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                _RewardDetails(redemption: redemption, status: status),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: KompakColors.primarySurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Tunjukkan QR Code di bawah ini kepada ${redemption.item.provider.name} saat pengambilan hadiah.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: KompakColors.ink,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 18),
                      RepaintBoundary(
                        key: _qrKey,
                        child: ColoredBox(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: claimToken != null
                                ? QrImageView(data: claimToken, size: 112)
                                : const SizedBox(
                                    width: 112,
                                    height: 112,
                                    child: Icon(
                                      Icons.qr_code_2,
                                      size: 86,
                                      color: KompakColors.mutedInk,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: redemption.claimToken == null || _isSharing
                              ? null
                              : () => _shareQr(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KompakColors.success,
                            disabledBackgroundColor: KompakColors.outline,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isSharing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download_rounded, size: 19),
                          label: const Text('Unduh QR'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.alarm_outlined,
                            color: KompakColors.mutedInk,
                            size: 15,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Berlaku hingga ${_formatDate(redemption.expiresAt)}',
                              style: const TextStyle(
                                color: KompakColors.mutedInk,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                if (widget.createdNow) ...[
                  _DialogButton(
                    label: 'Kembali ke Beranda',
                    backgroundColor: KompakColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: () =>
                        Navigator.of(context).pop(RedemptionDialogAction.home),
                  ),
                  const SizedBox(height: 8),
                  _DialogButton(
                    label: 'Lihat Riwayat Poin',
                    backgroundColor: KompakColors.primarySurface,
                    foregroundColor: KompakColors.primary,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(RedemptionDialogAction.history),
                  ),
                ] else
                  _DialogButton(
                    label: 'Tutup',
                    backgroundColor: KompakColors.primary,
                    foregroundColor: Colors.white,
                    onPressed: () =>
                        Navigator.of(context).pop(RedemptionDialogAction.close),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _shareQr(BuildContext context) async {
    setState(() => _isSharing = true);
    try {
      final shareBox = context.findRenderObject() as RenderBox?;
      final origin = shareBox == null
          ? null
          : shareBox.localToGlobal(Offset.zero) & shareBox.size;
      final boundary = _qrKey.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary) {
        throw StateError('QR belum siap.');
      }
      final image = await boundary.toImage(pixelRatio: 3);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('QR tidak dapat dibuat.');

      final fileName =
          'kompak-qr-${widget.redemption.id.replaceAll(RegExp('[^A-Za-z0-9-]'), '')}.png';
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(Uint8List.view(bytes.buffer), mimeType: 'image/png'),
          ],
          fileNameOverrides: [fileName],
          subject: 'QR Penukaran ${widget.redemption.item.title}',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('QR belum dapat diunduh. Coba lagi.')),
        );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }
}

class _RewardDetails extends StatelessWidget {
  const _RewardDetails({required this.redemption, required this.status});

  final RewardRedemption redemption;
  final _StatusPresentation status;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Stack(
        children: [
          RewardImage(
            item: redemption.item,
            height: 100,
            borderRadius: BorderRadius.circular(10),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: ProviderLogo(provider: redemption.item.provider, size: 38),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        redemption.item.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: KompakColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 10),
      const Divider(height: 1, color: KompakColors.outline),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Detail(
              label: 'ID Referensi',
              value: '#${_shortReference(redemption.id)}',
            ),
          ),
          Expanded(
            child: _Detail(
              label: 'Waktu',
              value: _formatDateTime(redemption.createdAt),
              alignEnd: true,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: _Detail(
              label: 'Lokasi Penukaran',
              value: redemption.item.provider.name,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: status.color,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              status.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _Detail extends StatelessWidget {
  const _Detail({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: alignEnd
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start,
    children: [
      Text(
        label,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(color: KompakColors.mutedInk, fontSize: 10),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
        style: const TextStyle(
          color: KompakColors.ink,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 42,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    ),
  );
}

class _StatusPresentation {
  const _StatusPresentation(this.label, this.color);

  final String label;
  final Color color;
}

_StatusPresentation _statusPresentation(RedemptionStatus status) =>
    switch (status) {
      RedemptionStatus.pending => const _StatusPresentation(
        'Menunggu Pengambilan',
        KompakColors.warning,
      ),
      RedemptionStatus.completed => const _StatusPresentation(
        'Berhasil',
        KompakColors.success,
      ),
      RedemptionStatus.rejected => const _StatusPresentation(
        'Ditolak',
        KompakColors.error,
      ),
      RedemptionStatus.cancelled => const _StatusPresentation(
        'Dibatalkan',
        KompakColors.error,
      ),
    };

String _shortReference(String value) => value.length <= 10
    ? value.toUpperCase()
    : value.substring(0, 10).toUpperCase();

String _formatDateTime(DateTime value) =>
    '${value.day} ${_months[value.month - 1]} ${value.year}, ${DateFormat('HH:mm').format(value)}';

String _formatDate(DateTime value) =>
    '${value.day} ${_months[value.month - 1]} ${value.year}';

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];
