// lib/providers/location_provider.dart

import 'package:flutter/foundation.dart';
import '../data/repositories/location_repository.dart';
import '../data/models/location_model.dart';


/// Location Provider
/// 
/// State management for Indonesia administrative regions (Wilayah)
/// 
/// Features:
/// - Cascade dropdowns (province → city → district → village)
/// - Cache provinces (30 days)
/// - Real-time fetch for regencies/districts/villages
/// - Loading state per dropdown level
/// - Error handling per level
/// 
/// Use Cases:
/// - Signup screen (address selection)
/// - Edit profile screen (update address)
/// 
/// Cache Strategy:
/// - Provinces: 30-day cache (rarely changes)
/// - Regencies/Districts/Villages: No cache (real-time)
/// 
/// Usage:
/// ```dart
/// final provider = Provider.of<LocationProvider>(context, listen: false);
/// 
/// // Load provinces first
/// await provider.loadProvinces();
/// 
/// // User selects province → Load regencies
/// await provider.loadRegencies(selectedProvince.code);
/// 
/// // User selects regency → Load districts
/// await provider.loadDistricts(selectedRegency.code);
/// 
/// // User selects district → Load villages
/// await provider.loadVillages(selectedDistrict.code);
/// ```
class LocationProvider extends ChangeNotifier {
  final LocationRepository _locationRepository;

  LocationProvider({LocationRepository? locationRepository})
      : _locationRepository = locationRepository ?? LocationRepository();

  // ============================================================================
  // STATE - PROVINCES (Level 1)
  // ============================================================================

  /// List of provinces (cached)
  List<LocationModel>? _provinces;
  List<LocationModel>? get provinces => _provinces;

  /// Selected province
  LocationModel? _selectedProvince;
  LocationModel? get selectedProvince => _selectedProvince;

  /// Loading provinces state
  bool _isLoadingProvinces = false;
  bool get isLoadingProvinces => _isLoadingProvinces;

  /// Provinces error
  String? _provincesError;
  String? get provincesError => _provincesError;

  // ============================================================================
  // STATE - REGENCIES (Level 2)
  // ============================================================================

  /// List of regencies (cities/kabupaten)
  List<LocationModel>? _regencies;
  List<LocationModel>? get regencies => _regencies;

  /// Selected regency
  LocationModel? _selectedRegency;
  LocationModel? get selectedRegency => _selectedRegency;

  /// Loading regencies state
  bool _isLoadingRegencies = false;
  bool get isLoadingRegencies => _isLoadingRegencies;

  /// Regencies error
  String? _regenciesError;
  String? get regenciesError => _regenciesError;

  // ============================================================================
  // STATE - DISTRICTS (Level 3)
  // ============================================================================

  /// List of districts (kecamatan)
  List<LocationModel>? _districts;
  List<LocationModel>? get districts => _districts;

  /// Selected district
  LocationModel? _selectedDistrict;
  LocationModel? get selectedDistrict => _selectedDistrict;

  /// Loading districts state
  bool _isLoadingDistricts = false;
  bool get isLoadingDistricts => _isLoadingDistricts;

  /// Districts error
  String? _districtsError;
  String? get districtsError => _districtsError;

  // ============================================================================
  // STATE - VILLAGES (Level 4)
  // ============================================================================

  /// List of villages (desa/kelurahan)
  List<LocationModel>? _villages;
  List<LocationModel>? get villages => _villages;

  /// Selected village
  LocationModel? _selectedVillage;
  LocationModel? get selectedVillage => _selectedVillage;

  /// Loading villages state
  bool _isLoadingVillages = false;
  bool get isLoadingVillages => _isLoadingVillages;

  /// Villages error
  String? _villagesError;
  String? get villagesError => _villagesError;

  // ============================================================================
  // COMPUTED PROPERTIES
  // ============================================================================

  /// Check if provinces loaded
  bool get hasProvinces => _provinces != null && _provinces!.isNotEmpty;

  /// Check if regencies loaded
  bool get hasRegencies => _regencies != null && _regencies!.isNotEmpty;

  /// Check if districts loaded
  bool get hasDistricts => _districts != null && _districts!.isNotEmpty;

  /// Check if villages loaded
  bool get hasVillages => _villages != null && _villages!.isNotEmpty;

