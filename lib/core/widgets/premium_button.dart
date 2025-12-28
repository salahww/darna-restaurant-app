import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

/// A premium button component with gradient background, press animations,
/// and loading state support.
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final IconData? icon;
  final Gradient? gradient;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const PremiumButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.icon,
    this.gradient,
    this.textColor,
    this.width,
    this.height = 56,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = widget.isEnabled
        ? (widget.gradient ?? AppColors.royalRedGradient)
        : LinearGradient(colors: [Colors.grey[300]!, Colors.grey[400]!]);

    return Semantics(
      button: true,
      enabled: widget.isEnabled,
      label: widget.text,
      onTap: widget.isEnabled ? widget.onPressed : null,
      child: GestureDetector(
        onTapDown: widget.isEnabled && !widget.isLoading ? (_) => _scaleController.forward() : null,
        onTapUp: widget.isEnabled && !widget.isLoading 
            ? (_) {
                _scaleController.reverse();
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: widget.isEnabled && !widget.isLoading ? () => _scaleController.reverse() : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: effectiveGradient,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: widget.isEnabled 
                  ? (widget.boxShadow ?? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ])
                  : [],
            ),
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: widget.textColor ?? Colors.white),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: GoogleFonts.dmSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: widget.textColor ?? Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
