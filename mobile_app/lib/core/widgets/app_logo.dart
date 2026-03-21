import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final double padding;
  final Color backgroundColor;
  final double borderRadius;

  const AppLogo({
    super.key,
    this.size = 56,
    this.padding = 8,
    this.backgroundColor = const Color(0xFFEDF7EE),
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Image.asset(
        'assets/images/logo_agrotrack.png',
        fit: BoxFit.contain,
      ),
    );
  }
}