// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/l10n/app_localizations.dart';
import 'data/local/hive_helper.dart';
import 'data/local/shared_prefs_helper.dart';
import 'providers/auth_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/detection_provider.dart';
import 'providers/user_provider.dart';
import 'providers/language_provider.dart';
import 'providers/location_provider.dart';
import 'providers/dashboard_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await HiveHelper.init();
  await HiveHelper.openBoxes();

  // Initialize SharedPreferences
  await SharedPrefsHelper.init();

  // Initialize LanguageProvider
  final languageProvider = LanguageProvider();
  await languageProvider.loadSavedLanguage();

  // ============================================================================
  // ✅ NEW: Initialize AuthProvider and load tokens
  // ============================================================================
  final authProvider = AuthProvider();
  await authProvider.initializeAuth(); // Load tokens from SecureStorage
  debugPrint('✅ [Main] AuthProvider initialized');
  debugPrint('🔍 [Main] isAuthenticated: ${authProvider.isAuthenticated}');
  debugPrint('🔍 [Main] currentUser: ${authProvider.currentUser?.email ?? "null"}');
  // ============================================================================

  runApp(
    MultiProvider(
      providers: [
        // ============================================================================
        // ✅ CHANGED: Use .value instead of create (pass initialized instance)
        // ============================================================================
        ChangeNotifierProvider.value(value: authProvider),
        // ============================================================================
        
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // ✅ NEW: Get authProvider

    // ============================================================================
    // ✅ NEW: Show splash screen while auth is initializing
    // ============================================================================
    if (!authProvider.isInitialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // ============================================================================

    return MaterialApp.router(
      title: 'DR Detection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // ============================================================================
      // LOCALIZATION SETUP
      // ============================================================================

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: AppLocalizations.supportedLocales,

      locale: languageProvider.currentLocale,

      // ============================================================================
      // ROUTER
      // ============================================================================

      routerConfig: AppRouter.router,
    );
  }
}