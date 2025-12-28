import 'package:flutter/material.dart';
import 'package:darna/core/theme/app_theme.dart';

/// Theme-aware Darna logo widget that displays the appropriate logo
/// based on the current brightness (dark/light mode)
/// 
/// Now featuring Royal Red/Gold Moroccan branding
class DarnaLogo extends StatelessWidget {
  final double height;
  final bool useNewBranding;
  final bool animated;
  
  const DarnaLogo({
    super.key,
    this.height = 80,
    this.useNewBranding = true,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Choose logo based on branding preference
    final String logoPath;
    if (useNewBranding) {
      logoPath = isDark 
        ? 'assets/images/darna_logo_dark_red.png' 
        : 'assets/images/darna_logo_light_red.png';
    } else {
      logoPath = isDark 
        ? 'assets/images/darna_dark.png' 
        : 'assets/images/darna_light.png';
    }
    
    Widget logoWidget = Image.asset(
      logoPath,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Premium fallback if logo images are not found
        return _buildTextFallback(context);
      },
    );
    
    // Add entrance animation if requested
    if (animated) {
      logoWidget = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutBack,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: logoWidget,
      );
    }
    
    return logoWidget;
  }
  
  Widget _buildTextFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decorative element
          Container(
            width: 4,
            height: height * 0.6,
            decoration: BoxDecoration(
              gradient: AppColors.royalRedGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'DARNA',
            style: TextStyle(
              fontSize: height * 0.4,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
