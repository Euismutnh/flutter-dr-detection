// lib/data/repositories/wilayah_repository.dart

import '../services/location_service.dart';
import '../models/location_model.dart';
import '../local/shared_prefs_helper.dart';
import 'dart:convert';

class LocationRepository {
  final LocationService _service;

  LocationRepository({LocationService? service})
      : _service = service ?? LocationService();

  static const String _keyProvinces = 'cached_provinces';
  static const String _keyProvincesTimestamp = 'cached_provinces_timestamp';
  static const Duration _cacheDuration = Duration(days: 30);

  Future<List<LocationModel>> getProvinces({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _getCachedProvinces();
      if (cached != null) return cached;
    }

    try {
      final provinces = await _service.getProvinces();
      await _cacheProvinces(provinces);
      return provinces;
    } catch (e) {
      final cached = await _getCachedProvinces(ignoreExpiry: true);
      if (cached != null) return cached;
      rethrow;
    }
  }

  Future<List<LocationModel>> getRegencies(String provinceCode) async {
    return await _service.getRegencies(provinceCode);
  }

  Future<List<LocationModel>> getDistricts(String regencyCode) async {
    return await _service.getDistricts(regencyCode);
  }

  Future<List<LocationModel>> getVillages(String districtCode) async {
    return await _service.getVillages(districtCode);
  }

  Future<List<LocationModel>?> _getCachedProvinces({bool ignoreExpiry = false}) async {
    try {
      final jsonString = await SharedPrefsHelper.getString(_keyProvinces);
      if (jsonString == null) return null;

      if (!ignoreExpiry) {
        final timestamp = await SharedPrefsHelper.getInt(_keyProvincesTimestamp);
        if (timestamp == null) return null;

        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final age = DateTime.now().difference(cacheTime);

        if (age > _cacheDuration) return null;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => LocationModel.fromJson(json)).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> _cacheProvinces(List<LocationModel> provinces) async {
    try {
      final jsonString = jsonEncode(provinces.map((p) => p.toJson()).toList());
      await SharedPrefsHelper.setString(_keyProvinces, jsonString);
      await SharedPrefsHelper.setInt(
        _keyProvincesTimestamp,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> clearCache() async {
    await SharedPrefsHelper.remove(_keyProvinces);
    await SharedPrefsHelper.remove(_keyProvincesTimestamp);
  }
}