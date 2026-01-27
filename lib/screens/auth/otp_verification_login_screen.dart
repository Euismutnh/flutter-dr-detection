// lib/screens/auth/otp_verification_login_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:pinput/pinput.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class OtpLoginScreen extends StatefulWidget {
  final String email;

  const OtpLoginScreen({super.key, required this.email});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _timer;
  int _remainingSeconds = AppConstants.otpExpiryMinutes * 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _canResend = false;
      _remainingSeconds = AppConstants.otpExpiryMinutes * 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text;
    if (otp.length != 6) return;

    // [SOP 1] CAPTURE
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context); // Capture Router
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // [SOP 2] ASYNC
      await authProvider.verifyLoginOtp(email: widget.email, otp: otp);

      // [SOP 3] SUCCESS
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successSignin),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigasi aman pakai 'router' variable
      router.go(RouteNames.home);
    } on ApiException catch (e) {
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

  Future<void> _handleResendOtp() async {
    // [SOP 1] CAPTURE
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      _startTimer(); // Timer lokal (synchronous), aman.

      // [SOP 2] ASYNC
      await authProvider.login(
        email: widget.email,
        password: '',
      ); // Logic resend

      // [SOP 3] SUCCESS
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.resendOtp),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
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

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyles.h2.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: Spacing.radiusLG,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
    );
    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.danger, width: 2),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.background),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: Spacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Spacing.verticalMD,
                        Center(
                          child: Hero(
                            tag: 'otp_icon',
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: AppGradients.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.mark_email_read_rounded,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                        Spacing.verticalXL,
                        Text(
                              l10n.otpVerification,
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                              ),
                              textAlign: TextAlign.center,
                            )
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .slideY(begin: 0.2, end: 0),
                        Spacing.verticalSM,
                        Text(
                          l10n.otpSentTo,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Spacing.verticalXS,
                        Text(
                          widget.email,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 300.ms),
                        Spacing.verticalXXL,
                        Container(
                              padding: Spacing.paddingLG,
                              decoration: BoxDecoration(
                                color: AppColors.surface.withValues(alpha: 0.5),
                                borderRadius: Spacing.radiusXL,
                                border: Border.all(
                                  color: AppColors.surface.withValues(
                                    alpha: 0.6,
                                  ),
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
                                children: [
                                  Pinput(
                                    controller: _otpController,
                                    focusNode: _focusNode,
                                    length: AppConstants.otpLength,
                                    defaultPinTheme: defaultPinTheme,
                                    focusedPinTheme: focusedPinTheme,
                                    submittedPinTheme: submittedPinTheme,
                                    errorPinTheme: errorPinTheme,
                                    pinputAutovalidateMode:
                                        PinputAutovalidateMode.onSubmit,
                                    showCursor: true,
                                    autofocus: true,
                                    onCompleted: (_) => _handleVerifyOtp(),
                                  ),
                                  Spacing.verticalLG,
                                  if (!_canResend)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                        Spacing.horizontalXS,
                                        Text(
                                          '${l10n.resendCodeIn} $_formattedTime',
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                color: AppColors.textSecondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ],
                                    )
                                  else
                                    Consumer<AuthProvider>(
                                      builder: (context, authProvider, child) {
                                        return TextButton.icon(
                                          onPressed: authProvider.isLoading
                                              ? null
                                              : _handleResendOtp,
                                          icon: const Icon(
                                            Icons.refresh_rounded,
                                            size: 18,
                                          ),
                                          label: Text(l10n.resendOtp),
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.primary,
                                            textStyle: AppTextStyles.labelMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            )
                            .animate()
                            .fadeIn(delay: 400.ms)
                            .slideY(begin: 0.2, end: 0),
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
                                    text: l10n.verifyProceed,
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _handleVerifyOtp,
                                    isLoading: authProvider.isLoading,
                                    type: ButtonType.primary,
                                    size: ButtonSize.large,
                                    icon: Icons.arrow_forward_rounded,
                                    iconRight: true,
                                  ),
                                );
                              },
                            )
                            .animate()
                            .fadeIn(delay: 600.ms)
                            .slideY(begin: 0.2, end: 0),
                        Spacing.verticalLG,
                        Text(
                          l10n.checkSpam,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 800.ms),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
