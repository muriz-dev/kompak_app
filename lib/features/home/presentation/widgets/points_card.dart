import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/home_data.dart';

class PointsCard extends StatelessWidget {
  const PointsCard({
    super.key,
    required this.userSummary,
    required this.onRedeemTap,
  });

  final UserSummary userSummary;
  final VoidCallback onRedeemTap;

  @override
  Widget build(BuildContext context) {
    final formattedPoints = NumberFormat.decimalPattern(
      'id_ID',
    ).format(userSummary.points);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: const Color(0xFF2F67E8),
        child: SizedBox(
          height: 156,
          child: Stack(
            children: [
              Positioned(
                top: -72,
                right: -32,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.2,
                    child: SvgPicture.asset(
                      'assets/images/app_icon_white.svg',
                      width: 200,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'TOTAL KONTRIBUSI',
                                style: TextStyle(
                                  color: Color(0xFFE5ECFF),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      formattedPoints,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 31,
                                        height: 1.1,
                                        letterSpacing: -0.5,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Text(
                                      'Poin',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Icon(
                            Icons.workspace_premium_outlined,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: FilledButton.icon(
                        key: const ValueKey('home-redeem-points-button'),
                        onPressed: onRedeemTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF2F67E8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.card_giftcard_rounded, size: 23),
                        label: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Tukarkan Poin ke Toko Poin',
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
