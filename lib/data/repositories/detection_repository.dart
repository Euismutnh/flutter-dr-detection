// lib/data/repositories/detection_repository.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/detection_service.dart';
import '../models/detection/detection_model.dart';
import '../local/hive_helper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/utils/validators.dart';

/// Detection Repository
/// 
/// Business logic layer untuk DR detection management
/// 
/// Responsibilities:
/// - Coordinate DetectionService + Hive cache
/// - Implement 3-step detection flow (start → preview → save/cancel)
/// - Manage temporary session data (15-minute TTL)
/// - Handle detection history with cache strategy
/// - Validate detection inputs
/// 
/// Detection Flow (3 Steps):
/// 1. startDetection() → Upload image, AI predict → Get session_id + preview
/// 2. User Decision:
///    - saveDetection() → Save to DB → Clear session
///    - cancelDetection() → Delete temp data → Clear session
///    - retry → Call startDetection() again (new session)
/// 3. History: getDetections() → List with filters + cache
/// 
/// Cache Strategy:
/// - Detection History: Cache for 1 hour (READ operations)
/// - Session Data: In-memory only (NOT cached in Hive)
/// - Write Operations: Online only (requires internet)
class DetectionRepository {
  final DetectionService _detectionService;

  DetectionRepository({DetectionService? detectionService})
      : _detectionService = detectionService ?? DetectionService();

  // Cache expiry duration
  static const Duration _cacheExpiry = Duration(hours: 1);

  // ============================================================================
  // SESSION MANAGEMENT (In-Memory, Not Cached)
  // ============================================================================

  /// Current active session (temporary storage)
  /// 
  /// Note: This is NOT cached in Hive (session expires in 15 min on backend)
  String? get sessionId => _currentSessionId;
  String? _currentSessionId;
  DetectionPreviewModel? _currentPreviewData;

  /// Check if there's an active session
  bool get hasActiveSession => _currentSessionId != null;

  /// Get current preview data (if exists)
  DetectionPreviewModel? get currentPreview => _currentPreviewData;

  /// Clear session data (cleanup after save/cancel)
  void _clearSession() {
    _currentSessionId = null;
    _currentPreviewData = null;
    debugPrint('🧹 [DetectionRepo] Session cleared');
  }

  // ============================================================================
  // DETECTION FLOW - STEP 1: START DETECTION
  // ============================================================================

  /// Step 1: Start detection and get preview
  /// 
  /// Process:
  /// 1. Validate inputs (patient code, side eye, image)
  /// 2. Upload image to backend
  /// 3. Backend runs AI prediction
  /// 4. Backend stores result temporarily (session_id, 15 min TTL)
  /// 5. Return preview data for user review
  /// 
  /// Parameters:
  /// - patientCode: Valid patient code (must exist)
  /// - sideEye: "Right" or "Left"
  /// - image: Fundus image file (JPEG/PNG, max 5MB)
  /// 
  /// Returns: DetectionPreviewModel with session_id
  /// Throws: ApiException if upload/prediction fails
  Future<DetectionPreviewModel> startDetection({
    required String patientCode,
    required String sideEye,
    required MultipartFile image,
  }) async {
    debugPrint('🚀 [DetectionRepo] Starting detection for patient: $patientCode');

    // Validation (defense in depth)
    final codeError = Validators.patientCode(patientCode);
    if (codeError != null) {
      throw Exception(codeError);
    }

    if (sideEye != 'Right' && sideEye != 'Left') {
      throw Exception('Side eye must be "Right" or "Left"');
    }

    // Image validation (basic checks)
    if (image.length > 5 * 1024 * 1024) {
      throw Exception('Image size exceeds 5MB limit');
    }

    try {
      // Call API (upload + AI prediction)
      final response = await _detectionService.startDetection(
        patientCode: patientCode,
        sideEye: sideEye,
        image: image,
      );

      // Store session data in memory (NOT in Hive)
      _currentSessionId = response.sessionId;
      _currentPreviewData = response.data;

      debugPrint('✅ [DetectionRepo] Detection started, session: ${response.sessionId}');
      debugPrint('   Classification: ${response.data.classification} - ${response.data.predictedLabel}');
      debugPrint('   Confidence: ${(response.data.confidence * 100).toStringAsFixed(1)}%');

      return response.data;
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Start detection failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected error: $e');
      throw Exception('Detection failed: $e');
    }
  }

  // ============================================================================
  // DETECTION FLOW - STEP 2A: SAVE DETECTION
  // ============================================================================

