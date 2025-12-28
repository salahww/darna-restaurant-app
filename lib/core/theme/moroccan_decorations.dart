import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';

/// Moroccan-inspired decorations and premium effects
class MoroccanDecorations {
  MoroccanDecorations._();

  // ========== GLASSMORPHIC EFFECTS ==========

  /// Frosted glass decoration for cards
  static BoxDecoration glassmorphic({
    double blurAmount = 10.0,
    double opacity = 0.1,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool showBorder = true,
  }) {
    return BoxDecoration(
      color: (backgroundColor ?? Colors.white).withValues(alpha: opacity),
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: showBorder
          ? Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Glassmorphic container with backdrop blur
  static Widget glassmorphicContainer({
    required Widget child,
    double blurAmount = 10.0,
    double opacity = 0.1,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: glassmorphic(
            blurAmount: blurAmount,
            opacity: opacity,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }

  // ========== MOROCCAN-THEMED BORDERS ==========

  /// Subtle gold border accent
  static BoxDecoration goldBorder({
    double width = 1.5,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 0.3),
        width: width,
      ),
    );
  }

  /// Premium double border (Moroccan zellige-inspired)
  static BoxDecoration premiumDoubleBorder({
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 0.2),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ========== PREMIUM GRADIENTS ==========

  /// Red to burgundy gradient (for buttons, headers)
  static BoxDecoration premiumGradient({
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      gradient: AppColors.royalRedGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      boxShadow: shadows ??
          [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
    );
  }

  /// Gold gradient (for premium accents)
  static BoxDecoration goldGradient({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      gradient: AppColors.royalGoldGradient,
      borderRadius: borderRadius ?? BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.secondary.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ========== CARD SHADOWS ==========

  /// Warm-toned shadow for cards
  static List<BoxShadow> cardShadow({double elevation = 1.0}) {
    return [
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.06 * elevation),
        blurRadius: 8 * elevation,
        offset: Offset(0, 2 * elevation),
      ),
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.04 * elevation),
        blurRadius: 16 * elevation,
        offset: Offset(0, 4 * elevation),
      ),
    ];
  }

  /// Premium glow shadow (for highlighted elements)
  static List<BoxShadow> premiumGlow({Color? color}) {
    return [
      BoxShadow(
        color: (color ?? AppColors.primary).withValues(alpha: 0.3),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
  }

  /// Gold glow effect
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: AppColors.secondary.withValues(alpha: 0.35),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  // ========== PREMIUM CARD DECORATIONS ==========

  /// Premium card with subtle red glow
  static BoxDecoration premiumCard({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    bool withGlow = false,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      boxShadow: withGlow ? premiumGlow() : cardShadow(),
    );
  }

  /// Featured card (highlighted products, banners)
  static BoxDecoration featuredCard({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: AppColors.secondary.withValues(alpha: 0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.secondary.withValues(alpha: 0.15),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // ========== OVERLAY DECORATIONS ==========

  /// Dark overlay for images with text
  static BoxDecoration imageOverlay({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      gradient: AppColors.darkOverlay,
    );
  }

  /// Warm tint overlay (for Moroccan aesthetic)
  static BoxDecoration warmTintOverlay({
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      borderRadius: borderRadius,
      gradient: LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withValues(alpha: 0.15),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }
}
