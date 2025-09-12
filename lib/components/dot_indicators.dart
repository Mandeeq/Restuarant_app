import 'package:flutter/material.dart';
import '../theme.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.activeColor = primaryColor,
    this.inActiveColor = Colors.grey,
    this.size = 8.0,
    this.activeSize = 24.0,
    this.margin = const EdgeInsets.symmetric(horizontal: 4.0), Color? inactiveColor,
  });

  final bool isActive;
  final Color activeColor;
  final Color inActiveColor;
  final double size;
  final double activeSize;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kDefaultDuration,
      curve: Curves.easeInOut,
      margin: margin,
      height: size,
      width: isActive ? activeSize : size,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
          BoxShadow(
            color: activeColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
    );
  }
}