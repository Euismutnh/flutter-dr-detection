// lib/core/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';


/// Helper Utilities
/// Common utility functions used across the app
class Helpers {
  // ============================================================================
  // DATE & TIME FORMATTING
  // ============================================================================

  /// Format date to "dd MMM yyyy" (e.g., "15 Jan 2024")
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }

  /// Format date and time to "dd MMM yyyy, HH:mm" (e.g., "15 Jan 2024, 14:30")
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }

  /// Format date for API (YYYY-MM-DD)
  static String formatDateForApi(DateTime date) {
    return DateFormat(AppConstants.apiDateFormat).format(date);
  }

  /// Parse date from API format (YYYY-MM-DD)
  static DateTime? parseDateFromApi(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;

    try {
      return DateFormat(AppConstants.apiDateFormat).parse(dateString);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return null;
    }
  }

  /// Get relative time (e.g., "2 hours ago", "3 days ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Calculate age from date of birth
  static int calculateAge(DateTime dateOfBirth) {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;

    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }

  // ============================================================================
  // STRING MANIPULATION
  // ============================================================================

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Get initials from name (max 2 letters)
  static String getInitials(String name) {
    if (name.isEmpty) return '?';

    final words = name.trim().split(' ');

    if (words.length == 1) {
      // Single word - take first 2 characters
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    // Multiple words - take first letter of first two words
    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
  }

  /// Truncate text with ellipsis
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // ============================================================================
  // FILE SIZE FORMATTING
  // ============================================================================

  /// Format file size in bytes to human readable format
  static String formatFileSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  // ============================================================================
  // NUMBER FORMATTING
  // ============================================================================

  /// Format number with thousands separator (e.g., 1,234,567)
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  /// Format percentage (e.g., 85.5%)
  static String formatPercentage(double value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Format confidence score (e.g., 0.8567 -> 85.7%)
  static String formatConfidence(double confidence, {int decimals = 1}) {
    return formatPercentage(confidence * 100, decimals: decimals);
  }

  // ============================================================================
  // VALIDATION HELPERS
  // ============================================================================

  /// Check if string is valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email);
  }

  /// Check if string is valid phone number (Indonesian)
  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^08\d{8,13}$').hasMatch(phone);
  }

  // ============================================================================
  // UI HELPERS
  // ============================================================================

  /// Show snackbar
  static void showSnackbar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(
    BuildContext context,
    String message,
  ) {
    showSnackbar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(
    BuildContext context,
    String message,
  ) {
    showSnackbar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  /// Hide keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: confirmColor != null
                ? TextButton.styleFrom(foregroundColor: confirmColor)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  // ============================================================================
  // DEVICE INFO
  // ============================================================================

  /// Get screen width
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 600 && width < 1024;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenWidth(context) >= 1024;
  }

  // ============================================================================
  // COLOR HELPERS
  // ============================================================================

  /// Get color from hex string
  static Color colorFromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
  }

  static Color getClassificationColor(int classification) {
  switch (classification) {
    case 0:
      return AppColors.success;      // No DR - Green
    case 1:
      return AppColors.info;         // Mild - Blue
    case 2:
      return AppColors.warning;      // Moderate - Orange
    case 3:
      return const Color(0xFFFF6B6B); // Severe - Red Light
    case 4:
      return AppColors.danger;       // PDR - Red Dark
    default:
      return AppColors.textSecondary;
  }
  }
}
