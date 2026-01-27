// lib/data/services/location_service.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/external_dio_client.dart';
import '../models/location_model.dart';

/// Location Service
///
/// API client untuk Wilayah Indonesia (External API)
///
/// API: https://wilayah.id/api
///
/// Response Format:
/// ```json
/// {
///   "data": [
///     { "code": "11", "name": "Aceh" },
///     { "code": "12", "name": "Sumatera Utara" },
///     ...
///   ],
///   "meta": {
///     "administrative_area_level": 1,
///     "updated_at": "2025-07-04"
///   }
/// }
/// ```
class LocationService {
  static const String _baseUrl = 'https://wilayah.id/api';
  final Dio _dio;

  LocationService({Dio? dio}) : _dio = dio ?? ExternalDioClient.instance.dio;

  /// Get all provinces
  Future<List<LocationModel>> getProvinces() async {
    try {
      debugPrint('🌍 [LocationService] Fetching provinces...');
      final response = await _dio.get('$_baseUrl/provinces.json');
      final result = _parseLocationList(response.data);
      debugPrint('✅ [LocationService] Provinces loaded: ${result.length}');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ [LocationService] Provinces error: ${e.message}');
      throw Exception('Failed to load provinces: ${e.message}');
    }
  }

  /// Get regencies (cities/kabupaten) by province code
  Future<List<LocationModel>> getRegencies(String provinceCode) async {
    try {
      debugPrint(
        '🌍 [LocationService] Fetching regencies for province: $provinceCode',
      );
      final response = await _dio.get('$_baseUrl/regencies/$provinceCode.json');
      final result = _parseLocationList(response.data);
      debugPrint('✅ [LocationService] Regencies loaded: ${result.length}');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ [LocationService] Regencies error: ${e.message}');
      throw Exception('Failed to load regencies: ${e.message}');
    }
  }

  /// Get districts (kecamatan) by regency code
  Future<List<LocationModel>> getDistricts(String regencyCode) async {
    try {
      debugPrint(
        '🌍 [LocationService] Fetching districts for regency: $regencyCode',
      );
      final response = await _dio.get('$_baseUrl/districts/$regencyCode.json');
      final result = _parseLocationList(response.data);
      debugPrint('✅ [LocationService] Districts loaded: ${result.length}');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ [LocationService] Districts error: ${e.message}');
      throw Exception('Failed to load districts: ${e.message}');
    }
  }

  /// Get villages (desa/kelurahan) by district code
  Future<List<LocationModel>> getVillages(String districtCode) async {
    try {
      debugPrint(
        '🌍 [LocationService] Fetching villages for district: $districtCode',
      );
      final response = await _dio.get('$_baseUrl/villages/$districtCode.json');
      final result = _parseLocationList(response.data);
      debugPrint('✅ [LocationService] Villages loaded: ${result.length}');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ [LocationService] Villages error: ${e.message}');
      throw Exception('Failed to load villages: ${e.message}');
    }
  }

  /// Parse location list from API response
  ///
  /// Handles both formats:
  /// 1. Direct list: [{ "code": "11", "name": "Aceh" }, ...]
  /// 2. Wrapped in data: { "data": [...], "meta": {...} }
  List<LocationModel> _parseLocationList(dynamic data) {
    try {
      List<dynamic> list;

      // wilayah.id format: { "data": [...], "meta": {...} }
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        list = data['data'] as List<dynamic>;
      } else if (data is List) {
        list = data;
      } else {
        debugPrint('⚠️ [LocationService] Unknown format: ${data.runtimeType}');
        return [];
      }

      return list
          .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ [LocationService] Parse error: $e');
      return [];
    }
  }
}

