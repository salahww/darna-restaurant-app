import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SnackBarType { success, error, warning, info }

class CustomSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    required SnackBarType type,
    String? title,
  }) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.hideCurrentSnackBar();

    Color backgroundColor;
    Color iconColor;
    IconData icon;
    String defaultTitle;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.success;
        iconColor = Colors.white;
        icon = Iconsax.tick_circle;
        defaultTitle = 'Success';
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.error;
        iconColor = Colors.white;
        icon = Iconsax.warning_2;
        defaultTitle = 'Error';
        break;
      case SnackBarType.warning:
        backgroundColor = AppColors.warning;
        iconColor = Colors.white;
        icon = Iconsax.warning_2;
        defaultTitle = 'Warning';
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.primary;
        iconColor = Colors.white;
        icon = Iconsax.info_circle;
        defaultTitle = 'Info';
        break;
    }

    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        duration: const Duration(seconds: 4),
        content: _SnackBarContent(
          message: message,
          type: type,
          title: title ?? defaultTitle,
          backgroundColor: backgroundColor,
          icon: icon,
          iconColor: iconColor,
        ),
      ),
    );
  }
}

class _SnackBarContent extends StatefulWidget {
  final String message;
  final String title;
  final SnackBarType type;
  final Color backgroundColor;
  final IconData icon;
  final Color iconColor;

  const _SnackBarContent({
    required this.message,
    required this.title,
    required this.type,
    required this.backgroundColor,
    required this.icon,
    required this.iconColor,
  });

  @override
  State<_SnackBarContent> createState() => _SnackBarContentState();
}

class _SnackBarContentState extends State<_SnackBarContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.backgroundColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOutBack);
  }
}
