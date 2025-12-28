import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium Royal Moroccan Design System
/// 5-Star Restaurant App Theme
class AppTheme {
  AppTheme._();

  /// Light Theme - Luxury Day Experience
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.deepTeal,
      secondary: AppColors.richGold,
      tertiary: AppColors.burgundy,
      surface: AppColors.warmWhite,
      surfaceContainerHighest: AppColors.cream,
      error: AppColors.error,
      onPrimary: AppColors.warmWhite,
      onSecondary: AppColors.charcoal,
      onSurface: AppColors.charcoal,
      onError: AppColors.warmWhite,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.background,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.warmWhite,
      foregroundColor: AppColors.charcoal,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
        letterSpacing: -0.5,
      ),
      iconTheme: const IconThemeData(color: AppColors.charcoal),
    ),
    
    // Card Theme
    cardColor: AppColors.warmWhite,
    cardTheme: CardThemeData(
      color: AppColors.warmWhite,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepTeal,
        foregroundColor: AppColors.cream,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.deepTeal,
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.warmWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.slate.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.slate.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deepTeal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.dmSans(
        color: AppColors.slate,
        fontSize: 16,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.richGold.withOpacity(0.1),
      labelStyle: GoogleFonts.dmSans(
        color: AppColors.deepTeal,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Typography
    textTheme: _buildTextTheme(Brightness.light),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.richGold.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
  );

  /// Dark Theme - Luxury Night Experience
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.deepTealDark,
      secondary: AppColors.richGoldDark,
      tertiary: AppColors.burgundyDark,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkBackground,
      error: AppColors.error,
      onPrimary: AppColors.lightText,
      onSecondary: AppColors.charcoal,
      onSurface: AppColors.lightText,
      onError: AppColors.lightText,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: AppColors.darkBackground,
    
    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.lightText,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.dmSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightText,
        letterSpacing: -0.5,
      ),
    ),
    
    // Card Theme
    cardColor: AppColors.darkSurface,
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.deepTealDark,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryText.withOpacity(0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.deepTealDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.dmSans(
        color: AppColors.secondaryText,
        fontSize: 16,
      ),
    ),
    
    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.richGoldDark.withOpacity(0.15),
      labelStyle: GoogleFonts.dmSans(
        color: AppColors.richGoldDark,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Typography
    textTheme: _buildTextTheme(Brightness.dark),
    
    // Divider
    dividerTheme: DividerThemeData(
      color: AppColors.richGoldDark.withOpacity(0.2),
      thickness: 1,
      space: 24,
    ),
  );

  /// Build Premium Typography System (DM Sans)
  /// Modern, Geometric, Humanist - High Legibility & Premium Feel
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseColor = brightness == Brightness.light 
        ? AppColors.charcoal 
        : AppColors.lightText;
    final secondaryColor = brightness == Brightness.light 
        ? AppColors.slate 
        : AppColors.secondaryText;

    return TextTheme(
      // Display - Hero headings
      displayLarge: GoogleFonts.dmSans(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -1.5,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.dmSans(
        fontSize: 44,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -1.0,
        height: 1.1,
      ),
      displaySmall: GoogleFonts.dmSans(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      
      // Headings - Section titles
      headlineLarge: GoogleFonts.dmSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -1.0,
        height: 1.2,
      ),
      headlineMedium: GoogleFonts.dmSans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      
      // Titles - Card titles, List items
      titleLarge: GoogleFonts.dmSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 0.0,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: baseColor,
        letterSpacing: 0.1,
      ),
      
      // Body - Paragraphs
      bodyLarge: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      bodyMedium: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: baseColor,
        height: 1.5,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
        height: 1.5,
        letterSpacing: 0.4,
      ),
      
      // Labels - Buttons, Overlines
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 1.0, // Uppercase style often used
      ),
      labelMedium: GoogleFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: 1.0,
      ),
      labelSmall: GoogleFonts.dmSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: secondaryColor,
        letterSpacing: 1.0,
      ),
    );
  }

  /// Premium Price Text Style
  static TextStyle priceStyle({
    required Brightness brightness,
    double fontSize = 28,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    final color = brightness == Brightness.light 
        ? AppColors.primary 
        : AppColors.lightText;
    
    return GoogleFonts.dmSans(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: -0.5,
    );
  }
}

/// Royal Moroccan Red Color Palette
/// Premium Moroccan-inspired design system
class AppColors {
  AppColors._();

