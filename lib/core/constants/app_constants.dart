// lib/core/constants/app_constants.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class AppConstants {
  AppConstants._();

  // ============================================================================
  // APP INFO
  // ============================================================================
  static const String appName = 'DR Detection';
  static const String appVersion = '1.0.0';

  // ============================================================================
  // STORAGE KEYS
  // ============================================================================
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserData = 'user_data';
  static const String keyIsLoggedIn = 'is_logged_in';

  // ============================================================================
  // DROPDOWN OPTIONS (Match Backend Validation)
  // ============================================================================
  static const List<String> genderOptions = ['Male', 'Female'];
  static const List<String> sideEyeOptions = ['Right', 'Left'];

  static const List<String> professionOptions = [
  'Ophthalmologist',        // Dokter Mata (Sp.M)
  'Endocrinologist',        // Dokter Penyakit Dalam/Endokrin (Sp.PD)
  'General Practitioner',   // Dokter Umum
  'Optometrist',            // Optometris (Ahli Refraksi)
  'Nurse',                  // Perawat/Ners
  'Medical Student',        // Mahasiswa Kedokteran
  'Healthcare Assistant',   // Asisten Medis
  'Other',
];

static String getProfessionLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    
    switch (key) {
      case 'Ophthalmologist': return l10n.profOphthalmologist;
      case 'Endocrinologist': return l10n.profEndocrinologist;
      case 'General Practitioner': return l10n.profGeneralPractitioner;
      case 'Optometrist': return l10n.profOptometrist;
      case 'Nurse': return l10n.profNurse;
      case 'Medical Student': return l10n.profMedicalStudent;
      case 'Healthcare Assistant': return l10n.profHealthcareAssistant;
      case 'Other': return l10n.profOther;
      default: return key; 
    }
  }

  // ============================================================================
  // DR CLASSIFICATIONS
  // ============================================================================
  static const Map<int, String> drClassifications = {
    0: 'No DR',
    1: 'Mild NPDR',
    2: 'Moderate NPDR',
    3: 'Severe NPDR',
    4: 'Proliferative DR',
  };

  // ============================================================================
  // PERIOD FILTER (untuk detection history)
  // ============================================================================
  static const List<String> periodOptions = [
    'last_7_days',
    'last_1_month',
    'last_3_months',
    'last_6_months',
    'last_1_year',
  ];

  static const Map<String, String> periodLabels = {
    'last_7_days': 'Last 7 Days',
    'last_1_month': 'Last Month',
    'last_3_months': 'Last 3 Months',
    'last_6_months': 'Last 6 Months',
    'last_1_year': 'Last Year',
  };

  // ============================================================================
  // VALIDATION RULES (Match Backend)
  // ============================================================================
  static const int minPasswordLength = 8;
  static const int otpLength = 6;
  static const int otpExpiryMinutes = 5;
  static const int minPatientCodeLength = 3;
  static const int maxPatientCodeLength = 50;

  static final RegExp passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
  static final RegExp otpRegex = RegExp(r'^\d{6}$');
  static final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp phoneRegex = RegExp(r'^08\d{8,13}$');

  // ============================================================================
  // FILE UPLOAD LIMITS
  // ============================================================================
  static const int maxImageSizeMB = 5;
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  // Backend accepted (after conversion)
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedImageMimeTypes = ['image/jpeg', 'image/png'];

  // Frontend supported (includes TIFF & DICOM - will auto-convert)
  static const List<String> supportedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'tif',
    'tiff'
  ];

  // ============================================================================
  // OTHER SETTINGS
  // ============================================================================
  static const int sessionTimeoutMinutes = 15;
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ============================================================================
  // DATE FORMATS
  // ============================================================================
  static const String dateFormat = 'dd MMM yyyy';
  static const String dateTimeFormat = 'dd MMM yyyy, HH:mm';
  static const String apiDateFormat = 'yyyy-MM-dd';

  // // ============================================================================
  // // ERROR MESSAGES
  // // ============================================================================
  // static const String errorNetwork =
  //     'No internet connection. Please check your network.';
  // static const String errorServer = 'Server error. Please try again later.';
  // static const String errorUnknown = 'An unexpected error occurred.';
  // static const String errorInvalidEmail = 'Invalid email format.';
  // static const String errorInvalidPhone =
  //     'Phone must start with 08 (10-15 digits).';
  // static const String errorInvalidPassword =
  //     'Password must be at least 8 characters with letter and number.';
  // static const String errorInvalidOtp = 'OTP must be 6 digits.';
  // static const String errorTokenExpired =
  //     'Session expired. Please login again.';
  // static const String errorTokenRevoked =
  //     'Session revoked. Please login again.';
  // static const String errorImageTooLarge = 'Image size exceeds 5MB limit.';
  // static const String errorUnsupportedFormat = 'Unsupported image format.';

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  static String getDrLabel(int classification) =>
      drClassifications[classification] ?? 'Unknown';

  static String getPeriodLabel(String period) => periodLabels[period] ?? period;

  static bool isValidEmail(String email) => emailRegex.hasMatch(email.trim());
  static bool isValidPhone(String phone) => phoneRegex.hasMatch(phone.trim());
  static bool isValidPassword(String password) =>
      password.length >= minPasswordLength && passwordRegex.hasMatch(password);
  static bool isValidOtp(String otp) => otpRegex.hasMatch(otp.trim());

  static bool isImageSizeValid(int sizeInBytes) =>
      sizeInBytes <= maxImageSizeBytes;
  static bool isImageExtensionAllowed(String ext) =>
      allowedImageExtensions.contains(ext.toLowerCase());
  static bool isImageExtensionSupported(String ext) =>
      supportedImageExtensions.contains(ext.toLowerCase());
  static bool needsConversion(String ext) {
    final e = ext.toLowerCase();
    return e == 'tif' || e == 'tiff';
  }

  /// Supported languages
  static const List<String> supportedLanguages = ['en', 'id'];

  /// Language names
  static const Map<String, String> languageNames = {
    'en': 'English',
    'id': 'Bahasa Indonesia',
  };

  /// Default language
  static const String defaultLanguage = 'en';

  /// SharedPrefs key for language
  static const String keySelectedLanguage = 'selected_language';
}
