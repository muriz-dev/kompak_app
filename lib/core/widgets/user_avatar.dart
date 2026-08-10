import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.size,
    this.borderColor = Colors.transparent,
    this.borderWidth = 0,
    this.backgroundColor = const Color(0xFFE7EEFF),
    this.foregroundColor = const Color(0xFF2F67E8),
  });

  final String name;
  final double size;
  final Color borderColor;
  final double borderWidth;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Avatar $name',
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initialsForName(name),
              key: const ValueKey('user-avatar-initials'),
              style: TextStyle(
                color: foregroundColor,
                fontSize: size * 0.34,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String initialsForName(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) return '?';

  final first = parts.first.substring(0, 1);
  final last = parts.length > 1 ? parts.last.substring(0, 1) : '';
  return '$first$last'.toUpperCase();
}
