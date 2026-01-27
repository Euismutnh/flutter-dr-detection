// lib/core/utils/validators.dart
import '../../core/constants/app_constants.dart';

/// Form Validators
/// Reusable validation functions untuk semua forms
class Validators {
  // ============================================================================
  // EMAIL VALIDATION
  // ============================================================================

  /// Validate email format
  static String? email(String? value) {
    // 1. Basic checks
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final email = value.trim();

    // 2. Must contain exactly one @
    if (email.split('@').length != 2) {
      return 'Invalid email format';
    }

    // 3. Check for spaces
    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    // 4. Split into local and domain parts
    final parts = email.split('@');
    final local = parts[0];
    final domain = parts[1];

    // 5. Local part validation (username)
    if (local.isEmpty || local.length > 64) {
      return 'Invalid email format';
    }

    // Local cannot start or end with dot
    if (local.startsWith('.') || local.endsWith('.')) {
      return 'Invalid email format';
    }

    // No consecutive dots in local part
    if (local.contains('..')) {
      return 'Invalid email format';
    }

    // Local part pattern: must start and end with alphanumeric
    // Allows: letters, numbers, dots, underscores, percent, plus, hyphen
    final localPattern =
        RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._%+-]*[a-zA-Z0-9]$|^[a-zA-Z0-9]$');
    if (!localPattern.hasMatch(local)) {
      return 'Invalid email format';
    }

    // 6. Domain validation
    if (domain.isEmpty || domain.length > 255) {
      return 'Invalid email format';
    }

    // Domain must contain at least one dot (require TLD)
    if (!domain.contains('.')) {
      return 'Invalid email format (domain must include TLD)';
    }

    // No consecutive dots in domain
    if (domain.contains('..')) {
      return 'Invalid email format';
    }

    // Domain cannot start or end with dot or hyphen
    if (domain.startsWith('.') ||
        domain.endsWith('.') ||
        domain.startsWith('-') ||
        domain.endsWith('-')) {
      return 'Invalid email format';
    }

    // Domain pattern (support unlimited subdomain levels)
    // Examples: company.com, mail.company.co.id, api.v2.staging.company.io
    final domainPattern = RegExp(
        r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?' // First label
        r'(\.[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?)*' // Subdomain labels (unlimited)
        r'\.[a-zA-Z]{2,}$' // TLD (minimum 2 chars: .id, .com, .co)
        );
    if (!domainPattern.hasMatch(domain)) {
      return 'Invalid email format';
    }

    // ✅ ALL CHECKS PASSED
    return null;
  }

  // ============================================================================
  // PASSWORD VALIDATION
  // ============================================================================

  /// Validate password (min 8 chars, 1 letter, 1 number)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }

    // Check for at least one letter
    if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validate confirm password
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Check password strength
  static PasswordStrength checkPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.empty;

    int score = 0;

    // Length check
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;

    // Contains lowercase
    if (RegExp(r'[a-z]').hasMatch(password)) score++;

    // Contains uppercase
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;

    // Contains number
    if (RegExp(r'\d').hasMatch(password)) score++;

    // Contains special character
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

    if (score <= 2) return PasswordStrength.weak;
    if (score <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  // ============================================================================
  // OTP VALIDATION
  // ============================================================================

  /// Validate OTP (6 digits)
  static String? otp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // ============================================================================
  // PHONE NUMBER VALIDATION (Indonesian)
  // ============================================================================

  /// Validate Indonesian phone number
  static String? phoneNumber(String? value) {
    // Phone number is optional, so empty is valid
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    // Must start with 08
    if (!value.startsWith('08')) {
      return 'Phone number must start with 08';
    }

    // Must be 10-15 digits
    if (value.length < 10 || value.length > 15) {
      return 'Phone number must be 10-15 digits';
    }

    // Must contain only numbers
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number must contain only numbers';
    }

    return null;
  }

  // ============================================================================
  // NAME VALIDATION
  // ============================================================================

  /// Validate full name
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    // Only letters, spaces, and common name characters
    if (!RegExp(r"^[a-zA-Z\s'\-.]+$").hasMatch(value)) {
      return 'Name contains invalid characters';
    }

    return null;
  }

  // ============================================================================
  // PATIENT CODE VALIDATION
  // ============================================================================

  /// Validate patient code
  static String? patientCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Patient code is required';
    }

    final trimmed = value.trim();

    if (trimmed.length < 3) {
      return 'Patient code must be at least 3 characters';
    }

    if (trimmed.length > 50) {
      return 'Patient code must not exceed 50 characters';
    }

    // Allow alphanumeric, hyphens, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmed)) {
      return 'Patient code can only contain letters, numbers, hyphens, and underscores';
    }

    return null;
  }

  // ============================================================================
  // DATE VALIDATION
  // ============================================================================

  /// Validate date of birth (must be in past)
  static String? dateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }

    final now = DateTime.now();

    // Cannot be in future
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }

    // Must be at least 1 year old
    final oneYearAgo = now.subtract(const Duration(days: 365));
    if (value.isAfter(oneYearAgo)) {
      return 'Invalid date of birth';
    }

    // Maximum age 150 years
    final maxAge = now.subtract(const Duration(days: 365 * 150));
    if (value.isBefore(maxAge)) {
      return 'Invalid date of birth';
    }

    return null;
  }

  // ============================================================================
  // GENERIC VALIDATORS
  // ============================================================================

  /// Validate required field
  static String? required(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate min length
  static String? minLength(String? value, int min,
      {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < min) {
      return '$fieldName must be at least $min characters';
    }

    return null;
  }

  /// Validate max length
  static String? maxLength(String? value, int max,
      {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return null; // Empty is valid for max length
    }

    if (value.length > max) {
      return '$fieldName must not exceed $max characters';
    }

    return null;
  }

  /// Validate numeric
  static String? numeric(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return '$fieldName must contain only numbers';
    }

    return null;
  }

  /// Validate alphabetic
  static String? alphabetic(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return '$fieldName must contain only letters';
    }

    return null;
  }

  /// Combine multiple validators
  static String? combine(
      String? value, List<String? Function(String?)> validators) {
    for (final validator in validators) {
      final error = validator(value);
      if (error != null) return error;
    }
    return null;
  }
}

/// Password Strength Enum
enum PasswordStrength {
  empty,
  weak,
  medium,
  strong,
}

/// Extension for PasswordStrength
extension PasswordStrengthExtension on PasswordStrength {
  String get label {
    switch (this) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.medium:
        return 'Medium';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  double get value {
    switch (this) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }
}
