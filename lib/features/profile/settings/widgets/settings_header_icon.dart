import 'package:flutter/material.dart';

class SettingsHeaderIcon extends StatelessWidget {
  final IconData icon;

  const SettingsHeaderIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3A2A1F) : const Color(0xFFFFF1E8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Theme.of(context).primaryColor, size: 40),
    );
  }
}
