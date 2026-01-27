// lib/data/local/hive_box_names.dart

/// Hive Box Names Constants
/// Centralized untuk avoid typo & inconsistency
class HiveBoxNames {
  HiveBoxNames._(); // Private constructor
  
  // Model boxes (TypeAdapter)
  static const String users = 'users_box';
  static const String patients = 'patients_box';
  static const String detections = 'detections_box';
  
  // Settings box (dynamic)
  static const String settings = 'settings_box';
}

/// Hive Settings Keys
/// Keys untuk settings box (cache metadata)
class HiveSettingsKeys {
  HiveSettingsKeys._();
  
  static const String lastSyncPatients = 'last_sync_patients';
  static const String lastSyncDetections = 'last_sync_detections';
  static const String cacheVersion = 'cache_version';
}