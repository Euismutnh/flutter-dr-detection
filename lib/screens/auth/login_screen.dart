// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/language_switcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Hide keyboard aman pakai context di awal (synchronous)
    Helpers.hideKeyboard(context);

    if (!_formKey.currentState!.validate()) return;

    // [SOP 1] CAPTURE: Ambil semua alat tempur sebelum perang (Async)
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context); // Capture Router biar navigasi aman
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Catatan: Biasanya method provider return void (throw error jika gagal).
      // Jadi variabel 'success' mungkin tidak perlu jika methodnya void.
      await authProvider.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // --- BATAS ASYNC GAP ---

      // 2. GUNAKAN ROUTER VARIABLE (Bukan context.go)
      // Ini aman dilakukan walau user sudah menutup screen,
      // karena router object masih valid di memori.
      final email = _emailController.text.trim();
      router.go('${RouteNames.otpSignIn}?email=${Uri.encodeComponent(email)}');

      // Opsional: Tampilkan pesan sukses pakai messenger (aman)
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successOtpSent),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      // 3. ERROR HANDLING (Sudah Perfect!)
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorUnknown),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.background),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: Spacing.screenPadding,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: 'app_logo',
                        child: Image.asset(
                          'assets/images/app_logo2.png',
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                      ).animate().scale(
                        duration: 600.ms,
                        curve: Curves.easeOutBack,
                      ),
                      Spacing.verticalXXXL,
                      Column(
                            children: [
                              Text(
                                l10n.welcomeBack,
                                style: AppTextStyles.h1.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Spacing.verticalXS,
                              Text(
                                l10n.signInToContinue,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: 200.ms)
                          .slideY(begin: 0.2, end: 0),
                      Spacing.verticalXL,
                      Container(
                            padding: Spacing.paddingLG,
                            decoration: BoxDecoration(
                              color: AppColors.surface.withValues(alpha: 0.5),
                              borderRadius: Spacing.radiusXL,
                              border: Border.all(
                                color: AppColors.surface.withValues(alpha: 0.6),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadowLight.withValues(
                                    alpha: 0.05,
                                  ),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                EmailTextField(
                                  controller: _emailController,
                                  validator: Validators.email,
                                  onChanged: (_) => setState(() {}),
                                ),
                                Spacing.verticalLG,
                                PasswordTextField(
                                  controller: _passwordController,
                                  validator: Validators.required,
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () =>
                                        context.push(RouteNames.forgotPassword),
                                    child: Text(
                                      l10n.forgotPassword,
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.1, end: 0),
                      Spacing.verticalXL,
                      Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: Spacing.radiusXXL,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: CustomButton(
                                  text: l10n.login,
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  isLoading: authProvider.isLoading,
                                  type: ButtonType.primary,
                                  size: ButtonSize.large,
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideY(begin: 0.1, end: 0),
                      Spacing.verticalLG,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n.noAccount,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(RouteNames.signup),
                            child: Text(
                              l10n.signup,
                              style: AppTextStyles.labelMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 800.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 50, // Jarak dari atas layar
            right: 0, // Jarak dari kanan
            child: const LanguageSwitcher(),
          ),
        ],
      ),
    );
  }
}
