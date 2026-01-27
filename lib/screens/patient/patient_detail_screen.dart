// lib/screens/patient/patient_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/patient_provider.dart';
import '../../providers/detection_provider.dart';
import '../../widgets/patient_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/helpers.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/export/export.dart';
import '../../data/models/detection/detection_model.dart';

// ⭐ SIMPLIFIED IMPORTS - No more alias needed!
import '../../widgets/medical_card.dart'; // Contains: StatCard, DetectionCard, etc.

// ⭐ NEW WIDGET IMPORTS
import '../../widgets/cards/latest_detection_card.dart';
import '../../widgets/charts/detection_progress_chart.dart';
import '../../widgets/states/empty_detection_state.dart';
import '../../core/utils/stats_calculator.dart';

class PatientDetailScreen extends StatefulWidget {
  final String patientCode;

  const PatientDetailScreen({super.key, required this.patientCode});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadData();
        _isInitialized = true;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _startNewDetection(BuildContext context) {
    final router = GoRouter.of(context);
    router.push('/detection/start?patientCode=${widget.patientCode}');
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
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
        patientProvider.getPatientByCode(
          widget.patientCode,
          forceRefresh: true,
        ),
        detectionProvider.loadDetections(forceRefresh: true),
      ]);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successDataRefreshed),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          l10n.patientDetails,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: _showExportDialog,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      body: Consumer2<PatientProvider, DetectionProvider>(
        builder: (context, patientProvider, detectionProvider, child) {
          if (patientProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          final patient = patientProvider.selectedPatient;
          if (patient == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.person_off_outlined,
                    size: 64,
                    color: AppColors.textDisabled,
                  ),
                  Spacing.verticalLG,
                  Text(
                    l10n.errorPatientNotFound,
                    style: AppTextStyles.bodyLarge,
                  ),
                  Spacing.verticalLG,
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildPatientHeader(patient, l10n),
              Spacing.verticalLG,
              _buildModernTabBar(l10n),
              Spacing.verticalLG,
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(patient, l10n),
                    _buildHistoryTab(l10n),
                    _buildProgressChartTab(detectionProvider.detections),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPatientHeader(dynamic patient, AppLocalizations l10n) {
    return Container(
      margin: Spacing.paddingLG,
      padding: Spacing.paddingLG,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Spacing.radiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          PatientAvatar(name: patient.name, gender: patient.gender, size: 64),
          Spacing.horizontalMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacing.verticalXXS,
                Text(
                  'ID: ${patient.patientCode}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacing.verticalXS,
                Text(
                  '${patient.gender}, ${patient.age} years (DOB: ${Helpers.formatDate(patient.dateOfBirth)})',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildModernTabBar(AppLocalizations l10n) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Spacing.lg),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Spacing.radiusLG,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: Spacing.radiusMD,
        ),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(fontSize: 13),
        labelPadding: const EdgeInsets.symmetric(horizontal: 8),
        tabAlignment: TabAlignment.fill,
        tabs: [
          Tab(
            height: 42,
            child: Text(
              l10n.overview,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          Tab(
            height: 42,
            child: Text(
              l10n.detectionHistory,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
          Tab(
            height: 42,
            child: Text(
              l10n.progressChart,
              textAlign: TextAlign.center,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildOverviewTab(dynamic patient, AppLocalizations l10n) {
    return Consumer<DetectionProvider>(
      builder: (context, detectionProvider, child) {
        final detections =
            detectionProvider.detections
                ?.where((d) => d.patientCode == patient.patientCode)
                .toList() ??
            [];

        detections.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
        final latestDetection = detections.isNotEmpty ? detections.first : null;
        final avgConfidence = StatsCalculator.calculateAverageConfidence(
          detections,
        );

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: Spacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.assessment_outlined,
                        label: l10n.totalDetections,
                        value: detections.length.toString(),
                        color: AppColors.info,
                      ),
                    ),
                    Spacing.horizontalMD,
                    Expanded(
                      child: StatCard(
                        icon: Icons.verified_outlined,
                        label: 'Average Confidence',
                        value: '${avgConfidence.toStringAsFixed(1)}%',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                Spacing.verticalXL,
                Text(
                  l10n.latestDetection,
                  style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
                ),
                Spacing.verticalMD,
                if (latestDetection != null) ...[
                  LatestDetectionCard(
                    detection: latestDetection,
                    patientName: patient.name,
                    patientCode: patient.patientCode,
                    onViewDetails: () {
                      final router = GoRouter.of(context);
                      router.push('/history/${latestDetection.id}');
                    },
                  ),
                  Spacing.verticalLG,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _startNewDetection(context),
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      label: Text(
                        l10n.startDetection,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else
                  EmptyDetectionState(
                    title: l10n.noDetectionsYet,
                    subtitle: l10n.startFirstDetection,
                    onAction: () => _startNewDetection(context),
                    actionLabel: l10n.startDetection,
                  ),
                Spacing.verticalXXXL,
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(AppLocalizations l10n) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, child) {
        final detections =
            provider.detections
                ?.where((d) => d.patientCode == widget.patientCode)
                .toList() ??
            [];

        detections.sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

        if (provider.isLoadingHistory && detections.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        if (detections.isEmpty) {
          return Center(
            child: EmptyDetectionState(
              title: l10n.noDetectionsYet,
              subtitle: l10n.startFirstDetection,
              onAction: () => _startNewDetection(context),
              actionLabel: l10n.startDetection,
            ),
          );
        }

        return ListView.separated(
          padding: Spacing.paddingLG,
          itemCount: detections.length,
          separatorBuilder: (context, index) => Spacing.verticalMD,
          itemBuilder: (context, index) {
            final detection = detections[index];
            return DetectionCard(
                  patientName: detection.patientName,
                  patientCode: detection.patientCode,
                  classificationLabel: detection.predictedLabel,
                  classification: detection.classification,
                  confidence: detection.confidence,
                  sideEye: detection.sideEye,
                  detectedAt: Helpers.formatDate(detection.detectedAt),
                  imageUrl: detection.imageUrl,
                  compact: true,
                  onTap: () {
                    final router = GoRouter.of(context);
                    router.push('/history/${detection.id}');
                  },
                )
                .animate(delay: (index * 50).ms)
                .fadeIn()
                .slideX(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  Widget _buildProgressChartTab(List<DetectionModel>? allDetections) {
    return Consumer<PatientProvider>(
      builder: (context, patientProvider, child) {
        final patient = patientProvider.selectedPatient;
        if (patient == null) return const SizedBox();

        final detections =
            allDetections
                ?.where((d) => d.patientCode == patient.patientCode)
                .toList() ??
            [];

        detections.sort((a, b) => a.detectedAt.compareTo(b.detectedAt));

        return DetectionProgressChart(detections: detections);
      },
    );
  }

  void _showMoreMenu() {
    final l10n = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: Spacing.radiusXL.topLeft,
            topRight: Spacing.radiusXL.topRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Spacing.verticalMD,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Spacing.verticalLG,
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary,
              ),
              title: Text(l10n.editPatient),
              onTap: () {
                Navigator.pop(context);
                final router = GoRouter.of(context);
                router.push('/patients/edit/${widget.patientCode}');
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.deletePatient,
                style: const TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation();
              },
            ),
            Spacing.verticalMD,
          ],
        ),
      ),
    );
  }

  void _showExportDialog() {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final patient = patientProvider.selectedPatient;

    if (patient != null) {
      showPatientExportDialog(context, patient);
    }
  }

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Spacing.radiusXL),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: Spacing.radiusMD,
              ),
              child: const Icon(Icons.warning, color: AppColors.danger),
            ),
            Spacing.horizontalMD,
            Expanded(child: Text(l10n.deletePatient, style: AppTextStyles.h4)),
          ],
        ),
        content: Text(l10n.deletePatientConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePatient();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePatient() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );

    try {
      await patientProvider.deletePatient(widget.patientCode);

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.patientDeleted),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (mounted) {
        final router = GoRouter.of(context);
        router.pop();
      }
    } on ApiException catch (e) {
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
