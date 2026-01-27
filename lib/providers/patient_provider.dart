// lib/providers/patient_provider.dart

import 'package:flutter/foundation.dart';
import '../data/repositories/patient_repository.dart';
import '../data/models/patient/patient_model.dart';
import '../core/network/api_error_handler.dart';

/// Patient Provider
/// 
/// State management for patient CRUD operations
/// 
/// Features:
/// - In-memory cache + smart refresh
/// - CRUD operations (create, read, update, delete)
/// - Search & filter patients in-memory
/// - Offline support via repository cache
/// - Rethrow errors to UI for localized message handling
/// 
/// Usage:
/// ```dart
/// final provider = Provider.of<PatientProvider>(context, listen: false);
/// try {
///   await provider.loadPatients();
/// } on ApiException catch (e) {
///   final message = e.getTranslatedMessage(context);
///   Helpers.showErrorSnackbar(context, message);
/// }
/// ```
class PatientProvider extends ChangeNotifier {
  final PatientRepository _patientRepository;

  PatientProvider({PatientRepository? patientRepository})
      : _patientRepository = patientRepository ?? PatientRepository();

  // ============================================================================
  // STATE
  // ============================================================================

  /// In-memory cache of patients
  List<PatientModel>? _cachedPatients;
  List<PatientModel>? get patients => _cachedPatients;

  /// Selected patient for detail view
  PatientModel? _selectedPatient;
  PatientModel? get selectedPatient => _selectedPatient;

  /// Loading states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCreating = false;
  bool get isCreating => _isCreating;

  bool _isUpdating = false;
  bool get isUpdating => _isUpdating;

  bool _isDeleting = false;
  bool get isDeleting => _isDeleting;

  /// Error key (for debugging/optional UI display)
  String? _errorKey;
  String? get errorKey => _errorKey;

  /// Last load time (for smart refresh)
  DateTime? _lastLoadTime;
  DateTime? get lastLoadTime => _lastLoadTime;

  /// Search query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// Gender filter
  String? _genderFilter;
  String? get genderFilter => _genderFilter;

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Filtered patients based on search query and gender filter
  List<PatientModel> get filteredPatients {
    if (_cachedPatients == null) return [];

    List<PatientModel> result = _cachedPatients!;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((patient) {
        return patient.name.toLowerCase().contains(query) ||
            patient.patientCode.toLowerCase().contains(query);
      }).toList();
    }

    // Apply gender filter
    if (_genderFilter != null && _genderFilter!.isNotEmpty) {
      result = result.where((patient) {
        return patient.gender.toLowerCase() == _genderFilter!.toLowerCase();
      }).toList();
    }

