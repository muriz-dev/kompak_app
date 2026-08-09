import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class FaceScannerOverlay extends StatefulWidget {
  final Widget child;
  final bool active;

  const FaceScannerOverlay({
    required this.child,
    this.active = true,
    super.key,
  });

  @override
  State<FaceScannerOverlay> createState() => _FaceScannerOverlayState();
}

class _FaceScannerOverlayState extends State<FaceScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      value: 0.18,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _syncAnimation();
  }

  @override
  void didUpdateWidget(FaceScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncAnimation();
  }

  void _syncAnimation() {
    if (!widget.active || _reduceMotion) {
      _controller
        ..stop()
        ..value = 0.42;
      return;
    }
    if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: 0.62,
              heightFactor: 0.64,
              child: Semantics(
                label: 'Area pemindaian wajah',
                child: Container(
                  key: const ValueKey('face-scanner-guide'),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: KompakColors.scannerGuide,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.28),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: RepaintBoundary(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return AnimatedBuilder(
                          animation: _controller,
                          child: Container(
                            key: const ValueKey('face-scanner-line'),
                            height: 4,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0),
                                  Colors.white,
                                  Colors.white.withValues(alpha: 0),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.32),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          builder: (context, scanLine) {
                            final progress = Curves.easeInOutCubic.transform(
                              _controller.value,
                            );
                            final travel = constraints.maxHeight - 4;
                            return Align(
                              alignment: Alignment.topCenter,
                              child: Transform.translate(
                                offset: Offset(0, travel * progress),
                                child: scanLine,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
