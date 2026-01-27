// lib/data/local/hive_helper.dart

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user/user_model.dart';
import '../models/patient/patient_model.dart';
import '../models/detection/detection_model.dart';
import 'hive_box_names.dart';

class HiveHelper {
  HiveHelper._(); // Private constructor

  static bool _isInitialized = false;

  /// Initialize Hive (call di main.dart sebelum runApp)
  static Future<void> init() async {
    if (_isInitialized) {
      debugPrint('⚠️ Hive already initialized');
      return;
    }

    // Initialize Hive Flutter
    await Hive.initFlutter();

    // Register TypeAdapters (PENTING!)
    Hive.registerAdapter(UserModelAdapter()); // typeId: 0
    Hive.registerAdapter(PatientModelAdapter()); // typeId: 1
    Hive.registerAdapter(DetectionModelAdapter()); // typeId: 2

    _isInitialized = true;
    debugPrint('✅ Hive initialized with TypeAdapters');
  }

  /// Open all boxes (call setelah init, sebelum runApp)
  static Future<void> openBoxes() async {
    if (!_isInitialized) {
      throw StateError('Hive not initialized. Call HiveHelper.init() first');
    }

    await Future.wait([
      Hive.openBox<UserModel>(HiveBoxNames.users),
      Hive.openBox<PatientModel>(HiveBoxNames.patients),
      Hive.openBox<DetectionModel>(HiveBoxNames.detections),
      Hive.openBox(HiveBoxNames.settings), // Dynamic box untuk settings
    ]);

    debugPrint('✅ All Hive boxes opened');
  }

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================

  /// Save current user
  static Future<void> saveCurrentUser(UserModel user) async {
    final box = Hive.box<UserModel>(HiveBoxNames.users);
    await box.put('current_user', user);
    debugPrint('✅ User saved: ${user.email}');
  }

  /// Get current user
  static UserModel? getCurrentUser() {
    final box = Hive.box<UserModel>(HiveBoxNames.users);
    return box.get('current_user');
  }

  /// Delete current user
  static Future<void> deleteCurrentUser() async {
    final box = Hive.box<UserModel>(HiveBoxNames.users);
    await box.delete('current_user');
    debugPrint('✅ User deleted');
  }

  /// Check if user exists (without deserializing full object)
  static bool hasUser() {
    return getCurrentUser() != null;
  }

  // ============================================================================
  // PATIENT MANAGEMENT
  // ============================================================================

  /// Cache patient list (overwrite all)
  static Future<void> cachePatients(List<PatientModel> patients) async {
    final box = Hive.box<PatientModel>(HiveBoxNames.patients);

    // Clear old cache
    await box.clear();

    // Add all dengan patient code sebagai key
    for (var patient in patients) {
      await box.put(patient.patientCode, patient);
    }

    // Save last sync time
    await _saveLastSyncTime(HiveSettingsKeys.lastSyncPatients);

    debugPrint('✅ Cached ${patients.length} patients');
  }

  /// Get cached patients
  static List<PatientModel> getCachedPatients() {
    final box = Hive.box<PatientModel>(HiveBoxNames.patients);
    return box.values.toList();
  }

  /// Get patient by code
  static PatientModel? getPatientByCode(String code) {
    final box = Hive.box<PatientModel>(HiveBoxNames.patients);
    return box.get(code);
  }

  /// Update single patient in cache (without refetching all)
  static Future<void> updatePatientCache(PatientModel patient) async {
    final box = Hive.box<PatientModel>(HiveBoxNames.patients);
    await box.put(patient.patientCode, patient);
    debugPrint('✅ Patient updated in cache: ${patient.patientCode}');
  }

  /// Delete patient from cache
  static Future<void> deletePatientCache(String code) async {
    final box = Hive.box<PatientModel>(HiveBoxNames.patients);
    await box.delete(code);
    debugPrint('✅ Patient deleted from cache: $code');
  }

  /// Get patients count (for UI badges)
  static int getPatientsCount() {
    return Hive.box<PatientModel>(HiveBoxNames.patients).length;
  }

  // ============================================================================
  // DETECTION MANAGEMENT
  // ============================================================================

  /// Cache detection list (overwrite all)
  static Future<void> cacheDetections(List<DetectionModel> detections) async {
    final box = Hive.box<DetectionModel>(HiveBoxNames.detections);

    // Clear old cache
    await box.clear();

    // Add all dengan detection id sebagai key
    for (var detection in detections) {
      await box.put(detection.id, detection);
    }

    // Save last sync time
    await _saveLastSyncTime(HiveSettingsKeys.lastSyncDetections);

    debugPrint('✅ Cached ${detections.length} detections');
  }

  /// Get cached detections
  static List<DetectionModel> getCachedDetections() {
    final box = Hive.box<DetectionModel>(HiveBoxNames.detections);
    return box.values.toList();
  }

  /// Get detection by id
  static DetectionModel? getDetectionById(int id) {
    final box = Hive.box<DetectionModel>(HiveBoxNames.detections);
    return box.get(id);
  }

  /// Delete detection from cache
  static Future<void> deleteDetectionCache(int id) async {
    final box = Hive.box<DetectionModel>(HiveBoxNames.detections);
    await box.delete(id);
    debugPrint('✅ Detection deleted from cache: $id');
  }

  /// Get detections count (for UI badges)
  static int getDetectionsCount() {
    return Hive.box<DetectionModel>(HiveBoxNames.detections).length;
  }

  // ============================================================================
  // GENERIC DATA METHODS (✅ NEW - For Dashboard & Other Dynamic Data)
  // ============================================================================

