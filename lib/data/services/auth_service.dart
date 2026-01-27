// lib/data/services/auth_service.dart

import 'package:dio/dio.dart';
import '../../core/network/dio_clients.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth/auth_response.dart';
import '../models/user/user_model.dart';

class AuthService {
  final DioClient _dioClient = DioClient.instance;

  /// Backend: POST /auth/signup (multipart/form-data)
  Future<MessageResponse> signup({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? profession,
    String? dateOfBirth, // YYYY-MM-DD format
    String? provinceName,
    String? cityName,
    String? districtName,
    String? villageName,
    String? detailedAddress,
    String? assignmentLocation,
    MultipartFile? photo, // Optional profile photo
  }) async {
    // Prepare FormData
    final formData = FormData.fromMap({
      'full_name': fullName,
      'email': email,
      'password': password,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (profession != null) 'profession': profession,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (provinceName != null) 'province_name': provinceName,
      if (cityName != null) 'city_name': cityName,
      if (districtName != null) 'district_name': districtName,
      if (villageName != null) 'village_name': villageName,
      if (detailedAddress != null) 'detailed_address': detailedAddress,
      if (assignmentLocation != null) 'assignment_location': assignmentLocation,
      if (photo != null) 'photo': photo,
    });

    final response = await _dioClient.post(
      ApiConstants.authSignup,
      data: formData,
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/verify-otp
  Future<AuthTokenResponse> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.authVerifyOtp,
      data: {'email': email, 'otp': otp},
    );

    return AuthTokenResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/signin
  /// Backend: POST /auth/signin
  Future<MessageResponse> signin({
    required String email,
    required String password,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.authSignin,
      data: {'email': email, 'password': password},
    );
    return MessageResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/signin/verify-otp
  /// Returns: AuthTokenResponse (access_token + refresh_token)
  Future<AuthTokenResponse> verifySigninOtp({
    required String email,
    required String otp,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.authSigninVerifyOtp,
      data: {'email': email, 'otp': otp},
    );

    return AuthTokenResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/refresh
  /// Returns: AuthTokenResponse (new access_token + same refresh_token)
  Future<AuthTokenResponse> refreshToken({required String refreshToken}) async {
    final response = await _dioClient.post(
      ApiConstants.authRefresh,
      data: {'refresh_token': refreshToken},
    );

    return AuthTokenResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/forgot-password
  /// Returns: MessageResponse (OTP sent)
  Future<MessageResponse> forgotPassword({required String email}) async {
    final response = await _dioClient.post(
      ApiConstants.authForgotPassword,
      data: {'email': email},
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/reset-password
  /// Returns: MessageResponse (password reset success)
  Future<MessageResponse> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await _dioClient.post(
      ApiConstants.authResetPassword,
      data: {'email': email, 'otp': otp, 'new_password': newPassword},
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/resend-otp
  /// Returns: MessageResponse (OTP resent)
  Future<MessageResponse> resendOtp({required String email}) async {
    final response = await _dioClient.post(
      ApiConstants.authResendOtp,
      data: {'email': email},
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: GET /auth/me
  /// Returns: UserModel (current user data)
  /// Note: Requires authentication (access token in header)
  Future<UserModel> getCurrentUser() async {
    final response = await _dioClient.get(ApiConstants.authMe);
    return UserModel.fromJson(response.data);
  }

  /// Backend: POST /auth/update-profile-photo (multipart/form-data)
  /// Returns: MessageResponse (photo updated)
  Future<MessageResponse> updateProfilePhoto({
    required MultipartFile photo,
  }) async {
    final formData = FormData.fromMap({'photo': photo});

    final response = await _dioClient.postFormData(
      ApiConstants.authUpdateProfilePhoto,
      formData: formData,
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: DELETE /auth/delete-profile-photo
  /// Returns: MessageResponse (photo deleted)
  Future<MessageResponse> deleteProfilePhoto() async {
    final response = await _dioClient.delete(
      ApiConstants.authDeleteProfilePhoto,
    );

    return MessageResponse.fromJson(response.data);
  }

  /// Backend: POST /auth/signout
  /// Returns: MessageResponse (signed out successfully)
  /// Note: Backend will blacklist the access token
  Future<MessageResponse> signout() async {
    final response = await _dioClient.post(ApiConstants.authSignout);
    return MessageResponse.fromJson(response.data);
  }
}