  /// Check if any location is loading
  bool get isLoadingAny =>
      _isLoadingProvinces ||
      _isLoadingRegencies ||
      _isLoadingDistricts ||
      _isLoadingVillages;

  /// Check if complete address selected (all 4 levels)
  bool get isCompleteAddressSelected =>
      _selectedProvince != null &&
      _selectedRegency != null &&
      _selectedDistrict != null &&
      _selectedVillage != null;

  /// Get complete address string
  String? get completeAddressString {
    if (!isCompleteAddressSelected) return null;

    return '${_selectedVillage!.name}, ${_selectedDistrict!.name}, '
        '${_selectedRegency!.name}, ${_selectedProvince!.name}';
  }

  // ============================================================================
  // LEVEL 1: LOAD PROVINCES
  // ============================================================================

  /// Load provinces (with 30-day cache)
  /// 
  /// Strategy:
  /// 1. Check repository cache first (30 days)
  /// 2. If cache valid → Return cached
  /// 3. If cache expired → Fetch from API → Update cache
  /// 4. If API fails → Return stale cache (offline mode)
  /// 
  /// Parameters:
  /// - forceRefresh: Skip cache, fetch from API
  /// 
  /// Returns: true if successful
  Future<bool> loadProvinces({bool forceRefresh = false}) async {
    _isLoadingProvinces = true;
    _provincesError = null;
    notifyListeners();

    try {
      debugPrint('🌍 [LocationProvider] Loading provinces...');

      // Call repository (handles 30-day cache)
      final provinces = await _locationRepository.getProvinces(
        forceRefresh: forceRefresh,
      );

      _provinces = provinces;

      debugPrint('✅ [LocationProvider] Loaded ${provinces.length} provinces');
      _isLoadingProvinces = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [LocationProvider] Load provinces failed: $e');
      _provincesError = 'Failed to load provinces: $e';
      _isLoadingProvinces = false;
      notifyListeners();
      return false;
    }
  }

  /// Select province and load its regencies
  /// 
  /// Process:
  /// 1. Set selected province
  /// 2. Clear dependent data (regencies, districts, villages)
  /// 3. Load regencies for selected province
  /// 
  /// Parameters:
  /// - province: Selected province
  /// - autoLoadRegencies: Auto-load regencies (default: true)
  /// 
  /// Returns: true if successful
  Future<bool> selectProvince(
    LocationModel province, {
    bool autoLoadRegencies = true,
  }) async {
    debugPrint('📍 [LocationProvider] Province selected: ${province.name}');

    _selectedProvince = province;

    // Clear dependent data (cascade reset)
    _clearRegencies();
    _clearDistricts();
    _clearVillages();

    notifyListeners();

    // Auto-load regencies
    if (autoLoadRegencies) {
      return await loadRegencies(province.code);
    }

    return true;
  }

  // ============================================================================
  // LEVEL 2: LOAD REGENCIES
  // ============================================================================

  /// Load regencies (cities/kabupaten) for selected province
  /// 
  /// Strategy: Real-time fetch (no cache)
  /// 
  /// Parameters:
  /// - provinceCode: Province code (e.g., "11" for Aceh)
  /// 
  /// Returns: true if successful
  Future<bool> loadRegencies(String provinceCode) async {
    _isLoadingRegencies = true;
    _regenciesError = null;
    notifyListeners();

    try {
      debugPrint('🏙️ [LocationProvider] Loading regencies for province: $provinceCode');

      final regencies = await _locationRepository.getRegencies(provinceCode);

      _regencies = regencies;

      debugPrint('✅ [LocationProvider] Loaded ${regencies.length} regencies');
      _isLoadingRegencies = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [LocationProvider] Load regencies failed: $e');
      _regenciesError = 'Failed to load cities: $e';
      _isLoadingRegencies = false;
      notifyListeners();
      return false;
    }
  }

  /// Select regency and load its districts
  /// 
  /// Process:
  /// 1. Set selected regency
  /// 2. Clear dependent data (districts, villages)
  /// 3. Load districts for selected regency
  /// 
  /// Parameters:
  /// - regency: Selected regency
  /// - autoLoadDistricts: Auto-load districts (default: true)
  /// 
  /// Returns: true if successful
  Future<bool> selectRegency(
    LocationModel regency, {
    bool autoLoadDistricts = true,
  }) async {
    debugPrint('📍 [LocationProvider] Regency selected: ${regency.name}');

    _selectedRegency = regency;

    // Clear dependent data (cascade reset)
    _clearDistricts();
    _clearVillages();

    notifyListeners();

    // Auto-load districts
    if (autoLoadDistricts) {
      return await loadDistricts(regency.code);
    }

    return true;
  }

