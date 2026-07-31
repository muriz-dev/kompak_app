import 'package:flutter/material.dart';

class KompakBottomNavigation extends StatelessWidget {
  const KompakBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: Icons.home_rounded, label: 'Home'),
    (icon: Icons.how_to_reg_rounded, label: 'Absensi'),
    (icon: Icons.storefront_outlined, label: 'Toko'),
    (icon: Icons.stars_rounded, label: 'Peringkat'),
  ];

  static const _transitionDuration = Duration(milliseconds: 180);
  static const _transitionCurve = Curves.easeOutCubic;
  static const _activeColor = Color(0xFF2F67E8);

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : _transitionDuration;

    return SizedBox(
      height: 88 + safeBottom,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: Color(0x180F172A),
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(12, 8, 12, 6 + safeBottom),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;
              final indicatorWidth = itemWidth.clamp(72.0, 88.0);

              return Row(
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isSelected = currentIndex == index;

                  return Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: isSelected ? 1 : 0,
                        end: isSelected ? 1 : 0,
                      ),
                      duration: duration,
                      curve: _transitionCurve,
                      builder: (context, activeProgress, child) {
                        final foreground = Color.lerp(
                          const Color(0xFF4D545D),
                          Colors.white,
                          activeProgress,
                        )!;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Transform.scale(
                              key: ValueKey(
                                'bottom-nav-indicator-scale-$index',
                              ),
                              scale: 0.90 + (activeProgress * 0.10),
                              child: Opacity(
                                key: ValueKey('bottom-nav-indicator-$index'),
                                opacity: activeProgress,
                                child: Container(
                                  width: indicatorWidth,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: _activeColor,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            _NavigationTapTarget(
                              key: ValueKey('bottom-nav-pressable-$index'),
                              label: item.label,
                              isSelected: isSelected,
                              reduceMotion: reduceMotion,
                              itemKey: ValueKey('bottom-nav-item-$index'),
                              pressScaleKey: ValueKey(
                                'bottom-nav-press-scale-$index',
                              ),
                              onTap: () => onSelected(index),
                              child: SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: Center(
                                  child: Transform.translate(
                                    offset: Offset(0, -activeProgress),
                                    child: Transform.scale(
                                      scale: 1 + (activeProgress * 0.045),
                                      child: _NavigationItemContent(
                                        icon: item.icon,
                                        label: item.label,
                                        color: foreground,
                                        activeProgress: activeProgress,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavigationTapTarget extends StatefulWidget {
  const _NavigationTapTarget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.reduceMotion,
    required this.itemKey,
    required this.pressScaleKey,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool isSelected;
  final bool reduceMotion;
  final Key itemKey;
  final Key pressScaleKey;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_NavigationTapTarget> createState() => _NavigationTapTargetState();
}

class _NavigationTapTargetState extends State<_NavigationTapTarget> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: widget.isSelected,
      button: true,
      label: widget.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: widget.itemKey,
          onTap: widget.onTap,
          onHighlightChanged: _setPressed,
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.focused)) {
              return const Color(0x142F67E8);
            }
            if (states.contains(WidgetState.hovered)) {
              return const Color(0x0A2F67E8);
            }
            return Colors.transparent;
          }),
          borderRadius: BorderRadius.circular(14),
          child: AnimatedScale(
            key: widget.pressScaleKey,
            scale: _isPressed ? 0.96 : 1,
            duration: widget.reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 80),
            curve: Curves.easeOutCubic,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class _NavigationItemContent extends StatelessWidget {
  const _NavigationItemContent({
    required this.icon,
    required this.label,
    required this.color,
    required this.activeProgress,
  });

  final IconData icon;
  final String label;
  final Color color;
  final double activeProgress;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.lerp(
              FontWeight.w600,
              FontWeight.w700,
              activeProgress,
            ),
          ),
        ),
      ],
    );
  }
}
