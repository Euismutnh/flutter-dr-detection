// lib/core/utils/greeting_helper.dart

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../constants/app_constants.dart';

/// Greeting Helper
///
/// Provides greeting messages and professional titles based on:
/// - Time of day (morning, afternoon, evening, night)
/// - User's profession
/// - User's gender (for non-medical professionals)
///
/// Usage:
/// ```dart
/// final greeting = GreetingHelper.getGreeting(context);
/// final title = GreetingHelper.getProfessionalTitle(context, profession, gender);
/// final fullGreeting = GreetingHelper.getFullGreeting(context, name, profession, gender);
/// ```
class GreetingHelper {
  GreetingHelper._();

  // ============================================================================
  // TIME-BASED GREETING
  // ============================================================================

  /// Get greeting based on current time
  ///
  /// Returns localized greeting:
  /// - 05:00 - 11:59 → Good Morning
  /// - 12:00 - 14:59 → Good Afternoon
  /// - 15:00 - 17:59 → Good Evening
  /// - 18:00 - 04:59 → Good Night
  static String getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return l10n.greetingMorning;
    } else if (hour >= 12 && hour < 15) {
      return l10n.greetingAfternoon;
    } else if (hour >= 15 && hour < 18) {
      return l10n.greetingEvening;
    } else {
      return l10n.greetingNight;
    }
  }

  // ============================================================================
  // PROFESSIONAL TITLE
  // ============================================================================

  /// Get professional title based on profession and gender
  ///
  /// Logic:
  /// - Ophthalmologist, Endocrinologist, General Practitioner → "Dr." / "dr."
  /// - Nurse → "Nurse" (EN) / "Ners" (ID)
  /// - Other professions → Gender-based: "Mr./Ms." (EN) / "Tn./Ny." (ID)
  ///
  /// Parameters:
  /// - profession: User's profession (from UserModel.profession)
  /// - gender: User's gender (optional, used for non-medical)
  ///
  /// Returns: Professional title string
  static String getProfessionalTitle(
    BuildContext context,
    String? profession,
    String? gender,
  ) {
    final l10n = AppLocalizations.of(context);

    if (profession == null || profession.isEmpty) {
      return _getGenderTitle(l10n, gender);
    }

    // Doctor professions
    final doctorProfessions = [
      'Ophthalmologist',
      'Endocrinologist',
      'General Practitioner',

      'Dokter Mata',
      'Dokter Spesialis Endokrin',
      'Dokter Umum', 
    ];

    if (doctorProfessions.contains(profession)) {
      return l10n.titleDr; // "Dr." or "dr."
    }

    // Nurse profession
    if (profession == 'Nurse') {
      return l10n.titleNurse; // "Nurse" or "Ners"
    }

    // Other professions - use gender-based title
    return _getGenderTitle(l10n, gender);
  }

  /// Get gender-based title (Mr./Ms. or Tn./Ny.)
  static String _getGenderTitle(AppLocalizations l10n, String? gender) {
    if (gender == null || gender.isEmpty) {
      return ''; // No title if gender unknown
    }

    if (gender.toLowerCase() == 'male') {
      return l10n.titleMr; // "Mr." or "Tn."
    } else if (gender.toLowerCase() == 'female') {
      return l10n.titleMs; // "Ms." or "Ny."
    }

    return '';
  }

  // ============================================================================
  // FULL GREETING
  // ============================================================================

  /// Get full greeting with time-based greeting and professional title
  ///
  /// Format: "Good Morning, Dr. John Doe"
  ///
  /// Parameters:
  /// - name: User's full name
  /// - profession: User's profession
  /// - gender: User's gender (optional)
  ///
  /// Returns: Full greeting string
  static String getFullGreeting(
    BuildContext context,
    String name, {
    String? profession,
    String? gender,
  }) {
    final greeting = getGreeting(context);
    final title = getProfessionalTitle(context, profession, gender);

    // Build name with title
    final displayName = title.isNotEmpty ? '$title $name' : name;

    return '$greeting,\n$displayName';
  }

  /// Get greeting line only (without name)
  ///
  /// Use when you want to display greeting and name separately
  static String getGreetingLine(BuildContext context) {
    return '${getGreeting(context)},';
  }

  /// Get display name with title
  ///
  /// Returns: "Dr. John Doe" or just "John Doe" if no title
  static String getDisplayNameWithTitle(
    BuildContext context,
    String name, {
    String? profession,
    String? gender,
  }) {
    final title = getProfessionalTitle(context, profession, gender);
    return title.isNotEmpty ? '$title $name' : name;
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Check if profession qualifies for "Dr." title
  static bool isDoctorProfession(String? profession) {
    if (profession == null) return false;

    return [
      'Ophthalmologist',
      'Endocrinologist',
      'General Practitioner',
    ].contains(profession);
  }

  /// Check if profession is Nurse
  static bool isNurseProfession(String? profession) {
    return profession == 'Nurse';
  }

  /// Check if profession is medical (doctor or nurse)
  static bool isMedicalProfession(String? profession) {
    return isDoctorProfession(profession) || isNurseProfession(profession);
  }

  /// Get profession display name (localized)
  static String getProfessionDisplayName(
    BuildContext context,
    String? profession,
  ) {
    if (profession == null || profession.isEmpty) return '';
    return AppConstants.getProfessionLabel(context, profession);
  }
}