  // ============================================================================
  // LEVEL 3: LOAD DISTRICTS
  // ============================================================================

  /// Load districts (kecamatan) for selected regency
  /// 
  /// Strategy: Real-time fetch (no cache)
  /// 
  /// Parameters:
  /// - regencyCode: Regency code (e.g., "11.01" for Kabupaten Aceh Selatan)
  /// 
  /// Returns: true if successful
  Future<bool> loadDistricts(String regencyCode) async {
    _isLoadingDistricts = true;
    _districtsError = null;
    notifyListeners();

    try {
      debugPrint('🏘️ [LocationProvider] Loading districts for regency: $regencyCode');

      final districts = await _locationRepository.getDistricts(regencyCode);

      _districts = districts;

      debugPrint('✅ [LocationProvider] Loaded ${districts.length} districts');
      _isLoadingDistricts = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [LocationProvider] Load districts failed: $e');
      _districtsError = 'Failed to load districts: $e';
      _isLoadingDistricts = false;
      notifyListeners();
      return false;
    }
  }

  /// Select district and load its villages
  /// 
  /// Process:
  /// 1. Set selected district
  /// 2. Clear dependent data (villages)
  /// 3. Load villages for selected district
  /// 
  /// Parameters:
  /// - district: Selected district
  /// - autoLoadVillages: Auto-load villages (default: true)
  /// 
  /// Returns: true if successful
  Future<bool> selectDistrict(
    LocationModel district, {
    bool autoLoadVillages = true,
  }) async {
    debugPrint('📍 [LocationProvider] District selected: ${district.name}');

    _selectedDistrict = district;

    // Clear dependent data (cascade reset)
    _clearVillages();

    notifyListeners();

    // Auto-load villages
    if (autoLoadVillages) {
      return await loadVillages(district.code);
    }

    return true;
  }

  // ============================================================================
  // LEVEL 4: LOAD VILLAGES
  // ============================================================================

  /// Load villages (desa/kelurahan) for selected district
  /// 
  /// Strategy: Real-time fetch (no cache)
  /// 
  /// Parameters:
  /// - districtCode: District code (e.g., "11.01.01" for Kecamatan Bakongan)
  /// 
  /// Returns: true if successful
  Future<bool> loadVillages(String districtCode) async {
    _isLoadingVillages = true;
    _villagesError = null;
    notifyListeners();

    try {
      debugPrint('🏡 [LocationProvider] Loading villages for district: $districtCode');

      final villages = await _locationRepository.getVillages(districtCode);

      _villages = villages;

      debugPrint('✅ [LocationProvider] Loaded ${villages.length} villages');
      _isLoadingVillages = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ [LocationProvider] Load villages failed: $e');
      _villagesError = 'Failed to load villages: $e';
      _isLoadingVillages = false;
      notifyListeners();
      return false;
    }
  }

  /// Select village
  /// 
  /// Process:
  /// 1. Set selected village
  /// 2. Address selection complete!
  /// 
  /// Parameters:
  /// - village: Selected village
  void selectVillage(LocationModel village) {
    debugPrint('📍 [LocationProvider] Village selected: ${village.name}');
    debugPrint('✅ [LocationProvider] Complete address: $completeAddressString');

    _selectedVillage = village;
    notifyListeners();
  }

  // ============================================================================
  // RESET & CLEAR METHODS
  // ============================================================================

  /// Clear regencies and dependent data
  void _clearRegencies() {
    _regencies = null;
    _selectedRegency = null;
    _regenciesError = null;
    debugPrint('🧹 [LocationProvider] Regencies cleared');
  }

  /// Clear districts and dependent data
  void _clearDistricts() {
    _districts = null;
    _selectedDistrict = null;
    _districtsError = null;
    debugPrint('🧹 [LocationProvider] Districts cleared');
  }

  /// Clear villages
  void _clearVillages() {
    _villages = null;
    _selectedVillage = null;
    _villagesError = null;
    debugPrint('🧹 [LocationProvider] Villages cleared');
  }

