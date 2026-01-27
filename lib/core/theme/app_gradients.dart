// lib/core/theme/app_gradients.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Gradient System
/// Pre-defined gradients for consistent UI across the app
class AppGradients {
  // Private constructor
  AppGradients._();

  // ============================================================================
  // PRIMARY GRADIENTS (Medical Blue → Cyan)
  // ============================================================================
  
  /// Primary gradient - Blue to Cyan (for buttons, headers)
  /// Usage: Buttons, CTAs, Primary actions
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E7CF6), // Primary Blue
      Color(0xFF00BCD4), // Cyan
    ],
  );
  
  /// Primary gradient (vertical orientation)
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2E7CF6),
      Color(0xFF00BCD4),
    ],
  );
  
  /// Primary gradient (horizontal orientation)
  static const LinearGradient primaryHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF2E7CF6),
      Color(0xFF00BCD4),
    ],
  );


  // ============================================================================
  // BACKGROUND GRADIENTS
  // ============================================================================
  
  /// Soft background gradient - For screen backgrounds
  /// Light blue tints from top to bottom
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF0F9FF), // Sky-50
      Color(0xFFE0F2FE), // Sky-100
      Color(0xFFBAE6FD), // Sky-200
    ],
  );
  
  /// Login/Splash background gradient
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE0F2FE), // Light blue
      Color(0xFFDDD6FE), // Light purple tint
      Color(0xFFFCE7F3), // Light pink tint
    ],
  );
  
  /// Card shimmer gradient (for loading states)
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment(-1.0, -0.5),
    end: Alignment(1.0, 0.5),
    colors: [
      Color(0xFFE5E7EB),
      Color(0xFFF3F4F6),
      Color(0xFFE5E7EB),
    ],
  );

  // ============================================================================
  // STATUS GRADIENTS (DR Classification)
  // ============================================================================
  
  /// Success gradient - No DR (Green)
  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Emerald 500
      Color(0xFF34D399),  // Emerald-400
    ],
  );
  
  /// Warning gradient - Mild/Moderate NPDR (Orange/Amber)
  static const LinearGradient warning = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Amber-500
      Color(0xFFFBBF24), // Amber-400
    ],
  );
  
  /// Danger gradient - Severe/Proliferative DR (Red)
  static const LinearGradient danger = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF4444), // Red-500
      Color(0xFFF87171), // Red-400
    ],
  );
  
  /// Info gradient - General information (Blue)
  static const LinearGradient info = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), // Blue-500
      Color(0xFF60A5FA), // Blue-400
    ],
  );
  // Gender Gradients for Avatars
  static const LinearGradient male = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)], // Blue gradient
  );

  static const LinearGradient female = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)], // Pink gradient
  );

  // ============================================================================
  // ACCENT GRADIENTS
  // ============================================================================
  
  /// Teal gradient - For secondary actions
  static const LinearGradient teal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF06D6A0), // Teal
      Color(0xFF40E0B8), // Light Teal
    ],
  );
  
  /// Purple gradient - For premium/special features
  static const LinearGradient purple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B5CF6), // Purple-500
      Color(0xFFA78BFA), // Purple-400
    ],
  );

  // ============================================================================
  // OVERLAY GRADIENTS
  // ============================================================================
  
  /// Dark overlay - For image overlays
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0x99000000), // 60% black
    ],
  );
  
  /// Light overlay - For glassmorphism effects
  static const LinearGradient lightOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Color(0x1AFFFFFF), // 10% white
    ],
  );

  // ============================================================================
  // SPECIAL GRADIENTS
  // ============================================================================
  
  /// Rainbow gradient - For progress indicators
  static const LinearGradient rainbow = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF10B981), // Green
      Color(0xFFF59E0B), // Yellow
      Color(0xFFEF4444), // Red
    ],
  );
  
  /// Glassmorphism gradient - For card backgrounds
  static LinearGradient glassmorphism = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Colors.white.withValues(alpha: 0.7),
      Colors.white.withValues(alpha: 0.3),
    ],
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get gradient based on DR classification (0-4)
  static LinearGradient getClassificationGradient(int classification) {
    switch (classification) {
      case 0: // No DR
        return success;
      case 1: // Mild NPDR
        return warning;
      case 2: // Moderate NPDR
        return warning;
      case 3: // Severe NPDR
        return danger;
      case 4: // Proliferative DR
        return danger;
      default:
        return LinearGradient(
          colors: [AppColors.textSecondary, AppColors.textDisabled],
        );
    }
  }
  
  /// Create custom gradient from two colors
  static LinearGradient custom({
    required Color startColor,
    required Color endColor,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: [startColor, endColor],
    );
  }
  
  /// Create radial gradient
  static RadialGradient radial({
    required Color centerColor,
    required Color edgeColor,
    AlignmentGeometry center = Alignment.center,
    double radius = 0.5,
  }) {
    return RadialGradient(
      center: center,
      radius: radius,
      colors: [centerColor, edgeColor],
    );
  }
}