// lib/data/services/patient_service.dart

import '../../core/network/dio_clients.dart';
import '../../core/constants/api_constants.dart';
import '../models/patient/patient_model.dart';
import '../models/auth/auth_response.dart';

/// Patient Service - API calls untuk patient management
///
/// Endpoints:
/// - GET    /patients (list with pagination)
/// - POST   /patients (create new patient)
/// - GET    /patients/{code} (get by patient code)
/// - PUT    /patients/{code} (update patient)
/// - DELETE /patients/{code} (delete patient)
class PatientService {
  final DioClient _dioClient = DioClient.instance;

  /// Get list of patients for current user
  ///
  /// Backend: GET /patients?skip={skip}&limit={limit}
  Future<List<PatientModel>> getPatients({
    int skip = 0,
    int limit = 100,
  }) async {
    final response = await _dioClient.get(
      ApiConstants.patientsWithPagination(skip: skip, limit: limit),
    );

    final List<dynamic> data = response.data;
    return data.map((json) => PatientModel.fromJson(json)).toList();
  }

  /// Get patient by patient code
  ///
  /// Backend: GET /patients/{patient_code}
  Future<PatientModel> getPatientByCode(String patientCode) async {
    final response = await _dioClient.get(
      ApiConstants.patientByCode(patientCode),
    );

    return PatientModel.fromJson(response.data);
  }

  /// Create new patient
  ///
  /// Backend: POST /patients
  ///
  /// All fields required:
  /// - patientCode: Will be converted to uppercase
  /// - name: Min 2 chars
  /// - gender: "Male" or "Female"
  /// - dateOfBirth: YYYY-MM-DD format
  Future<PatientModel> createPatient({
    required String patientCode,
    required String name,
    required String gender,
    required String dateOfBirth,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.patients,
      data: {
        'patient_code': patientCode,
        'name': name,
        'gender': gender,
        'date_of_birth': dateOfBirth,
      },
    );

    if (response.data is Map && response.data.containsKey('data')) {
      return PatientModel.fromJson(response.data['data']);
    }

    // Fallback jika backend ternyata mengirim raw json
    return PatientModel.fromJson(response.data);
  }

  /// Update existing patient (partial update)
  ///
  /// Backend: PUT /patients/{patient_code}
  Future<PatientModel> updatePatient({
    required String patientCode,
    String? name,
    String? gender,
    String? dateOfBirth,
  }) async {
    final Map<String, dynamic> data = {};

    if (name != null && name.isNotEmpty) data['name'] = name;
    if (gender != null && gender.isNotEmpty) data['gender'] = gender;
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      data['date_of_birth'] = dateOfBirth;
    }

    final response = await _dioClient.put(
      ApiConstants.patientByCode(patientCode),
      data: data,
    );

    return PatientModel.fromJson(response.data);
  }

  /// Delete patient and all related records (cascade)
  ///
  /// Backend: DELETE /patients/{patient_code}
  ///
  /// Warning: Also deletes fundus images & detections
  Future<MessageResponse> deletePatient(String patientCode) async {
    final response = await _dioClient.delete(
      ApiConstants.patientByCode(patientCode),
    );

    return MessageResponse.fromJson(response.data);
  }
}