  /// Step 2A: Save detection to database
  /// 
  /// Process:
  /// 1. Validate session exists
  /// 2. Call backend to save (fundus_image + detection records)
  /// 3. Clear local session data
  /// 4. Clear detection cache (force refresh on next getDetections)
  /// 
  /// Requirements: Must call startDetection() first
  /// 
  /// Returns: void on success
  /// Throws: ApiException if save fails or session expired
  Future<void> saveDetection() async {
    if (_currentSessionId == null) {
      throw Exception('No active detection session. Call startDetection() first.');
    }

    debugPrint('💾 [DetectionRepo] Saving detection with session: $_currentSessionId');

    try {
      // Call API to save
      await _detectionService.saveDetection(sessionId: _currentSessionId!);

      debugPrint('✅ [DetectionRepo] Detection saved successfully');

      // Clear cache to force refresh on next getDetections()
      await HiveHelper.clearDetectionsCache();
      debugPrint('🧹 [DetectionRepo] Detection cache cleared for refresh');

      // Clear session
      _clearSession();
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Save detection failed: ${e.message}');
      // Don't clear session on error (user can retry)
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected save error: $e');
      throw Exception('Failed to save detection: $e');
    }
  }

  // ============================================================================
  // DETECTION FLOW - STEP 2B: CANCEL DETECTION
  // ============================================================================

  /// Step 2B: Cancel detection and cleanup temp data
  /// 
  /// Process:
  /// 1. Call backend to delete temp image & session
  /// 2. Clear local session data
  /// 
  /// Note: This is called when user presses "Cancel" or "Retry"
  /// 
  /// Returns: void on success
  /// Throws: ApiException if cancel fails
  Future<void> cancelDetection() async {
    if (_currentSessionId == null) {
      debugPrint('⚠️ [DetectionRepo] No active session to cancel');
      return; // Silent return (idempotent)
    }

    debugPrint('🚫 [DetectionRepo] Cancelling detection session: $_currentSessionId');

    try {
      // Call API to cleanup
      await _detectionService.cancelDetection(_currentSessionId!);

      debugPrint('✅ [DetectionRepo] Detection cancelled and cleaned up');

      // Clear session
      _clearSession();
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Cancel detection failed: ${e.message}');
      
      // Clear session anyway (cleanup local state)
      _clearSession();
      
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected cancel error: $e');
      
      // Clear session anyway
      _clearSession();
      
      throw Exception('Failed to cancel detection: $e');
    }
  }

  // ============================================================================
  // DETECTION HISTORY (Hybrid Cache Strategy)
  // ============================================================================

  /// Get detection history with filters
  /// 
  /// Strategy:
  /// 1. Check cache first (if not force refresh)
  /// 2. If cache valid → Return cached data
  /// 3. If cache expired → Fetch from API → Update cache
  /// 4. If API fails → Return stale cache (offline mode)
  /// 
  /// Filters (all optional):
  /// - classification: 0-4 (No DR, Mild, Moderate, Severe, PDR)
  /// - ageMin, ageMax: Filter by patient age
  /// - gender: "Male" or "Female"
  /// - period: "last_7_days", "last_1_month", etc.
  /// - patientCode: Filter by specific patient
  /// 
  /// Returns: `List<DetectionModel>`
  /// Throws: Exception if no cache and API fails
  Future<List<DetectionModel>> getDetections({
    int? classification,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? period,
    String? patientCode,
    int skip = 0,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    debugPrint('📋 [DetectionRepo] Getting detections (forceRefresh: $forceRefresh)');

    // Validation
    if (classification != null && (classification < 0 || classification > 4)) {
      throw Exception('Classification must be between 0-4');
    }

    if (gender != null && gender != 'Male' && gender != 'Female') {
      throw Exception('Gender must be "Male" or "Female"');
    }

    // 1. Check cache first (if not force refresh and no filters)
    // Note: We only cache unfiltered results for simplicity
    final hasFilters = classification != null ||
        ageMin != null ||
        ageMax != null ||
        gender != null ||
        period != null ||
        patientCode != null;

    if (!forceRefresh && !hasFilters) {
      final isExpired = HiveHelper.isDetectionsExpired(maxAge: _cacheExpiry);

      if (!isExpired) {
        final cached = HiveHelper.getCachedDetections();
        
        if (cached.isNotEmpty) {
          debugPrint('✅ [DetectionRepo] Returning ${cached.length} detections from cache');
          return cached;
        }
      }
    }

    // 2. Fetch from API
    try {
      final detections = await _detectionService.getDetections(
        classification: classification,
        ageMin: ageMin,
        ageMax: ageMax,
        gender: gender,
        period: period,
        patientCode: patientCode,
        skip: skip,
        limit: limit,
      );

      // 3. Update cache (only if unfiltered)
      if (!hasFilters) {
        await HiveHelper.cacheDetections(detections);
        debugPrint('✅ [DetectionRepo] Fetched and cached ${detections.length} detections');
      } else {
        debugPrint('✅ [DetectionRepo] Fetched ${detections.length} filtered detections (not cached)');
      }

      return detections;
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] API failed: ${e.message}');

      // 4. Fallback to stale cache (offline mode, only if unfiltered)
      if (!hasFilters) {
        final cached = HiveHelper.getCachedDetections();
        
        if (cached.isNotEmpty) {
          debugPrint('⚠️ [DetectionRepo] Returning ${cached.length} stale cached detections (offline mode)');
          return cached;
        }
      }

      debugPrint('❌ [DetectionRepo] No cache available');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected error: $e');

      // Try return stale cache (unfiltered only)
      if (!hasFilters) {
        final cached = HiveHelper.getCachedDetections();
        if (cached.isNotEmpty) {
          debugPrint('⚠️ [DetectionRepo] Returning cached detections after error');
          return cached;
        }
      }

      throw Exception('Failed to get detections: $e');
    }
  }