    return result;
  }

  /// Check if there are patients
  bool get hasPatients => _cachedPatients != null && _cachedPatients!.isNotEmpty;

  /// Check if filtered results are empty
  bool get isFilteredEmpty => filteredPatients.isEmpty;

  /// Get patients count
  int get patientsCount => _cachedPatients?.length ?? 0;

  /// Get filtered count
  int get filteredCount => filteredPatients.length;

  // ============================================================================
  // LOAD PATIENTS (READ)
  // ============================================================================

  /// Load all patients with smart refresh
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> loadPatients({bool forceRefresh = false}) async {
    // If already in memory & not force refresh → skip
    if (_cachedPatients != null && !forceRefresh) {
      debugPrint('📋 [PatientProvider] Using in-memory cache (${_cachedPatients!.length} patients)');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      debugPrint('🔄 [PatientProvider] Loading patients (forceRefresh: $forceRefresh)...');

      final patients = await _patientRepository.getPatients(
        forceRefresh: forceRefresh,
      );

      // Update in-memory cache
      _cachedPatients = patients;
      _lastLoadTime = DateTime.now();

      debugPrint('✅ [PatientProvider] Loaded ${patients.length} patients');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  /// Refresh patients (force reload)
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> refreshPatients() async {
    debugPrint('🔄 [PatientProvider] Refreshing patients...');
    await loadPatients(forceRefresh: true);
  }

  // ============================================================================
  // GET PATIENT DETAIL (READ)
  // ============================================================================

  /// Get patient by patient code
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> getPatientByCode(
    String patientCode, {
    bool forceRefresh = false,
  }) async {
    _clearError();

    // Try find in memory first (if not force refresh)
    if (!forceRefresh && _cachedPatients != null) {
      try {
        final patient = _cachedPatients!.firstWhere(
          (p) => p.patientCode.toLowerCase() == patientCode.toLowerCase(),
        );
        _selectedPatient = patient;
        debugPrint('✅ [PatientProvider] Patient found in memory: $patientCode');
        notifyListeners();
        return;
      } catch (e) {
        // Not found in memory, continue to API
        debugPrint('⚠️ [PatientProvider] Patient not in memory, fetching from API...');
      }
    }

    // Fetch from repository
    _setLoading(true);

    try {
      debugPrint('🔄 [PatientProvider] Fetching patient: $patientCode');

      final patient = await _patientRepository.getPatientByCode(
        patientCode,
        forceRefresh: forceRefresh,
      );

      _selectedPatient = patient;

      // Update in-memory cache if exists
      if (_cachedPatients != null) {
        final index = _cachedPatients!.indexWhere(
          (p) => p.patientCode.toLowerCase() == patientCode.toLowerCase(),
        );

        if (index != -1) {
          _cachedPatients![index] = patient;
        } else {
          _cachedPatients!.add(patient);
        }
      }

      debugPrint('✅ [PatientProvider] Patient fetched: $patientCode');
      _setLoading(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setLoading(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setLoading(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // CREATE PATIENT (WRITE)
  // ============================================================================

  /// Create new patient
  /// 
  /// Returns: Created PatientModel
  /// Throws: ApiException (caught by UI for localized message)
  Future<PatientModel> createPatient({
    required String patientCode,
    required String name,
    required String gender,
    required DateTime dateOfBirth,
  }) async {
    _setCreating(true);
    _clearError();

    try {
      debugPrint('➕ [PatientProvider] Creating patient: $patientCode');

      final patient = await _patientRepository.createPatient(
        patientCode: patientCode,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      // Invalidate in-memory cache & reload
      debugPrint('🔄 [PatientProvider] Patient created, reloading list...');
      await loadPatients(forceRefresh: true);

      debugPrint('✅ [PatientProvider] Patient created successfully: $patientCode');
      _setCreating(false);
      return patient;
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setCreating(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setCreating(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // UPDATE PATIENT (WRITE)
  // ============================================================================

  /// Update existing patient
  /// 
  /// Returns: Updated PatientModel
  /// Throws: ApiException (caught by UI for localized message)
  Future<PatientModel> updatePatient({
    required String patientCode,
    String? name,
    String? gender,
    DateTime? dateOfBirth,
  }) async {
    _setUpdating(true);
    _clearError();

    try {
      debugPrint('✏️ [PatientProvider] Updating patient: $patientCode');

      final patient = await _patientRepository.updatePatient(
        patientCode: patientCode,
        name: name,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

      // Update in-memory cache
      if (_cachedPatients != null) {
        final index = _cachedPatients!.indexWhere(
          (p) => p.patientCode.toLowerCase() == patientCode.toLowerCase(),
        );

        if (index != -1) {
          _cachedPatients![index] = patient;
          debugPrint('✅ [PatientProvider] Updated in-memory cache');
        }
      }

      // Update selected patient if it's the same
      if (_selectedPatient?.patientCode.toLowerCase() == patientCode.toLowerCase()) {
        _selectedPatient = patient;
        debugPrint('✅ [PatientProvider] Updated selected patient');
      }

      debugPrint('✅ [PatientProvider] Patient updated successfully: $patientCode');
      _setUpdating(false);
      return patient;
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setUpdating(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setUpdating(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // DELETE PATIENT (WRITE)
  // ============================================================================

  /// Delete patient and all related records
  /// 
  /// Throws: ApiException (caught by UI for localized message)
  Future<void> deletePatient(String patientCode) async {
    _setDeleting(true);
    _clearError();

    try {
      debugPrint('🗑️ [PatientProvider] Deleting patient: $patientCode');

      await _patientRepository.deletePatient(patientCode);

      // Remove from in-memory cache
      if (_cachedPatients != null) {
        _cachedPatients!.removeWhere(
          (p) => p.patientCode.toLowerCase() == patientCode.toLowerCase(),
        );
        debugPrint('✅ [PatientProvider] Removed from in-memory cache');
      }

      // Clear selected patient if same
      if (_selectedPatient?.patientCode.toLowerCase() == patientCode.toLowerCase()) {
        _selectedPatient = null;
        debugPrint('✅ [PatientProvider] Cleared selected patient');
      }

      debugPrint('✅ [PatientProvider] Patient deleted successfully: $patientCode');
      _setDeleting(false);
    } on ApiException catch (e) {
      _setError(e.errorKey);
      _setDeleting(false);
      rethrow;
    } catch (e) {
      _setError('error_unknown');
      _setDeleting(false);
      throw ApiException(errorKey: 'error_unknown', error: null);
    }
  }

  // ============================================================================
  // SEARCH & FILTER
  // ============================================================================

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    debugPrint('🔍 [PatientProvider] Search query: "$query" ($filteredCount results)');
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    debugPrint('🔍 [PatientProvider] Search cleared');
    notifyListeners();
  }

  /// Set gender filter
  void setGenderFilter(String? gender) {
    _genderFilter = gender;
    debugPrint('🔍 [PatientProvider] Gender filter: ${gender ?? "All"} ($filteredCount results)');
    notifyListeners();
  }

  /// Clear gender filter
  void clearGenderFilter() {
    _genderFilter = null;
    debugPrint('🔍 [PatientProvider] Gender filter cleared');
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _genderFilter = null;
    debugPrint('🔍 [PatientProvider] All filters cleared');
    notifyListeners();
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set creating state
  void _setCreating(bool value) {
    _isCreating = value;
    notifyListeners();
  }

  /// Set updating state
  void _setUpdating(bool value) {
    _isUpdating = value;
    notifyListeners();
  }

  /// Set deleting state
  void _setDeleting(bool value) {
    _isDeleting = value;
    notifyListeners();
  }

  /// Set error key
  void _setError(String key) {
    _errorKey = key;
    notifyListeners();
  }

  /// Clear error key
  void _clearError() {
    _errorKey = null;
  }

  /// Set selected patient
  void setSelectedPatient(PatientModel? patient) {
    _selectedPatient = patient;
    debugPrint('👤 [PatientProvider] Selected patient: ${patient?.patientCode ?? "None"}');
    notifyListeners();
  }

  /// Clear selected patient
  void clearSelectedPatient() {
    _selectedPatient = null;
    debugPrint('👤 [PatientProvider] Selected patient cleared');
    notifyListeners();
  }

  /// Clear all in-memory cache
  void clearCache() {
    _cachedPatients = null;
    _selectedPatient = null;
    _lastLoadTime = null;
    _searchQuery = '';
    _genderFilter = null;
    _errorKey = null;
    debugPrint('🧹 [PatientProvider] Cache cleared');
    notifyListeners();
  }

  /// Check if cache is expired (1 hour)
  bool isCacheExpired() {
    if (_lastLoadTime == null) return true;
    final age = DateTime.now().difference(_lastLoadTime!);
    return age > const Duration(hours: 1);
  }

  /// Get cache age string
  String? getCacheAgeString() {
    if (_lastLoadTime == null) return null;
    final age = DateTime.now().difference(_lastLoadTime!);

    if (age.inMinutes < 1) return 'Just now';
    if (age.inMinutes < 60) return '${age.inMinutes} min ago';
    if (age.inHours < 24) return '${age.inHours} hour${age.inHours > 1 ? 's' : ''} ago';
    return '${age.inDays} day${age.inDays > 1 ? 's' : ''} ago';
  }
}