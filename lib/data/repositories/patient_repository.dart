// lib/data/repositories/patient_repository.dart

import 'package:flutter/foundation.dart';
import '../services/patient_service.dart';
import '../models/patient/patient_model.dart';
import '../local/hive_helper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';

/// Patient Repository
/// 
/// Business logic layer untuk patient management
/// 
/// Responsibilities:
/// - Coordinate PatientService + Hive cache
/// - Implement hybrid cache strategy (online/offline)
/// - Validate patient data (defense in depth)
/// - Handle CRUD operations with cache sync
/// 
/// Cache Strategy:
/// - READ: Check cache first → If expired, fetch API → Update cache
/// - WRITE: API only (requires internet) → Update cache on success
/// - Cache Duration: 1 hour (configurable)
/// - Offline: Return stale cache with warning
class PatientRepository {
  final PatientService _patientService;

  PatientRepository({PatientService? patientService})
      : _patientService = patientService ?? PatientService();

  // Cache expiry duration
  static const Duration _cacheExpiry = Duration(hours: 1);

  // ============================================================================
  // READ OPERATIONS (Hybrid Cache Strategy)
  // ============================================================================

  /// Get all patients for current user
  /// 
  /// Strategy:
  /// 1. Check cache first (if not force refresh)
  /// 2. If cache valid → Return cached data
  /// 3. If cache expired → Fetch from API → Update cache
  /// 4. If API fails → Return stale cache (offline mode)
  /// 
  /// Parameters:
  /// - forceRefresh: Skip cache, fetch from API
  /// - skip, limit: Pagination (for future use)
  /// 
  /// Returns: `List<PatientModel>`
  /// Throws: Exception if no cache and API fails
  Future<List<PatientModel>> getPatients({
    bool forceRefresh = false,
    int skip = 0,
    int limit = 100,
  }) async {
    debugPrint('📋 [PatientRepo] Getting patients (forceRefresh: $forceRefresh)');

    // 1. Check cache first (if not force refresh)
    if (!forceRefresh) {
      // Check if cache expired
      final isExpired = HiveHelper.isPatientsExpired(maxAge: _cacheExpiry);

      if (!isExpired) {
        // Cache valid, return cached data
        final cached = HiveHelper.getCachedPatients();
        
        if (cached.isNotEmpty) {
          debugPrint('✅ [PatientRepo] Returning ${cached.length} patients from cache');
          return cached;
        }
      } else {
        debugPrint('⏰ [PatientRepo] Cache expired, fetching from API');
      }
    }

    // 2. Fetch from API
    try {
      final patients = await _patientService.getPatients(
        skip: skip,
        limit: limit,
      );

      // 3. Update cache
      await HiveHelper.cachePatients(patients);
      debugPrint('✅ [PatientRepo] Fetched and cached ${patients.length} patients');

      return patients;
    } on ApiException catch (e) {
      debugPrint('❌ [PatientRepo] API failed: ${e.message}');

      // 4. Fallback to stale cache (offline mode)
      final cached = HiveHelper.getCachedPatients();
      
      if (cached.isNotEmpty) {
        debugPrint('⚠️ [PatientRepo] Returning ${cached.length} stale cached patients (offline mode)');
        return cached;
      }

      // No cache available, rethrow error
      debugPrint('❌ [PatientRepo] No cache available');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PatientRepo] Unexpected error: $e');

      // Try return stale cache
      final cached = HiveHelper.getCachedPatients();
      if (cached.isNotEmpty) {
        debugPrint('⚠️ [PatientRepo] Returning cached patients after error');
        return cached;
      }

      throw Exception('Failed to get patients: $e');
    }
  }

  /// Get patient by patient code
  /// 
  /// Strategy:
  /// 1. Try get from Hive cache first (fast)
  /// 2. If not in cache or force refresh → Fetch from API
  /// 3. Update cache on API success
  /// 
  /// Returns: PatientModel
  /// Throws: ApiException if not found or network error
  Future<PatientModel> getPatientByCode(
    String patientCode, {
    bool forceRefresh = false,
  }) async {
    // Validation
    final codeError = Validators.patientCode(patientCode);
    if (codeError != null) {
      throw Exception(codeError);
    }

    debugPrint('🔍 [PatientRepo] Getting patient: $patientCode');

    // 1. Check cache first (if not force refresh)
    if (!forceRefresh) {
      final cached = HiveHelper.getPatientByCode(patientCode);
      
      if (cached != null) {
        debugPrint('✅ [PatientRepo] Patient found in cache: $patientCode');
        return cached;
      }
    }

    // 2. Fetch from API
    try {
      final patient = await _patientService.getPatientByCode(patientCode);

      // 3. Update cache (single patient)
      await HiveHelper.updatePatientCache(patient);
      debugPrint('✅ [PatientRepo] Patient fetched and cached: $patientCode');

      return patient;
    } on ApiException catch (e) {
      debugPrint('❌ [PatientRepo] Get patient failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PatientRepo] Unexpected error: $e');
      throw Exception('Failed to get patient: $e');
    }
  }

  // ============================================================================
  // WRITE OPERATIONS (Requires Internet)
  // ============================================================================

  /// Create new patient
  /// 
  /// Strategy:
  /// 1. Validate input data (defense in depth)
  /// 2. Call API to create patient
  /// 3. Update cache with new patient
  /// 
  /// Requirements: ALL FIELDS REQUIRED
  /// - patientCode: 3-50 chars, alphanumeric + underscore/hyphen
  /// - name: Min 2 chars
  /// - gender: "Male" or "Female"
  /// - dateOfBirth: Valid date in past
  /// 
  /// Returns: Created PatientModel
  /// Throws: ApiException if creation fails
  Future<PatientModel> createPatient({
    required String patientCode,
    required String name,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    debugPrint('➕ [PatientRepo] Creating patient: $patientCode');

    // Validation (defense in depth)
    final codeError = Validators.patientCode(patientCode);
    if (codeError != null) {
      throw Exception(codeError);
    }

    final nameError = Validators.name(name);
    if (nameError != null) {
      throw Exception(nameError);
    }

    if (gender != 'Male' && gender != 'Female') {
      throw Exception('Gender must be "Male" or "Female"');
    }

    final dobError = Validators.dateOfBirth(dateOfBirth);
    if (dobError != null) {
      throw Exception(dobError);
    }

    try {
      // Format date for API (YYYY-MM-DD)
      final dateString = Helpers.formatDateForApi(dateOfBirth);

      // Call API
      final patient = await _patientService.createPatient(
        patientCode: patientCode,
        name: name,
        gender: gender,
        dateOfBirth: dateString,
      );

      // Update cache (add to list)
      await HiveHelper.updatePatientCache(patient);
      debugPrint('✅ [PatientRepo] Patient created and cached: $patientCode');

      return patient;
    } on ApiException catch (e) {
      debugPrint('❌ [PatientRepo] Create patient failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PatientRepo] Unexpected error: $e');
      throw Exception('Failed to create patient: $e');
    }
  }

  /// Update existing patient
  /// 
  /// Strategy:
  /// 1. Validate input data (if provided)
  /// 2. Call API to update patient
  /// 3. Update cache with updated patient
  /// 
  /// Note: Partial update supported (pass only fields to update)
  /// 
  /// Returns: Updated PatientModel
  /// Throws: ApiException if update fails
  Future<PatientModel> updatePatient({
    required String patientCode,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    debugPrint('✏️ [PatientRepo] Updating patient: $patientCode');

    // Validation
    final codeError = Validators.patientCode(patientCode);
    if (codeError != null) {
      throw Exception(codeError);
    }

    if (name != null) {
      final nameError = Validators.name(name);
      if (nameError != null) {
        throw Exception(nameError);
      }
    }

    if (gender != null && gender != 'Male' && gender != 'Female') {
      throw Exception('Gender must be "Male" or "Female"');
    }

    if (dateOfBirth != null) {
      final dobError = Validators.dateOfBirth(dateOfBirth);
      if (dobError != null) {
        throw Exception(dobError);
      }
    }

    try {
      // Format date if provided
      final dateString = dateOfBirth != null
          ? Helpers.formatDateForApi(dateOfBirth)
          : null;

      // Call API
      final patient = await _patientService.updatePatient(
        patientCode: patientCode,
        name: name,
        gender: gender,
        dateOfBirth: dateString,
      );

      // Update cache
      await HiveHelper.updatePatientCache(patient);
      debugPrint('✅ [PatientRepo] Patient updated and cached: $patientCode');

      return patient;
    } on ApiException catch (e) {
      debugPrint('❌ [PatientRepo] Update patient failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PatientRepo] Unexpected error: $e');
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete patient and all related records
  /// 
  /// Strategy:
  /// 1. Call API to delete patient (cascade delete on backend)
  /// 2. Remove from cache
  /// 
  /// Warning: This also deletes all detections & fundus images!
  /// 
  /// Returns: void on success
  /// Throws: ApiException if delete fails
  Future<void> deletePatient(String patientCode) async {
    debugPrint('🗑️ [PatientRepo] Deleting patient: $patientCode');

    // Validation
    final codeError = Validators.patientCode(patientCode);
    if (codeError != null) {
      throw Exception(codeError);
    }

    try {
      // Call API (cascade delete)
      await _patientService.deletePatient(patientCode);

      // Remove from cache
      await HiveHelper.deletePatientCache(patientCode);
      debugPrint('✅ [PatientRepo] Patient deleted: $patientCode');
    } on ApiException catch (e) {
      debugPrint('❌ [PatientRepo] Delete patient failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [PatientRepo] Unexpected error: $e');
      throw Exception('Failed to delete patient: $e');
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear patient cache manually
  /// 
  /// Use case: Force refresh after logout or data corruption
  Future<void> clearCache() async {
    try {
      await HiveHelper.clearPatientsCache();
      debugPrint('✅ [PatientRepo] Cache cleared');
    } catch (e) {
      debugPrint('❌ [PatientRepo] Clear cache failed: $e');
    }
  }

  /// Check if cache is expired
  /// 
  /// Returns: true if expired or no cache
  bool isCacheExpired() {
    return HiveHelper.isPatientsExpired(maxAge: _cacheExpiry);
  }

  /// Get patients count from cache (for UI badges)
  /// 
  /// Returns: Number of cached patients
  int getCachedPatientsCount() {
    return HiveHelper.getPatientsCount();
  }

  /// Check if patient exists in cache (offline check)
  /// 
  /// Returns: true if found in cache
  bool isPatientCached(String patientCode) {
    final patient = HiveHelper.getPatientByCode(patientCode);
    return patient != null;
  }
}