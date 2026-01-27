// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import '../constants/spacing.dart';

/// App Theme Configuration
/// Complete theme setup for the entire app
class AppTheme {
  AppTheme._();

  /// Light Theme (Primary theme for medical app)
  static ThemeData lightTheme = ThemeData(
    // ===== BRIGHTNESS =====
    brightness: Brightness.light,
    
    // ===== COLOR SCHEME =====
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.danger,
      onPrimary: AppColors.textOnPrimary,
      onSecondary: AppColors.textOnPrimary,
      onSurface: AppColors.textPrimary,
      onError: Colors.white,
    ),
    
    // ===== TYPOGRAPHY =====
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.h1,
      headlineMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      titleLarge: AppTextStyles.h4,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),
    
    // ===== APP BAR THEME =====
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.textPrimary,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h3,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    // ===== CARD THEME =====
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.surface,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: Spacing.radiusXL,
      ),
      margin: EdgeInsets.zero,
    ),
    
    // ===== ELEVATED BUTTON THEME =====
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shadowColor: AppColors.shadowButton,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: Spacing.radiusXXL,
        ),
        textStyle: AppTextStyles.buttonLarge,
      ),
    ),
    
    // ===== TEXT BUTTON THEME =====
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        textStyle: AppTextStyles.labelMedium,
      ),
    ),
    
    // ===== OUTLINED BUTTON THEME =====
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: Spacing.radiusXXL,
        ),
        textStyle: AppTextStyles.buttonLarge,
      ),
    ),
    
    // ===== INPUT DECORATION THEME =====
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.cardBackground,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: Spacing.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: Spacing.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Spacing.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: Spacing.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: Spacing.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.danger,
          width: 2,
        ),
      ),
      labelStyle: AppTextStyles.labelMedium,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textDisabled,
      ),
      errorStyle: AppTextStyles.error,
    ),
    
    // ===== ICON THEME =====
    iconTheme: const IconThemeData(
      color: AppColors.textPrimary,
      size: 24,
    ),
    
    // ===== FLOATING ACTION BUTTON THEME =====
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // ===== BOTTOM NAVIGATION BAR THEME =====
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      selectedLabelStyle: AppTextStyles.labelSmall,
      unselectedLabelStyle: AppTextStyles.labelSmall,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),
    
    // ===== CHIP THEME =====
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.borderLight,
      deleteIconColor: AppColors.textSecondary,
      labelStyle: AppTextStyles.labelSmall,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: Spacing.radiusMD,
      ),
    ),
    
    // ===== DIALOG THEME =====
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: Spacing.radiusXL,
      ),
      titleTextStyle: AppTextStyles.h3,
      contentTextStyle: AppTextStyles.bodyMedium,
    ),
    
    // ===== BOTTOM SHEET THEME =====
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    ),
    
    // ===== SNACK BAR THEME =====
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: Colors.white,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: Spacing.radiusMD,
      ),
      behavior: SnackBarBehavior.floating,
    ),
    
    // ===== DIVIDER THEME =====
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    
    // ===== PROGRESS INDICATOR THEME =====
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
      linearTrackColor: AppColors.borderLight,
      circularTrackColor: AppColors.borderLight,
    ),
    
    // ===== SWITCH THEME =====
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textDisabled;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary.withValues(alpha: 0.5);
        }
        return AppColors.borderLight;
      }),
    ),
    
    // ===== CHECKBOX THEME =====
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    
    // ===== RADIO THEME =====
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primary;
        }
        return AppColors.textSecondary;
      }),
    ),
    
    // ===== SLIDER THEME =====
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.borderLight,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.2),
    ),
  );
}