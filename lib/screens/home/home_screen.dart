// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/patient_provider.dart';
import '../../providers/detection_provider.dart';
import '../../widgets/patient_avatar.dart';
import '../../widgets/medical_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/greeting_helper.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    try {
      await Future.wait([
        dashboardProvider.loadDashboardStats(),
        patientProvider.loadPatients(),
        detectionProvider.loadDetections(),
      ]);
    } catch (e) {
      debugPrint('⚠️ [HomeScreen] Some data failed to load: $e');
    }
  }

  Future<void> _refreshData() async {
    if (!mounted) return;

    // 1. CAPTURE (Sudah Benar)
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    try {
      // 2. ASYNC (Sudah Benar)
      await Future.wait([
        dashboardProvider.refreshDashboardStats(),
        patientProvider.refreshPatients(),
        detectionProvider.refreshDetections(),
      ]);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successDataRefreshed), // Pakai l10n variable
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      // 4. ERROR (Sudah Benar - Perfect!)
      final message = e.getTranslatedMessageFromL10n(l10n);

      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // 5. GENERIC ERROR (Sudah Benar - Perfect!)
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorUnknown),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      debugPrint('⚠️ [HomeScreen] Refresh failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            children: [
              // ===== HEADER + FLOATING CARDS =====
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipPath(
                    clipper: _HeaderClipper(),
                    child: _buildHeaderBackground(context),
                  ),
                  Positioned(
                    left: Spacing.lg,
                    right: Spacing.lg,
                    top: MediaQuery.of(context).padding.top + 100,
                    child: _buildFloatingSummaryCards(context),
                  ),
                ],
              ),

              // Spacer untuk floating cards
              Spacing.verticalXXXL,
              Spacing.verticalXL,

              // ===== CONTENT =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetectionsTodayCard(context),
                    Spacing.verticalXL,
                    _buildClassificationSection(context),
                    Spacing.verticalXL,
                    _buildRecentPatientsSection(context),
                    Spacing.verticalXL,
                    _buildRecentDetectionsSection(context),
                    // Bottom safe area for navbar
                    Spacing.verticalXXXL,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // HEADER BACKGROUND (Curved)
  // ============================================================================

  Widget _buildHeaderBackground(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final greeting = GreetingHelper.getGreeting(context);
        final displayName = user != null
            ? GreetingHelper.getDisplayNameWithTitle(
                context,
                user.fullName,
                profession: user.profession,
              )
            : 'User';

        return Container(
          width: double.infinity,
          height: 220,
          decoration: const BoxDecoration(gradient: AppGradients.primary),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: UserAvatar(
                      name: user?.fullName ?? 'User',
                      size: Spacing.avatarMD + 4,
                      imageUrl: user?.photoUrl,
                      showBorder: false,
                      onTap: () => context.push(RouteNames.profile),
                    ),
                  ),

                  Spacing.horizontalMD,

                  // Greeting
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Spacing.verticalXS,
                        Text(
                          '$greeting,',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Spacing.verticalXXS,
                        Text(
                          displayName,
                          style: AppTextStyles.h4.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).animate().fadeIn(duration: 300.ms);
  }

  // ============================================================================
  // FLOATING SUMMARY CARDS
  // ============================================================================

  Widget _buildFloatingSummaryCards(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.people_rounded,
                iconBgColor: AppColors.primary.withValues(alpha: 0.1),
                iconColor: AppColors.primary,
                value: '${dashboardProvider.totalPatients}',
                label: l10n.totalPatients,
                onTap: () => context.go(RouteNames.patients),
              ),
            ),
            Spacing.horizontalSM,
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.document_scanner_rounded,
                iconBgColor: const Color(0xFFFCE7F3),
                iconColor: const Color(0xFFEC4899),
                value: '${dashboardProvider.totalDetections}',
                label: l10n.totalDetections,
                onTap: () => context.go(RouteNames.history),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.2, end: 0);
      },
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String value,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Spacing.paddingMD,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Spacing.radiusXL,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.sm + 2),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: Spacing.radiusMD,
              ),
              child: Icon(icon, color: iconColor, size: Spacing.iconMD - 2),
            ),
            Spacing.verticalMD,
            Text(
              value,
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                height: 1.0,
              ),
            ),
            Spacing.verticalXS,
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // DETECTIONS TODAY CARD
  // ============================================================================

  Widget _buildDetectionsTodayCard(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        return GestureDetector(
          onTap: () => context.go(RouteNames.history),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md + 2,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.primary,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(Spacing.sm + 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: Spacing.radiusMD,
                  ),
                  child: Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: Spacing.iconMD - 2,
                  ),
                ),
                Spacing.horizontalMD,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.detectionsToday,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacing.verticalXXS,
                      Text(
                        '${dashboardProvider.detectionsToday}',
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: Spacing.iconMD - 2,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.15, end: 0);
      },
    );
  }

  // ============================================================================
  // DR CLASSIFICATION SECTION
  // ============================================================================

  Widget _buildClassificationSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final breakdown = dashboardProvider.breakdown;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.drDistribution,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Spacing.verticalMD,
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              mainAxisSpacing: Spacing.sm + 2,
              crossAxisSpacing: Spacing.sm + 2,
              childAspectRatio: 2.7,
              children: [
                _buildClassificationCard(
                  label: AppConstants.drClassifications[0]!,
                  value: '${breakdown?.noDr ?? 0}',
                  color: AppColors.getClassificationColor(0),
                  delay: 0,
                ),
                _buildClassificationCard(
                  label: AppConstants.drClassifications[1]!,
                  value: '${breakdown?.mild ?? 0}',
                  color: AppColors.getClassificationColor(1),
                  delay: 1,
                ),
                _buildClassificationCard(
                  label: AppConstants.drClassifications[2]!,
                  value: '${breakdown?.moderate ?? 0}',
                  color: AppColors.getClassificationColor(2),
                  delay: 2,
                ),
                _buildClassificationCard(
                  label: AppConstants.drClassifications[3]!,
                  value: '${breakdown?.severe ?? 0}',
                  color: AppColors.getClassificationColor(3),
                  delay: 3,
                ),
                _buildClassificationCard(
                  label: AppConstants.drClassifications[4]!,
                  value: '${breakdown?.proliferative ?? 0}',
                  color: AppColors.getClassificationColor(4),
                  delay: 4,
                ),
                _buildTotalCard(
                  label: l10n.total,
                  value: '${breakdown?.total ?? 0}',
                  color: AppColors.primary,
                  delay: 5,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildClassificationCard({
    required String label,
    required String value,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm + 4,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Spacing.radiusMD,
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
            ),
          ),
          Spacing.verticalXXS,
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ).animate(delay: (40 * delay).ms).fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildTotalCard({
    required String label,
    required String value,
    required int delay,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md + 2,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryVertical,
        borderRadius: Spacing.radiusMD,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1.0,
            ),
          ),
          Spacing.verticalXXS,
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate(delay: (40 * delay).ms).fadeIn().slideX(begin: 0.05, end: 0);
  }

  // ============================================================================
  // RECENT PATIENTS SECTION - Using PatientCard from medical_card.dart
  // ============================================================================

  Widget _buildRecentPatientsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        final patients = patientProvider.patients ?? [];
        final recentPatients = patients.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: l10n.recentPatients,
              onSeeAll: () => context.go(RouteNames.patients),
            ),
            Spacing.verticalMD,
            if (patientProvider.isLoading && patients.isEmpty)
              _buildListShimmer()
            else if (recentPatients.isEmpty)
              _buildEmptyState(
                icon: Icons.people_outline,
                message: l10n.noDataFound,
              )
            else
              ...recentPatients.asMap().entries.map((entry) {
                final index = entry.key;
                final patient = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm),
                  child:
                      PatientCard(
                            patientCode: patient.patientCode,
                            patientName: patient.name,
                            gender: patient.gender,
                            age: patient.age??0,
                            compact: true,
                            onTap: () => context.push(
                              '/patients/${patient.patientCode}',
                            ),
                          )
                          .animate(delay: (50 * index).ms)
                          .fadeIn()
                          .slideX(begin: 0.03, end: 0),
                );
              }),
          ],
        );
      },
    );
  }

  // ============================================================================
  // RECENT DETECTIONS SECTION - Using DetectionCard from medical_card.dart
  // ============================================================================

  Widget _buildRecentDetectionsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<DetectionProvider>(
      builder: (context, detectionProvider, child) {
        final detections = detectionProvider.detections ?? [];
        final recentDetections = detections.take(5).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
              title: l10n.recentDetections,
              onSeeAll: () => context.go(RouteNames.history),
            ),
            Spacing.verticalMD,
            if (detectionProvider.isLoadingHistory && detections.isEmpty)
              _buildListShimmer()
            else if (recentDetections.isEmpty)
              _buildEmptyState(
                icon: Icons.document_scanner_outlined,
                message: l10n.noDataFound,
              )
            else
              ...recentDetections.asMap().entries.map((entry) {
                final index = entry.key;
                final detection = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: Spacing.sm),
                  child:
                      DetectionCard(
                            patientName: detection.patientName,
                            patientCode: detection.patientCode,
                            classificationLabel: detection.predictedLabel,
                            classification: detection.classification,
                            confidence: detection.confidence,
                            sideEye: detection.sideEye,
                            detectedAt: Helpers.formatDateTime(
                              detection.detectedAt,
                            ),
                            detectedAtDateTime: detection.detectedAt,
                            imageUrl:
                                detection.imageUrl,
                            compact: true,
                            onTap: () =>
                                context.push('/history/${detection.id}'),
                          )
                          .animate(delay: (50 * index).ms)
                          .fadeIn()
                          .slideX(begin: 0.03, end: 0),
                );
              }),
          ],
        );
      },
    );
  }

  // ============================================================================
  // COMMON WIDGETS
  // ============================================================================

  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeAll,
  }) {
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Row(
            children: [
              Text(
                l10n.seeAll,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacing.horizontalXS,
              Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.primary,
                size: Spacing.iconSM,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: Spacing.xl,
        horizontal: Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Spacing.radiusMD,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: Spacing.iconXL, color: AppColors.textDisabled),
          Spacing.verticalSM,
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox({required double height}) {
    return Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.borderLight,
            borderRadius: Spacing.radiusMD,
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.5));
  }

  Widget _buildListShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: Spacing.sm),
          child: _buildShimmerBox(height: 70),
        ),
      ),
    );
  }
}

// ============================================================================
// CUSTOM CLIPPER FOR CURVED HEADER
// ============================================================================

class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