  // ========== LIGHT MODE COLORS ==========
  
  /// Primary - Royal Moroccan Red (Moroccan flag inspired)
  static const Color primary = Color(0xFFC1272D);
  
  /// Primary Dark - Deep Burgundy
  static const Color primaryDark = Color(0xFF8B1A1A);
  
  /// Primary Light - Soft Red
  static const Color primaryLight = Color(0xFFE85B5B);
  
  /// Secondary - Royal Gold
  static const Color secondary = Color(0xFFD4AF37);
  
  /// Secondary Dark - Antique Gold
  static const Color secondaryDark = Color(0xFFB8960C);
  
  /// Background - Simple White (Requested)
  static const Color background = Color(0xFFFFFFFF);
  
  /// Surface - Pure White
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Text Primary - Rich Charcoal
  static const Color textPrimary = Color(0xFF2C1810);
  
  /// Text Secondary - Warm Gray
  static const Color textSecondary = Color(0xFF6B5B4D);
  
  /// Divider - Warm Light Gray
  static const Color divider = Color(0xFFE8E0D8);

  // ========== DARK MODE COLORS ==========
  
  /// Primary Dark Mode - Bright Red
  static const Color primaryDarkMode = Color(0xFFE63946);
  
  /// Background Dark - Near Black (Requested #161618)
  static const Color backgroundDark = Color(0xFF161618);
  
  /// Surface Dark - Rich Dark Gray
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  /// Text Primary Dark - Warm White
  static const Color textPrimaryDark = Color(0xFFEAEAEA);
  
  /// Text Secondary Dark - Muted Gold
  static const Color textSecondaryDark = Color(0xFFD4AF37);

  // ========== SEMANTIC COLORS ==========
  
  /// Success - Moroccan Mint Green
  static const Color success = Color(0xFF2E7D32);
  
  /// Warning - Amber/Saffron
  static const Color warning = Color(0xFFE6A23C);
  
  /// Error - Deep Red
  static const Color error = Color(0xFFDC3545);
  
  /// Info - Cool Blue
  static const Color info = Color(0xFF1976D2);
  
  /// Rating Star - Gold
  static const Color star = Color(0xFFD4AF37);

  // ========== LEGACY ALIASES (for compatibility) ==========
  static const Color deepTeal = primary;
  static const Color richGold = secondary;
  static const Color burgundy = primaryDark;
  static const Color cream = background;
  static const Color warmWhite = surface;
  static const Color charcoal = textPrimary;
  static const Color slate = textSecondary;
  static const Color deepTealDark = primaryDarkMode;
  static const Color richGoldDark = secondary;
  static const Color burgundyDark = primaryDark;
  static const Color darkBackground = backgroundDark;
  static const Color darkSurface = surfaceDark;
  static const Color lightText = textPrimaryDark;
  static const Color secondaryText = textSecondaryDark;

  // ========== GRADIENTS ==========
  
  /// Royal Red Gradient (Primary gradient)
  static const LinearGradient royalRedGradient = LinearGradient(
    colors: [Color(0xFFC1272D), Color(0xFF8B1A1A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Royal Gold Gradient
  static const LinearGradient royalGoldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFB8960C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Red to Gold Gradient (Premium accent)
  static const LinearGradient redGoldGradient = LinearGradient(
    colors: [Color(0xFFC1272D), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Gold Gradient (legacy alias - now uses royal gold)
  static const LinearGradient goldGradient = royalGoldGradient;
  
  /// Orange Gradient (legacy alias - now uses royal red)
  static const LinearGradient orangeGradient = royalRedGradient;
  
  /// Teal Gradient (legacy alias)
  static const LinearGradient tealGradient = royalRedGradient;
  
  /// Dark Overlay
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC1A1517)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.4, 1.0],
  );
  
  /// Warm Light Overlay (for cards)
  static const LinearGradient warmOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0x33C1272D)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

/// Premium Shadow Definitions
class AppShadows {
  AppShadows._();

  /// Subtle elevation
  static List<BoxShadow> elevation1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  /// Medium elevation
  static List<BoxShadow> elevation2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  /// High elevation
  static List<BoxShadow> elevation3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  /// Premium elevation (for important elements)
  static List<BoxShadow> elevation4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 48,
      offset: const Offset(0, 16),
    ),
  ];

  /// Gold glow effect
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: AppColors.richGold.withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

/// Design System Constants
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 9999.0;
}