  /// Reset all selections and data
  /// 
  /// Use case: Cancel form, start over
  void resetAll() {
    _provinces = null;
    _selectedProvince = null;
    _provincesError = null;

    _clearRegencies();
    _clearDistricts();
    _clearVillages();

    debugPrint('🧹 [LocationProvider] All location data reset');
    notifyListeners();
  }

  /// Reset selection (keep loaded data)
  /// 
  /// Use case: Clear form but keep dropdowns loaded
  void resetSelection() {
    _selectedProvince = null;
    _selectedRegency = null;
    _selectedDistrict = null;
    _selectedVillage = null;

    _clearRegencies();
    _clearDistricts();
    _clearVillages();

    debugPrint('🧹 [LocationProvider] Selection reset (data preserved)');
    notifyListeners();
  }

  // ============================================================================
  // PREFILL METHODS (For Edit Profile)
  // ============================================================================

  /// Prefill location from user profile
  /// 
  /// Use case: Edit profile screen (load existing address)
  /// 
  /// Process:
  /// 1. Load provinces
  /// 2. Find and select province by name
  /// 3. Load regencies → Find and select regency
  /// 4. Load districts → Find and select district
  /// 5. Load villages → Find and select village
  /// 
  /// Parameters:
  /// - provinceName: Current province name
  /// - cityName: Current city/regency name
  /// - districtName: Current district name
  /// - villageName: Current village name
  /// 
  /// Returns: true if all levels prefilled successfully
  Future<bool> prefillLocation({
    required String? provinceName,
    required String? cityName,
    required String? districtName,
    required String? villageName,
  }) async {
    debugPrint('🔄 [LocationProvider] Prefilling location...');

    // If any field is null, can't prefill
    if (provinceName == null ||
        cityName == null ||
        districtName == null ||
        villageName == null) {
      debugPrint('⚠️ [LocationProvider] Incomplete address, cannot prefill');
      return false;
    }

    try {
      // 1. Load provinces
      final provincesLoaded = await loadProvinces();
      if (!provincesLoaded) return false;

      // 2. Find and select province
      final province = _provinces!.firstWhere(
        (p) => p.name.toLowerCase() == provinceName.toLowerCase(),
        orElse: () => throw Exception('Province not found: $provinceName'),
      );
      await selectProvince(province, autoLoadRegencies: true);

      // 3. Find and select regency
      final regency = _regencies!.firstWhere(
        (r) => r.name.toLowerCase() == cityName.toLowerCase(),
        orElse: () => throw Exception('City not found: $cityName'),
      );
      await selectRegency(regency, autoLoadDistricts: true);

      // 4. Find and select district
      final district = _districts!.firstWhere(
        (d) => d.name.toLowerCase() == districtName.toLowerCase(),
        orElse: () => throw Exception('District not found: $districtName'),
      );
      await selectDistrict(district, autoLoadVillages: true);

      // 5. Find and select village
      final village = _villages!.firstWhere(
        (v) => v.name.toLowerCase() == villageName.toLowerCase(),
        orElse: () => throw Exception('Village not found: $villageName'),
      );
      selectVillage(village);

      debugPrint('✅ [LocationProvider] Location prefilled successfully');
      return true;
    } catch (e) {
      debugPrint('❌ [LocationProvider] Prefill failed: $e');
      return false;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Clear cache (call repository method)
  /// 
  /// Use case: Force refresh provinces cache
  Future<void> clearCache() async {
    await _locationRepository.clearCache();
    _provinces = null;
    debugPrint('🧹 [LocationProvider] Cache cleared');
    notifyListeners();
  }

  /// Get selected names (for form submission)
  Map<String, String?> getSelectedNames() {
    return {
      'province_name': _selectedProvince?.name,
      'city_name': _selectedRegency?.name,
      'district_name': _selectedDistrict?.name,
      'village_name': _selectedVillage?.name,
    };
  }

  /// Get selected codes (for debugging)
  Map<String, String?> getSelectedCodes() {
    return {
      'province_code': _selectedProvince?.code,
      'regency_code': _selectedRegency?.code,
      'district_code': _selectedDistrict?.code,
      'village_code': _selectedVillage?.code,
    };
  }
}