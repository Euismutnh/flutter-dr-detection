// lib/core/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/otp_verification_login_screen.dart';
import '../../screens/auth/otp_verification_signup_screen.dart';
import '../../screens/auth/forgot_password_screen.dart';
import '../../screens/auth/reset_password_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/patient/patient_list_screen.dart';
import '../../screens/patient/patient_detail_screen.dart';
import '../../screens/patient/add_patient_screen.dart';
import '../../screens/patient/edit_patient_screen.dart';
import '../../screens/detection/detection_screen.dart';
import '../../screens/detection/detection_history_screen.dart';
import '../../screens/detection/detection_detail_screen.dart';
import '../../screens/detection/progress_chart_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../../widgets/scaffold_with_navbar.dart';
import 'route_names.dart';

/// App Router Configuration using GoRouter
/// Handles all navigation, authentication guards, and deep linking
class AppRouter {
  AppRouter._();

  /// Global navigator key for programmatic navigation
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Router configuration
  static GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    initialLocation: RouteNames.login,

    // ============================================================================
    // REDIRECT LOGIC (Authentication Guard)
    // ============================================================================
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = authProvider.isAuthenticated;

      // Public routes that don't require authentication
      final publicRoutes = [
        RouteNames.login,
        RouteNames.signup,
        RouteNames.otpSignUp,
        RouteNames.otpSignIn,
        RouteNames.forgotPassword,
        RouteNames.resetPassword,
      ];

      final isGoingToPublicRoute =
          publicRoutes.contains(state.matchedLocation) ||
          state.matchedLocation.startsWith('/otp-verification') ||
          state.matchedLocation.startsWith('/reset-password');

      // If not logged in and trying to access protected route → redirect to login
      if (!isLoggedIn && !isGoingToPublicRoute) {
        return RouteNames.login;
      }

      // If logged in and trying to access login/signup → redirect to home
      if (isLoggedIn &&
          (state.matchedLocation == RouteNames.login ||
              state.matchedLocation == RouteNames.signup)) {
        return RouteNames.home;
      }

      return null;
    },

    // ============================================================================
    // ERROR HANDLING
    // ============================================================================
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri}" does not exist',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),

    // ============================================================================
    // ROUTES DEFINITION
    // ============================================================================
    routes: [
      // ========================================================================
      // AUTH ROUTES (Public - No authentication required)
      // ========================================================================
      GoRoute(
        path: RouteNames.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: RouteNames.signup,
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),

      GoRoute(
        path: RouteNames.otpSignUp,
        name: 'otp-verification-signup',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpSignUpScreen(email: email);
        },
      ),

      GoRoute(
        path: RouteNames.otpSignIn,
        name: 'otp-verification-signin',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          return OtpLoginScreen(email: email);
        },
      ),

      GoRoute(
        path: RouteNames.forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      GoRoute(
        path: RouteNames.resetPassword,
        name: 'reset-password',
        builder: (context, state) {
          final email = state.uri.queryParameters['email'] ?? '';
          final otp = state.uri.queryParameters['otp'] ?? '';
          return ResetPasswordScreen(email: email, otp: otp);
        },
      ),

      // ========================================================================
      // MAIN APP WITH BOTTOM NAVIGATION BAR
      // ========================================================================
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // BRANCH 0: HOME
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // BRANCH 1: PATIENTS
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.patients, // '/patients'
                builder: (context, state) => const PatientListScreen(),

                routes: [
                  // Add Patient
                  GoRoute(
                    path: 'add', // '/patients/add'
                    name: 'add_patient',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const AddPatientScreen(),
                  ),

                  // Patient Detail
                  GoRoute(
                    path: ':code', // '/patients/:code'
                    name: 'patient_detail',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final patientCode = state.pathParameters['code'] ?? '';
                      return PatientDetailScreen(patientCode: patientCode);
                    },
                  ),

                  // Edit Patient
                  GoRoute(
                    path: ':code/edit', // '/patients/:code/edit'
                    name: 'edit_patient',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final patientCode = state.pathParameters['code'] ?? '';
                      return EditPatientScreen(patientCode: patientCode);
                    },
                  ),
                ],
              ),
            ],
          ),

          // BRANCH 2: DETECTION (Center button)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.detection,
                name: 'detection',
                builder: (context, state) {
                  // Support pre-selection via query parameter
                  return const StartDetectionScreen(
                    key: ValueKey('tab_detection'), 
                  );
                },
              ),
            ],
          ),

          // BRANCH 3: HISTORY
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.history,
                name: 'history',
                builder: (context, state) => const DetectionHistoryScreen(),
              ),
            ],
          ),

          // BRANCH 4: PROFILE
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteNames.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/detection/start', 
        name: 'start-detection-direct',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final patientCode = state.uri.queryParameters['patientCode'];

          return StartDetectionScreen(
            key: ValueKey('detection_$patientCode'), 
            preSelectedPatientCode: patientCode,
          );
        },
      ),

      // ========================================================================
      // DETAIL ROUTES (Full screen without bottom nav)
      // These use parentNavigatorKey to show without navbar
      // ========================================================================

      /// Patient Detail Screen
      GoRoute(
        path: RouteNames.patientDetail,
        name: 'patient-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final patientCode = state.pathParameters['code'] ?? '';
          return PatientDetailScreen(patientCode: patientCode);
        },
      ),

      /// Add Patient Screen

      /// Edit Patient Screen
      GoRoute(
        path: RouteNames.editPatient,
        name: 'edit-patient',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final patientCode = state.pathParameters['code'] ?? '';
          return EditPatientScreen(patientCode: patientCode);
        },
      ),

      

      /// Detection Detail Screen
      GoRoute(
        path: RouteNames.detectionDetail,
        name: 'detection-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final detectionId =
              int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return DetectionDetailScreen(detectionId: detectionId);
        },
      ),

      /// Progress Chart Screen
      GoRoute(
        path: RouteNames.progressChart,
        name: 'progress-chart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final patientId =
              int.tryParse(state.pathParameters['patientId'] ?? '0') ?? 0;
          return ProgressChartScreen(patientId: patientId);
        },
      ),

      /// Edit Profile Screen
      GoRoute(
        path: RouteNames.editProfile,
        name: 'edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );

  // ============================================================================
  // HELPER METHODS FOR PROGRAMMATIC NAVIGATION
  // ============================================================================

  static void goToLogin(BuildContext context) {
    context.go(RouteNames.login);
  }

  static void goToHome(BuildContext context) {
    context.go(RouteNames.home);
  }

  static void goToPatientDetail(BuildContext context, String patientCode) {
    context.push('/patients/$patientCode');
  }

  static void goToEditPatient(BuildContext context, String patientCode) {
    context.push('/patients/$patientCode/edit');
  }

  static void goToDetectionDetail(BuildContext context, int detectionId) {
    context.push('/history/$detectionId');
  }

  static void goToProgressChart(BuildContext context, int patientId) {
    context.push('/patients/$patientId/progress');
  }

  static void goToOtpVerificationSignUp(BuildContext context, String email) {
    context.go('${RouteNames.otpSignUp}?email=${Uri.encodeComponent(email)}');
  }

  static void goToOtpVerificationSignIn(BuildContext context, String email) {
    context.go('${RouteNames.otpSignIn}?email=${Uri.encodeComponent(email)}');
  }

  static void goToResetPassword(
    BuildContext context,
    String email,
    String otp,
  ) {
    context.go(
      '${RouteNames.resetPassword}?email=${Uri.encodeComponent(email)}&otp=$otp',
    );
  }

  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  static void goBackToHome(BuildContext context) {
    context.go(RouteNames.home);
  }
}
