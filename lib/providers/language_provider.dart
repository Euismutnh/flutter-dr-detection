// lib/providers/language_provider.dart

import 'package:flutter/material.dart';
import '../data/local/shared_prefs_helper.dart';
import '../core/constants/app_constants.dart';

/// Language Provider
/// 
/// State management for app language (i18n)
/// 
/// Features:
/// - Switch between English & Indonesian
/// - Persist selection to SharedPreferences
/// - Load saved language on app start
/// 
/// Usage:
/// ```dart
/// final provider = Provider.of<LanguageProvider>(context, listen: false);
/// await provider.changeLanguage('id'); // Switch to Indonesian
/// ```
class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en'); // Default: English
  
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  
  /// Check if current language is English
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  /// Check if current language is Indonesian
  bool get isIndonesian => _currentLocale.languageCode == 'id';
  
  /// Get current language name
  String get currentLanguageName {
    return AppConstants.languageNames[_currentLocale.languageCode] ?? 'English';
  }

  // ============================================================================
  // INITIALIZATION
  // ============================================================================
  
  /// Load saved language from SharedPreferences
  /// 
  /// Call this in main.dart before runApp()
  Future<void> loadSavedLanguage() async {
    try {
      final savedLanguage = await SharedPrefsHelper.getString(
        AppConstants.keySelectedLanguage,
      );
      
      if (savedLanguage != null && 
          AppConstants.supportedLanguages.contains(savedLanguage)) {
        _currentLocale = Locale(savedLanguage);
        debugPrint('🌍 [LanguageProvider] Loaded saved language: $savedLanguage');
      } else {
        _currentLocale = Locale(AppConstants.defaultLanguage);
        debugPrint('🌍 [LanguageProvider] Using default language: ${AppConstants.defaultLanguage}');
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('❌ [LanguageProvider] Load language failed: $e');
      _currentLocale = Locale(AppConstants.defaultLanguage);
    }
  }

  // ============================================================================
  // CHANGE LANGUAGE
  // ============================================================================
  
  /// Change app language
  /// 
  /// Parameters:
  /// - languageCode: 'en' or 'id'
  /// 
  /// Returns: true if successful
  Future<bool> changeLanguage(String languageCode) async {
    // Validate language code
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      debugPrint('❌ [LanguageProvider] Unsupported language: $languageCode');
      return false;
    }
    
    // Check if already current language
    if (_currentLocale.languageCode == languageCode) {
      debugPrint('ℹ️ [LanguageProvider] Already using language: $languageCode');
      return true;
    }
    
    try {
      debugPrint('🌍 [LanguageProvider] Changing language to: $languageCode');
      
      // Update locale
      _currentLocale = Locale(languageCode);
      
      // Save to SharedPreferences
      await SharedPrefsHelper.setString(
        AppConstants.keySelectedLanguage,
        languageCode,
      );
      
      debugPrint('✅ [LanguageProvider] Language changed successfully');
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [LanguageProvider] Change language failed: $e');
      return false;
    }
  }
  
  /// Toggle between English and Indonesian
  Future<bool> toggleLanguage() async {
    final newLanguage = isEnglish ? 'id' : 'en';
    return await changeLanguage(newLanguage);
  }
  
  /// Reset to default language (English)
  Future<bool> resetToDefault() async {
    return await changeLanguage(AppConstants.defaultLanguage);
  }
}