  /// Get detection detail by ID
  /// 
  /// Strategy:
  /// 1. Try get from cache first (fast)
  /// 2. If not in cache or force refresh → Fetch from API
  /// 
  /// Returns: DetectionModel
  /// Throws: ApiException if not found
  Future<DetectionModel> getDetectionById(
    int detectionId, {
    bool forceRefresh = false,
  }) async {
    debugPrint('🔍 [DetectionRepo] Getting detection: $detectionId');

    // 1. Check cache first
    if (!forceRefresh) {
      final cached = HiveHelper.getDetectionById(detectionId);
      
      if (cached != null) {
        debugPrint('✅ [DetectionRepo] Detection found in cache: $detectionId');
        return cached;
      }
    }

    // 2. Fetch from API
    try {
      final detection = await _detectionService.getDetectionById(detectionId);
      debugPrint('✅ [DetectionRepo] Detection fetched: $detectionId');

      return detection;
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Get detection failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected error: $e');
      throw Exception('Failed to get detection: $e');
    }
  }

  /// Delete detection by ID
  /// 
  /// Strategy:
  /// 1. Call API to delete (cascade: fundus_image also deleted)
  /// 2. Remove from cache
  /// 
  /// Returns: void on success
  /// Throws: ApiException if delete fails
  Future<void> deleteDetection(int detectionId) async {
    debugPrint('🗑️ [DetectionRepo] Deleting detection: $detectionId');

    try {
      // Call API (cascade delete)
      await _detectionService.deleteDetection(detectionId);

      // Remove from cache
      await HiveHelper.deleteDetectionCache(detectionId);
      debugPrint('✅ [DetectionRepo] Detection deleted: $detectionId');
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Delete detection failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected error: $e');
      throw Exception('Failed to delete detection: $e');
    }
  }

  // ============================================================================
  // PROGRESS CHART (No Cache - Real-time Data)
  // ============================================================================

  /// Get patient progress chart data
  /// 
  /// Use case: Show DR progression over time for specific patient
  /// 
  /// Note: NOT cached (always fetch from API for accurate timeline)
  /// 
  /// Returns: Map with chart data
  /// Throws: ApiException if patient not found or API fails
  Future<Map<String, dynamic>> getPatientProgressChart(int patientId) async {
    debugPrint('📊 [DetectionRepo] Getting progress chart for patient: $patientId');

    try {
      final chartData = await _detectionService.getPatientProgressChart(patientId);
      debugPrint('✅ [DetectionRepo] Progress chart fetched');

      return chartData;
    } on ApiException catch (e) {
      debugPrint('❌ [DetectionRepo] Get progress chart failed: ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Unexpected error: $e');
      throw Exception('Failed to get progress chart: $e');
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear detection cache manually
  /// 
  /// Use case: Force refresh after logout or data corruption
  Future<void> clearCache() async {
    try {
      await HiveHelper.clearDetectionsCache();
      debugPrint('✅ [DetectionRepo] Detection cache cleared');
    } catch (e) {
      debugPrint('❌ [DetectionRepo] Clear cache failed: $e');
    }
  }

  /// Check if cache is expired
  /// 
  /// Returns: true if expired or no cache
  bool isCacheExpired() {
    return HiveHelper.isDetectionsExpired(maxAge: _cacheExpiry);
  }

  /// Get detections count from cache (for UI badges)
  /// 
  /// Returns: Number of cached detections
  int getCachedDetectionsCount() {
    return HiveHelper.getDetectionsCount();
  }
}