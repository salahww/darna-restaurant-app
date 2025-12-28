import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';

/// A reusable glassmorphic card with frosted glass effect
class GlassmorphicCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final Gradient? gradient;

  const GlassmorphicCard({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.1,
    this.color,
    this.borderRadius,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.elevation = 0,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: elevation > 0 
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05 * elevation),
                  blurRadius: 8 * elevation,
                  offset: Offset(0, 4 * elevation),
                )
              ] 
            : null,
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: color != null 
                  ? color!.withValues(alpha: opacity)
                  : AppColors.surface.withValues(alpha: opacity),
              gradient: gradient,
              borderRadius: effectiveBorderRadius,
              border: border ?? Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
