// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// App Color System - Medical Theme
/// Based on medical blue/teal palette for healthcare apps
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS (Medical Blue)
  // ============================================================================
  
  /// Main brand color - Medical Blue
  static const Color primary = Color(0xFF2E7CF6);
  
  /// Darker shade of primary - for pressed states
  static const Color primaryDark = Color(0xFF1E5BC6);
  
  /// Lighter shade of primary - for hover states
  static const Color primaryLight = Color(0xFF5B9DF8);
  
  /// Very light primary - for backgrounds
  static const Color primaryVeryLight = Color(0xFFE8F2FF);

  // Gender Colors
static const Color maleLight = Color(0xFF60A5FA);      // Sky Blue
static const Color maleDark = Color(0xFF3B82F6);       // Blue

static const Color femaleLight = Color(0xFFF472B6);    // Pink
static const Color femaleDark = Color(0xFFEC4899);     // Hot Pink

  // ============================================================================
  // SECONDARY COLORS (Teal/Cyan)
  // ============================================================================
  
  /// Secondary brand color - Cyan/Teal
  static const Color secondary = Color(0xFF00BCD4);
  
  /// Darker shade of secondary
  static const Color secondaryDark = Color(0xFF0097A7);
  
  /// Lighter shade of secondary
  static const Color secondaryLight = Color(0xFF4FC3F7);
  
  /// Very light secondary - for backgrounds
  static const Color secondaryVeryLight = Color(0xFFE0F7FA);

  // ============================================================================
  // ACCENT COLORS
  // ============================================================================
  
  /// Accent color - Emerald Green (for health/vitality)
  static const Color accent = Color(0xFF06D6A0);
  
  /// Light accent
  static const Color accentLight = Color(0xFF40E0B8);

  // ============================================================================
  // STATUS COLORS (DR Classification)
  // ============================================================================
  
  /// Success - No DR / Healthy
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  /// Warning - Mild NPDR / Moderate NPDR
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  /// Danger - Severe NPDR / Proliferative DR
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFF87171);
  static const Color dangerDark = Color(0xFFDC2626);
  
  /// Info - General information
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================
  
  /// Main app background - Very light blue tint
  static const Color background = Color(0xFFF5F9FF);
  
  /// Surface color - Pure white
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Card background - Slightly tinted white
  static const Color cardBackground = Color(0xFFFAFCFF);
  
  /// Scaffold background
  static const Color scaffoldBackground = Color(0xFFF0F9FF);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Primary text color - Dark gray (almost black)
  static const Color textPrimary = Color(0xFF1A1A2E);
  
  /// Secondary text color - Medium gray
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Disabled text color - Light gray
  static const Color textDisabled = Color(0xFF9CA3AF);
  
  /// Text on primary color (white)
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Text on dark background
  static const Color textOnDark = Color(0xFFFFFFFF);

  // ============================================================================
  // BORDER & DIVIDER COLORS
  // ============================================================================
  
  /// Default border color
  static const Color border = Color(0xFFE5E7EB);
  
  /// Light border color
  static const Color borderLight = Color(0xFFF3F4F6);
  
  /// Divider color
  static const Color divider = Color(0xFFE5E7EB);
  
  /// Input border color (focused)
  static const Color inputBorderFocused = primary;
  
  /// Input border color (error)
  static const Color inputBorderError = danger;

  // ============================================================================
  // SHADOW COLORS
  // ============================================================================
  
  /// Light shadow for cards
  static Color shadowLight = primary.withValues(alpha: 0.08);
  
  /// Medium shadow for elevated elements
  static Color shadowMedium = primary.withValues(alpha: 0.12);
  
  /// Strong shadow for floating elements
  static Color shadowStrong = Colors.black.withValues(alpha: 0.08);
  
  /// Button shadow
  static Color shadowButton = primary.withValues(alpha: 0.25);

  

  // ============================================================================
  // OVERLAY COLORS
  // ============================================================================
  
  /// Black overlay
  static Color overlayBlack = Colors.black.withValues(alpha: 0.5);
  
  /// White overlay
  static Color overlayWhite = Colors.white.withValues(alpha: 0.8);
  
  /// Primary overlay (for loading states)
  static Color overlayPrimary = primary.withValues(alpha: 0.1);

  // ============================================================================
  // DR CLASSIFICATION COLORS (Helper Methods)
  // ============================================================================
  
  /// Get color based on DR classification (0-4)
  static Color getClassificationColor(int classification) {
    switch (classification) {
      case 0: // No DR
        return success;
      case 1: // Mild NPDR
        return warning;
      case 2: // Moderate NPDR
        return warningDark;
      case 3: // Severe NPDR
        return danger;
      case 4: // Proliferative DR
        return dangerDark;
      default:
        return textSecondary;
    }
  }
  
  /// Get light color variant based on DR classification
  static Color getClassificationLightColor(int classification) {
    switch (classification) {
      case 0: // No DR
        return successLight;
      case 1: // Mild NPDR
        return warningLight;
      case 2: // Moderate NPDR
        return warning;
      case 3: // Severe NPDR
        return dangerLight;
      case 4: // Proliferative DR
        return danger;
      default:
        return textDisabled;
    }
  }
  
  /// Get background color for classification badges
  static Color getClassificationBackgroundColor(int classification) {
    return getClassificationColor(classification).withValues(alpha: 0.1);
  }

  // ============================================================================
  // GENDER COLORS (For Patient Avatar)
  // ============================================================================
  

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  /// Lighten color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
  
  /// Darken color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}