  /// Save generic data (any type that can be serialized)
  /// 
  /// Use case: Cache dashboard stats, app settings, etc.
  /// 
  /// Example:
  /// ```dart
  /// await HiveHelper.saveData('dashboard_stats', dashboardStatsJson);
  /// await HiveHelper.saveData('user_preferences', {'theme': 'dark'});
  /// ```
  static Future<void> saveData<T>(String key, T value) async {
    try {
      final box = Hive.box(HiveBoxNames.settings);
      await box.put(key, value);
      debugPrint('✅ [HiveHelper] Data saved for key: $key');
    } catch (e) {
      debugPrint('❌ [HiveHelper] Failed to save data for key $key: $e');
      rethrow;
    }
  }

  /// Get generic data
  /// 
  /// Returns: Data of type T, or null if not found
  /// 
  /// Example:
  /// ```dart
  /// final stats = HiveHelper.getData<Map<String, dynamic>>('dashboard_stats');
  /// final count = HiveHelper.getData<int>('total_patients');
  /// ```
  static T? getData<T>(String key) {
    try {
      final box = Hive.box(HiveBoxNames.settings);
      final value = box.get(key) as T?;
      
      if (value == null) {
        debugPrint('ℹ️ [HiveHelper] No data found for key: $key');
      } else {
        debugPrint('✅ [HiveHelper] Data retrieved for key: $key');
      }
      
      return value;
    } catch (e) {
      debugPrint('❌ [HiveHelper] Failed to get data for key $key: $e');
      return null;
    }
  }

  /// Delete generic data
  /// 
  /// Use case: Clear specific cache (e.g., dashboard cache)
  static Future<void> deleteData(String key) async {
    try {
      final box = Hive.box(HiveBoxNames.settings);
      await box.delete(key);
      debugPrint('✅ [HiveHelper] Data deleted for key: $key');
    } catch (e) {
      debugPrint('❌ [HiveHelper] Failed to delete data for key $key: $e');
    }
  }

  /// Check if data exists for a key
  /// 
  /// Use case: Check if dashboard cache exists before loading
  static bool hasData(String key) {
    try {
      final box = Hive.box(HiveBoxNames.settings);
      return box.containsKey(key);
    } catch (e) {
      debugPrint('❌ [HiveHelper] Failed to check key $key: $e');
      return false;
    }
  }

  // ============================================================================
  // TIMESTAMP & CACHE EXPIRY
  // ============================================================================

  /// Save last sync time (internal use)
  static Future<void> _saveLastSyncTime(String key) async {
    final box = Hive.box(HiveBoxNames.settings);
    await box.put(key, DateTime.now().toIso8601String());
  }

  /// Get last sync time
  static DateTime? getLastSyncTime(String key) {
    final box = Hive.box(HiveBoxNames.settings);
    final timeStr = box.get(key) as String?;
    return timeStr != null ? DateTime.parse(timeStr) : null;
  }

  /// Check if cache expired (generic method)
  static bool isCacheExpired(
    String key, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    final lastSync = getLastSyncTime(key);
    if (lastSync == null) return true;

    final now = DateTime.now();
    final age = now.difference(lastSync);

    return age > maxAge;
  }

  /// Check if patients cache expired (shortcut method)
  static bool isPatientsExpired({
    Duration maxAge = const Duration(hours: 1),
  }) {
    return isCacheExpired(HiveSettingsKeys.lastSyncPatients, maxAge: maxAge);
  }

  /// Check if detections cache expired (shortcut method)
  static bool isDetectionsExpired({
    Duration maxAge = const Duration(hours: 1),
  }) {
    return isCacheExpired(HiveSettingsKeys.lastSyncDetections, maxAge: maxAge);
  }

  // ============================================================================
  // CACHE CLEANUP
  // ============================================================================

  /// Clear all cached data (untuk logout)
  static Future<void> clearAllCache() async {
    await Future.wait([
      Hive.box<UserModel>(HiveBoxNames.users).clear(),
      Hive.box<PatientModel>(HiveBoxNames.patients).clear(),
      Hive.box<DetectionModel>(HiveBoxNames.detections).clear(),
      Hive.box(HiveBoxNames.settings).clear(),
    ]);

    debugPrint('✅ All Hive cache cleared');
  }

  /// Clear only patients cache (untuk refresh patients)
  static Future<void> clearPatientsCache() async {
    await Hive.box<PatientModel>(HiveBoxNames.patients).clear();
    debugPrint('✅ Patients cache cleared');
  }

  /// Clear only detections cache (untuk refresh detections)
  static Future<void> clearDetectionsCache() async {
    await Hive.box<DetectionModel>(HiveBoxNames.detections).clear();
    debugPrint('✅ Detections cache cleared');
  }

  // ============================================================================
  // STATISTICS & DEBUGGING
  // ============================================================================

  /// Get cache statistics (detailed info)
  static Map<String, dynamic> getCacheStats() {
    return {
      'users_count': Hive.box<UserModel>(HiveBoxNames.users).length,
      'patients_count': getPatientsCount(),
      'detections_count': getDetectionsCount(),
      'settings_keys_count': Hive.box(HiveBoxNames.settings).length,
      'patients_last_sync': getLastSyncTime(HiveSettingsKeys.lastSyncPatients),
      'detections_last_sync':
          getLastSyncTime(HiveSettingsKeys.lastSyncDetections),
      'patients_expired': isPatientsExpired(),
      'detections_expired': isDetectionsExpired(),
    };
  }

  /// Print cache stats (untuk debugging)
  static void printCacheStats() {
    final stats = getCacheStats();
    debugPrint('📊 Hive Cache Stats:');
    stats.forEach((key, value) {
      debugPrint('  - $key: $value');
    });
  }

  /// Close all boxes (optional, untuk cleanup saat app terminate)
  static Future<void> closeBoxes() async {
    await Hive.close();
    _isInitialized = false;
    debugPrint('✅ All Hive boxes closed');
  }
}