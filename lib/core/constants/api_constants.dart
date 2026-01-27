// lib/core/constants/api_constants.dart

/// API Constants
/// 
/// Centralized API configuration and endpoint definitions.
/// 
/// IMPORTANT: Endpoints yang return list harus pakai trailing slash
/// untuk menghindari redirect yang menyebabkan hilangnya Authorization header.
/// 
/// Backend behavior:
/// - /patients  → 301 redirect → /patients/ (header hilang!)
/// - /patients/ → 200 OK (correct)
class ApiConstants {
  ApiConstants._();

  // ============================================================================
  // BASE CONFIGURATION
  // ============================================================================
  
  /// Base URL untuk API
  static const String baseUrl =
      'https://dr-detection-api-165772118694.asia-southeast2.run.app/api/v1';
  
  /// Connection timeout (10 menit untuk upload gambar besar)
  static const int connectionTimeout = 600000;
  
  /// Receive timeout (10 menit untuk AI processing)
  static const int receiveTimeout = 600000;

  // ============================================================================
  // AUTH ENDPOINTS (12 endpoints)
  // Semua TANPA trailing slash (tidak ada redirect issue)
  // ============================================================================
  
  static const String authSignup = '/auth/signup';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResendOtp = '/auth/resend-otp';
  static const String authSignin = '/auth/signin';
  static const String authSigninVerifyOtp = '/auth/signin/verify-otp';
  static const String authRefresh = '/auth/refresh';
  static const String authSignout = '/auth/signout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';
  static const String authMe = '/auth/me';
  static const String authUpdateProfilePhoto = '/auth/update-profile-photo';
  static const String authDeleteProfilePhoto = '/auth/delete-profile-photo';

  // ============================================================================
  // USERS ENDPOINTS
  // ============================================================================
  
  /// GET & PATCH /users/me
  static const String usersMe = '/users/me';

  // ============================================================================
  // PATIENTS ENDPOINTS
  // PENTING: Pakai trailing slash untuk list endpoint!
  // ============================================================================
  
  /// GET (list) & POST (create) - DENGAN trailing slash
  static const String patients = '/patients/';
  
  /// Patient by code (GET, PUT, DELETE) - TANPA trailing slash
  /// Contoh: /patients/P001
  static String patientByCode(String code) => '/patients/$code';

  // ============================================================================
  // DETECTIONS ENDPOINTS
  // PENTING: Pakai trailing slash untuk list endpoint!
  // ============================================================================
  
  // === Detection Workflow ===
  
  /// POST /detections/start - Start detection (upload image)
  static const String detectionsStart = '/detections/start';
  
  /// POST /detections/save - Save detection result
  static const String detectionsSave = '/detections/save';
  
  /// DELETE /detections/cancel/{session_id} - Cancel detection
  static String detectionsCancel(String sessionId) => '/detections/cancel/$sessionId';

  // === Detection CRUD ===
  
  /// GET /detections/ - List detections - DENGAN trailing slash
  static const String detections = '/detections/';
  
  /// GET/DELETE /detections/{id} - Detection by ID
  static String detectionById(int id) => '/detections/$id';
  
  /// GET /detections/patients/{patient_id}/progress-chart
  static String patientProgressChart(int patientId) =>
      '/detections/patients/$patientId/progress-chart';

  // ============================================================================
  // DASHBOARD ENDPOINTS
  // ============================================================================
  
  /// GET /dashboard/stats - Dashboard statistics
  static const String dashboardStats = '/dashboard/stats';

  // ============================================================================
  // QUERY BUILDERS
  // PENTING: Semua query builder sudah include trailing slash
  // ============================================================================
  
  /// Build detection list URL with filters
  /// 
  /// Parameters:
  /// - classification: 0-4 (DR severity)
  /// - ageMin/ageMax: Age range filter
  /// - gender: "Male" or "Female"
  /// - period: "today", "week", "month", "year"
  /// - patientCode: Filter by specific patient
  /// - skip/limit: Pagination
  static String detectionsWithFilters({
    int? classification,
    int? ageMin,
    int? ageMax,
    String? gender,
    String? period,
    String? patientCode,
    int skip = 0,
    int limit = 100,
  }) {
    final params = <String>[];
    
    if (classification != null) params.add('classification=$classification');
    if (ageMin != null) params.add('age_min=$ageMin');
    if (ageMax != null) params.add('age_max=$ageMax');
    if (gender != null) params.add('gender=$gender');
    if (period != null) params.add('period=$period');
    if (patientCode != null) params.add('patient_code=$patientCode');
    params.add('skip=$skip');
    params.add('limit=$limit');
    
    // PENTING: Pakai trailing slash sebelum query params
    return '/detections/?${params.join('&')}';
  }

  /// Build patient list URL with pagination
  /// 
  /// Parameters:
  /// - skip: Offset for pagination (default: 0)
  /// - limit: Number of items per page (default: 100)
  static String patientsWithPagination({int skip = 0, int limit = 100}) {
    // PENTING: Pakai trailing slash sebelum query params
    return '/patients/?skip=$skip&limit=$limit';
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Build full URL from endpoint
  /// 
  /// Example: fullUrl('/patients/') → 'https://...api/v1/patients/'
  static String fullUrl(String endpoint) => '$baseUrl$endpoint';

  /// Check if endpoint requires authentication
  /// 
  /// Public endpoints (no auth required):
  /// - Signup, Verify OTP, Resend OTP
  /// - Signin, Signin Verify OTP
  /// - Forgot Password, Reset Password
  static bool requiresAuth(String endpoint) {
    final publicEndpoints = [
      authSignup,
      authVerifyOtp,
      authResendOtp,
      authSignin,
      authSigninVerifyOtp,
      authForgotPassword,
      authResetPassword,
    ];
    return !publicEndpoints.contains(endpoint);
  }

  /// Check if endpoint requires multipart/form-data
  /// 
  /// Multipart endpoints (file upload):
  /// - Signup (optional photo)
  /// - Update profile photo
  /// - Start detection (fundus image)
  static bool requiresMultipart(String endpoint) {
    final multipartEndpoints = [
      authSignup,
      authUpdateProfilePhoto,
      detectionsStart,
    ];
    return multipartEndpoints.contains(endpoint);
  }
}