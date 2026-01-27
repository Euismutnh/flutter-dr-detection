// lib/data/local/shared_prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../core/constants/app_constants.dart';

/// Shared Preferences Helper
/// For simple key-value storage (non-sensitive data)
class SharedPrefsHelper {
  static SharedPreferences? _prefs;
  
  /// Initialize SharedPreferences
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  /// Get SharedPreferences instance
  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }
  
  // ============================================================================
  // AUTH STATE
  // ============================================================================
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }
  
  /// Set login status
  static Future<bool> setLoggedIn(bool value) async {
    final prefs = await _instance;
    return prefs.setBool(AppConstants.keyIsLoggedIn, value);
  }
  
  // ============================================================================
  // USER DATA
  // ============================================================================
  
  /// Save user data as JSON string
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await _instance;
    final jsonString = jsonEncode(userData);
    return prefs.setString(AppConstants.keyUserData, jsonString);
  }
  
  /// Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await _instance;
    final jsonString = prefs.getString(AppConstants.keyUserData);
    
    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }
    
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding user data: $e');
      return null;
    }
  }
  
  /// Clear user data
  static Future<bool> clearUserData() async {
    final prefs = await _instance;
    return prefs.remove(AppConstants.keyUserData);
  }
  
  // ============================================================================
  // GENERIC METHODS
  // ============================================================================
  
  /// Save string
  static Future<bool> setString(String key, String value) async {
    final prefs = await _instance;
    return prefs.setString(key, value);
  }
  
  /// Get string
  static Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }
  
  /// Save int
  static Future<bool> setInt(String key, int value) async {
    final prefs = await _instance;
    return prefs.setInt(key, value);
  }
  
  /// Get int
  static Future<int?> getInt(String key) async {
    final prefs = await _instance;
    return prefs.getInt(key);
  }
  
  /// Save bool
  static Future<bool> setBool(String key, bool value) async {
    final prefs = await _instance;
    return prefs.setBool(key, value);
  }
  
  /// Get bool
  static Future<bool?> getBool(String key) async {
    final prefs = await _instance;
    return prefs.getBool(key);
  }
  
  /// Save double
  static Future<bool> setDouble(String key, double value) async {
    final prefs = await _instance;
    return prefs.setDouble(key, value);
  }
  
  /// Get double
  static Future<double?> getDouble(String key) async {
    final prefs = await _instance;
    return prefs.getDouble(key);
  }
  
  /// Save list of strings
  static Future<bool> setStringList(String key, List<String> value) async {
    final prefs = await _instance;
    return prefs.setStringList(key, value);
  }
  
  /// Get list of strings
  static Future<List<String>?> getStringList(String key) async {
    final prefs = await _instance;
    return prefs.getStringList(key);
  }
  
  /// Remove key
  static Future<bool> remove(String key) async {
    final prefs = await _instance;
    return prefs.remove(key);
  }
  
  /// Check if key exists
  static Future<bool> containsKey(String key) async {
    final prefs = await _instance;
    return prefs.containsKey(key);
  }
  
  /// Clear all data
  static Future<bool> clearAll() async {
    final prefs = await _instance;
    return prefs.clear();
  }
  
  /// Get all keys
  static Future<Set<String>> getAllKeys() async {
    final prefs = await _instance;
    return prefs.getKeys();
  }
}