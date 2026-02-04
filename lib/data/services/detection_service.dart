// lib/data/services/detection_service.dart

import 'package:dio/dio.dart';
import '../../core/network/dio_clients.dart';
import '../../core/constants/api_constants.dart';
import '../models/detection/detection_model.dart';
import '../models/auth/auth_response.dart';

/// Detection Service - API calls untuk deteksi DR
///
/// Flow 3 langkah:
/// 1. POST /detections/start (upload gambar) -> dapat session_id
/// 2. User review hasil -> pilih Save/Retry/Cancel
/// 3. POST /detections/save (dengan session_id) -> simpan ke database
class DetectionService {
  final DioClient _dioClient = DioClient.instance;

  /// Start detection (Step 1)
  ///
  /// Backend: POST /detections/start (multipart/form-data)
  ///
  /// Upload fundus image untuk prediksi AI
  /// Session berlaku 15 menit
  Future<DetectionPreviewModel> startDetection({
    required String patientCode,
    required String sideEye,
    required MultipartFile image,
  }) async {
    final formData = FormData.fromMap({
      'patient_code': patientCode,
      'side_eye': sideEye,
      'image': image,
    });

    final response = await _dioClient.post(
      ApiConstants.detectionsStart,
      data: formData,
    );
    // 1. Ambil body response sebagai Map
    final rootData = response.data as Map<String, dynamic>;
    // 2. Ambil objek 'data' (berisi patient_code, predicted_label, dll)
    final detectionData = rootData['data'] as Map<String, dynamic>;
    // 3. Ambil 'session_id' dari luar, masukkan ke dalam detectionData
    detectionData['session_id'] = rootData['session_id'];
    return DetectionPreviewModel.fromJson(detectionData);
  }

  /// Save detection (Step 3)
  ///
  /// Backend: POST /detections/save
  ///
  /// Simpan hasil deteksi ke database setelah user confirm
  /// Harus dipanggil dalam 15 menit setelah startDetection
  Future<MessageResponse> saveDetection({required String sessionId}) async {
    final response = await _dioClient.post(
      ApiConstants.detectionsSave,
      data: {'session_id': sessionId},
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Cancel detection
  ///
  /// Backend: DELETE /detections/cancel/{session_id}
  ///
  /// Batalkan deteksi dan hapus data temporary
  Future<MessageResponse> cancelDetection(String sessionId) async {
    final response = await _dioClient.delete(
      ApiConstants.detectionsCancel(sessionId),
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Get list detections dengan filter
  ///
  /// Backend: GET /detections
  ///
  /// Filters available:
  /// - classification: 0-4 (No DR, Mild, Moderate, Severe, PDR)
  /// - age_min, age_max: filter umur pasien
  /// - gender: "Male" atau "Female"
  /// - period: "last_7_days", "last_1_month", etc
  /// - patient_code: filter by kode pasien
  Future<List<DetectionModel>> getDetections({
    int? classification,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? period,
    String? patientCode,
    int skip = 0,
    int limit = 100,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.detectionsWithFilters(
        classification: classification,
        ageMin: ageMin,
        ageMax: ageMax,
        gender: gender,
        period: period,
        patientCode: patientCode,
        skip: skip,
        limit: limit,
      ),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => DetectionModel.fromJson(json)).toList();
  }

  /// Get detection detail by ID
  ///
  /// Backend: GET /detections/{id}
  Future<DetectionModel> getDetectionById(int detectionId) async {
    final response = await _dioClient.get(
      ApiConstants.detectionById(detectionId),
    );

    return DetectionModel.fromJson(response.data);
  }

  /// Delete detection
  ///
  /// Backend: DELETE /detections/{id}
  ///
  /// Hapus deteksi + fundus image terkait (cascade)
  Future<MessageResponse> deleteDetection(int detectionId) async {
    final response = await _dioClient.delete(
      ApiConstants.detectionById(detectionId),
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Get patient progress chart
  ///
  /// Backend: GET /detections/patients/{patient_id}/progress-chart
  ///
  /// Data untuk chart progress DR pasien dari waktu ke waktu
  Future<Map<String, dynamic>> getPatientProgressChart(int patientId) async {
    final response = await _dioClient.get(
      ApiConstants.patientProgressChart(patientId),
    );

    return response.data as Map<String, dynamic>;
  }
}
