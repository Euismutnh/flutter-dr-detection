// lib/data/services/user_service.dart

import '../../core/network/dio_clients.dart';
import '../../core/constants/api_constants.dart';
import '../models/user/user_model.dart';

/// User Service - API calls untuk manajemen profil user
///
/// Note: Auth-related endpoints ada di auth_service.dart
/// Service ini khusus untuk CRUD profil user yang sudah login
class UserService {
  final DioClient _dioClient = DioClient.instance;

  /// Get current user profile
  ///
  /// Backend: GET /users/me
  Future<UserModel> getCurrentUserProfile() async {
    final response = await _dioClient.get(ApiConstants.usersMe);
    return UserModel.fromJson(response.data);
  }

  /// Update user profile (partial update)
  ///
  /// Backend: PATCH /users/me
  ///
  /// Kirim field yang mau diupdate aja
  /// Photo diupdate lewat auth_service.updateProfilePhoto()
  Future<UserModel> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? profession,
    String? dateOfBirth, // YYYY-MM-DD
    String? provinceName,
    String? cityName,
    String? districtName,
    String? villageName,
    String? detailedAddress,
    String? assignmentLocation,
  }) async {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['full_name'] = fullName;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;
    if (profession != null) data['profession'] = profession;
    if (dateOfBirth != null) data['date_of_birth'] = dateOfBirth;
    if (provinceName != null) data['province_name'] = provinceName;
    if (cityName != null) data['city_name'] = cityName;
    if (districtName != null) data['district_name'] = districtName;
    if (villageName != null) data['village_name'] = villageName;
    if (detailedAddress != null) data['detailed_address'] = detailedAddress;
    if (assignmentLocation != null) {
      data['assignment_location'] = assignmentLocation;
    }

    final response = await _dioClient.patch(ApiConstants.usersMe, data: data);

    return UserModel.fromJson(response.data);
  }
}
