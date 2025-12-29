import 'package:flutter/material.dart';

/// Nutrix App Color Palette - Green Energy Theme 🍃
/// Fresh & Natural Design for Nutrition App
class AppColors {
  // Light theme palette (matching TSX variables)
  static const Color primary = Color(0xFF5A7E8C); // --primary
  static const Color primaryLight = Color(0xFF8FB4BF); // softened
  static const Color primaryDark = Color(0xFF4A6B7A);

  static const Color secondary = Color(0xFF8FB4BF); // --secondary
  static const Color secondaryLight = Color(0xFFC9DADF);
  static const Color secondaryDark = Color(0xFF6B9FAE);

  static const Color accent = Color(0xFFC9DADF); // --accent
  static const Color accentLight = Color(0xFFE1ECEF);

  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444); // --destructive
  static const Color info = Color(0xFF3B82F6);

  // Nutrition colors (can reuse brand hues)
  static const Color protein = Color(0xFFEF4444);
  static const Color carbs = Color(0xFFF59E0B);
  static const Color fat = Color(0xFF5A7E8C);
  static const Color calories = Color(0xFF8FB4BF);

  // Background / surface light
  static const Color background = Color(0xFFF4F7F8); // --background
  static const Color backgroundDark = Color(0xFFE6EDF0);
  static const Color card = Color(0xFFFFFFFF); // --card
  static const Color cardLight = Color(0xFFF9FBFC);

  // Dark theme palette
  static const Color darkBackground = Color(0xFF1A2428); // --background (dark)
  static const Color darkCard = Color(0xFF2A3A3E); // --card (dark)
  static const Color darkCardLight = Color(0xFF313F44);
  static const Color darkSurface = Color(0xFF212E32);
  static const Color darkBorder = Color(0xFF3A4A4E);

  // Text light
  static const Color textPrimary = Color(0xFF2A3A3E); // --foreground
  static const Color textSecondary = Color(0xFF5A7E8C);
  static const Color textLight = Color(0xFF8FB4BF);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Text dark
  static const Color darkTextPrimary = Color(0xFFF4F7F8);
  static const Color darkTextSecondary = Color(0xFF8FB4BF);
  static const Color darkTextLight = Color(0xFFC9DADF);

  // Gradients updated to new palette
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF5A7E8C), Color(0xFF8FB4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF8FB4BF), Color(0xFFC9DADF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4A6B7A), Color(0xFF8FB4BF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient forestGradient = LinearGradient(
    colors: [Color(0xFF1A2428), Color(0xFF4A6B7A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFF8FB4BF), Color(0xFFC9DADF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// App Text Styles
class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  // Body Text
  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  // Caption & Small
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
    height: 1.4,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textWhite,
    letterSpacing: 0.5,
  );
  
  // Special
  static const TextStyle number = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    height: 1,
  );
}

/// App Spacing & Sizing
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double full = 999;
}

class AppShadow {
  static List<BoxShadow> small = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> medium = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> large = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
