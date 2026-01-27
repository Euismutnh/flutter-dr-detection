// lib/core/routes/route_names.dart

class RouteNames {
  RouteNames._();
  
  // ============================================================================
  // AUTH ROUTES
  // ============================================================================
  static const String login = '/login';
  static const String signup = '/signup';
  static const String otpSignUp = '/otp-verification-signup';
  static const String otpSignIn = '/otp-verification-signin';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  
  // ============================================================================
  // MAIN ROUTES (Bottom Navigation)
  // ============================================================================
  static const String home = '/home';
  static const String patients = '/patients';
  static const String detection = '/detection';
  static const String history = '/history';
  static const String profile = '/profile';
  
  // ============================================================================
  // PATIENT ROUTES
  // ============================================================================
  static const String addPatient = '/patients/add';
  static const String editPatient = '/patients/:code/edit'; // Path parameter
  static const String patientDetail = '/patients/:code'; // Path parameter
  
  // ============================================================================
  // DETECTION ROUTES
  // ============================================================================
  static const String startDetection = '/detection/start';
  static const String detectionDetail = '/history/:id'; // Path parameter
  
  // ============================================================================
  // PROGRESS CHART
  // ============================================================================
  static const String progressChart = '/patients/:patientId/progress'; // Path parameter
  
  // ============================================================================
  // PROFILE ROUTES
  // ============================================================================
  static const String editProfile = '/profile/edit';
}