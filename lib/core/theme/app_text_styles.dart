// lib/core/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// App Typography System
/// Consistent text styles across the app using Plus Jakarta Sans font
/// 
/// Requirements in pubspec.yaml:
/// dependencies:
///   google_fonts: ^6.1.0
class AppTextStyles {
  // Private constructor
  AppTextStyles._();

  // Base font family
  static const String fontFamily = 'Plus Jakarta Sans';

  // ============================================================================
  // DISPLAY STYLES (Large titles, hero text)
  // ============================================================================
  
  /// Display Large - 40px, Bold
  /// Usage: Splash screen, main hero titles
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 40,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Display Medium - 36px, Bold
  /// Usage: Page titles, section headers
  static TextStyle displayMedium = GoogleFonts.plusJakartaSans(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  /// Display Small - 32px, SemiBold
  /// Usage: Card titles, emphasized text
  static TextStyle displaySmall = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.25,
  );

  // ============================================================================
  // HEADING STYLES (Section titles)
  // ============================================================================
  
  /// Heading 1 - 28px, SemiBold
  /// Usage: Screen titles, main sections
  static TextStyle h1 = GoogleFonts.plusJakartaSans(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Heading 2 - 24px, SemiBold
  /// Usage: Sub-sections, card headers
  static TextStyle h2 = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  /// Heading 3 - 20px, SemiBold
  /// Usage: Small sections, list headers
  static TextStyle h3 = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );
  
  /// Heading 4 - 18px, Medium
  /// Usage: Inline headings
  static TextStyle h4 = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ============================================================================
  // BODY STYLES (Content text)
  // ============================================================================
  
  /// Body Large - 16px, Regular
  /// Usage: Main content, descriptions
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Medium - 14px, Regular
  /// Usage: Secondary content, list items
  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
  
  /// Body Small - 12px, Regular
  /// Usage: Helper text, metadata
  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ============================================================================
  // LABEL STYLES (Form labels, buttons)
  // ============================================================================
  
  /// Label Large - 16px, SemiBold
  /// Usage: Large buttons, important labels
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Label Medium - 14px, SemiBold
  /// Usage: Regular buttons, form labels
  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  /// Label Small - 12px, Medium
  /// Usage: Small buttons, tags, badges
  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  // ============================================================================
  // CAPTION STYLES (Small text, metadata)
  // ============================================================================
  
  /// Caption - 12px, Regular
  /// Usage: Timestamps, subtitles, helper text
  static TextStyle caption = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle caption2 = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Caption Bold - 12px, SemiBold
  /// Usage: Emphasized captions
  static TextStyle captionBold = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  /// Overline - 10px, SemiBold, Uppercase
  /// Usage: Tags, labels, categories
  static TextStyle overline = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 1.5,
  );

  // ============================================================================
  // BUTTON TEXT STYLES
  // ============================================================================
  
  /// Button Large - 16px, Bold
  static TextStyle buttonLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Button Medium - 14px, SemiBold
  static TextStyle buttonMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  /// Button Small - 12px, SemiBold
  static TextStyle buttonSmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    height: 1.2,
    letterSpacing: 0.5,
  );

  // ============================================================================
  // SPECIALIZED STYLES
  // ============================================================================
  
  /// Link text - 14px, SemiBold, Primary color
  static TextStyle link = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.5,
    decoration: TextDecoration.underline,
  );
  
  /// Error text - 12px, Medium, Danger color
  static TextStyle error = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.danger,
    height: 1.4,
  );
  
  /// Success text - 12px, Medium, Success color
  static TextStyle success = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.success,
    height: 1.4,
  );
  
  /// Warning text - 12px, Medium, Warning color
  static TextStyle warning = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.warning,
    height: 1.4,
  );

  // ============================================================================
  // NUMBER/METRIC STYLES (For statistics)
  // ============================================================================
  
  /// Metric Large - 48px, Bold
  /// Usage: Large statistics, confidence percentages
  static TextStyle metricLarge = GoogleFonts.plusJakartaSans(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
  );
  
  /// Metric Medium - 32px, Bold
  /// Usage: Card statistics, counts
  static TextStyle metricMedium = GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.0,
  );
  
  /// Metric Small - 24px, SemiBold
  /// Usage: Small numbers, badges
  static TextStyle metricSmall = GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.0,
  );

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Apply color to any text style
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Apply weight to any text style
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Make text style white (for dark backgrounds)
  static TextStyle toWhite(TextStyle style) {
    return style.copyWith(color: AppColors.textOnDark);
  }
  
  /// Make text style primary color
  static TextStyle toPrimary(TextStyle style) {
    return style.copyWith(color: AppColors.primary);
  }
  
  /// Make text style secondary color
  static TextStyle toSecondary(TextStyle style) {
    return style.copyWith(color: AppColors.textSecondary);
  }
  
  /// Apply gradient to text (requires ShaderMask wrapper)
  /// Example usage:
  /// ```dart
  /// ShaderMask(
  ///   shaderCallback: AppTextStyles.applyGradient(AppGradients.primary),
  ///   child: Text('Gradient Text', style: AppTextStyles.displayLarge),
  /// )
  /// ```
  static ShaderCallback applyGradient(Gradient gradient) {
    return (Rect bounds) => gradient.createShader(bounds);
  }
}