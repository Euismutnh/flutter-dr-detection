// lib/features/export/widgets/export_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/spacing.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/utils/helpers.dart';

import '../../../providers/patient_provider.dart';
import '../../../providers/detection_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';

import '../../../data/models/patient/patient_model.dart';

import '../export_service.dart';

/// Export type options for Profile Screen (all data)
enum ExportAllType {
  patientsPdf,
  patientsExcel,
  detectionsPdf,
  detectionsExcel,
  fullReportPdf,
}

/// Export type options for Patient Detail Screen (per patient)
enum ExportPatientType { reportPdf, detectionsPdf, detectionsExcel }

/// Show export dialog for all data (from Profile Screen)
Future<void> showExportDialog(BuildContext context) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => const _ExportAllDialog(),
  );
}

/// Show export dialog for specific patient (from Patient Detail Screen)
Future<void> showPatientExportDialog(
  BuildContext context,
  PatientModel patient,
) async {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => _PatientExportDialog(patient: patient),
  );
}

// ============================================================================
// EXPORT ALL DIALOG (for Profile Screen)
// ============================================================================

class _ExportAllDialog extends StatefulWidget {
  const _ExportAllDialog();

  @override
  State<_ExportAllDialog> createState() => _ExportAllDialogState();
}

class _ExportAllDialogState extends State<_ExportAllDialog> {
  bool _isExporting = false;
  ExportAllType? _exportingType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: Spacing.paddingSM,
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: Spacing.paddingLG,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  Spacing.horizontalMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.exportData, style: AppTextStyles.h4),
                        Text(
                          'Choose export format',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Spacing.verticalLG,

            // Export options
            Padding(
              padding: Spacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patients section
                  _buildSectionHeader('Patients Data'),
                  Spacing.verticalSM,
                  Row(
                    children: [
                      Expanded(
                        child: _buildExportButton(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          sublabel: 'All Patients',
                          color: AppColors.danger,
                          type: ExportAllType.patientsPdf,
                        ),
                      ),
                      Spacing.horizontalSM,
                      Expanded(
                        child: _buildExportButton(
                          icon: Icons.table_chart_rounded,
                          label: 'Excel',
                          sublabel: 'All Patients',
                          color: AppColors.success,
                          type: ExportAllType.patientsExcel,
                        ),
                      ),
                    ],
                  ),

                  Spacing.verticalLG,

                  // Detections section
                  _buildSectionHeader('Detections Data'),
                  Spacing.verticalSM,
                  Row(
                    children: [
                      Expanded(
                        child: _buildExportButton(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          sublabel: 'All Detections',
                          color: AppColors.danger,
                          type: ExportAllType.detectionsPdf,
                        ),
                      ),
                      Spacing.horizontalSM,
                      Expanded(
                        child: _buildExportButton(
                          icon: Icons.table_chart_rounded,
                          label: 'Excel',
                          sublabel: 'All Detections',
                          color: AppColors.success,
                          type: ExportAllType.detectionsExcel,
                        ),
                      ),
                    ],
                  ),

                  Spacing.verticalLG,

                  // Full report
                  _buildSectionHeader('Complete Report'),
                  Spacing.verticalSM,
                  _buildFullReportButton(),
                ],
              ),
            ),

            Spacing.verticalXL,
          ],
        ),
      ),
    ).animate().slideY(
      begin: 0.3,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSecondary),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required ExportAllType type,
  }) {
    final isLoading = _isExporting && _exportingType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => _handleExport(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: Spacing.paddingMD,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      )
                    : Icon(icon, color: color, size: 20),
              ),
              Spacing.horizontalSM,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullReportButton() {
    final isLoading =
        _isExporting && _exportingType == ExportAllType.fullReportPdf;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading
            ? null
            : () => _handleExport(ExportAllType.fullReportPdf),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: Spacing.paddingMD,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primaryLight.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(
                        Icons.summarize_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
              Spacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Full Report (PDF)',
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
                      'Summary + All Patients + All Detections',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(ExportAllType type) async {
    setState(() {
      _isExporting = true;
      _exportingType = type;
    });

    try {
      final exportService = ExportService();
      final patientProvider = context.read<PatientProvider>();
      final detectionProvider = context.read<DetectionProvider>();
      final dashboardProvider = context.read<DashboardProvider>();
      final authProvider = context.read<AuthProvider>();

      final operator = authProvider.currentUser!;

      // Load data if needed
      if (patientProvider.patients == null ||
          patientProvider.patients!.isEmpty) {
        await patientProvider.loadPatients();
      }
      if (detectionProvider.detections == null ||
          detectionProvider.detections!.isEmpty) {
        await detectionProvider.loadDetections();
      }

      final patients = patientProvider.patients ?? [];
      final detections = detectionProvider.detections ?? [];

      // Handle each export type explicitly (no default case = no dead code)
      switch (type) {
        case ExportAllType.patientsPdf:
          await exportService.exportAllPatientsPdf(patients, operator);
        case ExportAllType.patientsExcel:
          await exportService.exportPatientsExcel(patients);
        case ExportAllType.detectionsPdf:
          await exportService.exportDetectionsPdf(detections, operator);
        case ExportAllType.detectionsExcel:
          await exportService.exportDetectionsExcel(detections);
        case ExportAllType.fullReportPdf:
          await exportService.exportFullReportPdf(
            patients,
            detections,
            operator,
            dashboardProvider.totalDetections,
          );
      }

      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackbar(
          context,
          'Export successful! File ready to share.',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Export failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });
      }
    }
  }
}

// ============================================================================
// PATIENT EXPORT DIALOG (for Patient Detail Screen)
// ============================================================================

class _PatientExportDialog extends StatefulWidget {
  final PatientModel patient;

  const _PatientExportDialog({required this.patient});

  @override
  State<_PatientExportDialog> createState() => _PatientExportDialogState();
}

class _PatientExportDialogState extends State<_PatientExportDialog> {
  bool _isExporting = false;
  ExportPatientType? _exportingType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: Spacing.paddingSM,
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: Spacing.paddingLG,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryVeryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.download_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  Spacing.horizontalMD,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.exportDataPatient, style: AppTextStyles.h4),
                        Text(
                          widget.patient.name,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Spacing.verticalLG,

            // Export options
            Padding(
              padding: Spacing.paddingLG,
              child: Column(
                children: [
                  // Full patient report
                  _buildExportOption(
                    icon: Icons.description_rounded,
                    title: 'Patient Report (PDF)',
                    subtitle:
                        'Patient info + detection history + recommendations',
                    color: AppColors.primary,
                    type: ExportPatientType.reportPdf,
                  ),

                  Spacing.verticalMD,

                  // Detection history PDF
                  _buildExportOption(
                    icon: Icons.picture_as_pdf_rounded,
                    title: 'Detection History (PDF)',
                    subtitle: 'Table of all detections for this patient',
                    color: AppColors.danger,
                    type: ExportPatientType.detectionsPdf,
                  ),

                  Spacing.verticalMD,

                  // Detection history Excel
                  _buildExportOption(
                    icon: Icons.table_chart_rounded,
                    title: 'Detection History (Excel)',
                    subtitle: 'Raw data for analysis',
                    color: AppColors.success,
                    type: ExportPatientType.detectionsExcel,
                  ),
                ],
              ),
            ),

            Spacing.verticalXL,
          ],
        ),
      ),
    ).animate().slideY(
      begin: 0.3,
      end: 0,
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildExportOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required ExportPatientType type,
  }) {
    final isLoading = _isExporting && _exportingType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => _handleExport(type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: Spacing.paddingMD,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
              ),
              Spacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleExport(ExportPatientType type) async {
    setState(() {
      _isExporting = true;
      _exportingType = type;
    });

    try {
      final exportService = ExportService();
      final detectionProvider = context.read<DetectionProvider>();
      final authProvider = context.read<AuthProvider>();

      final operator = authProvider.currentUser!;

      // Get detections for this patient
      final allDetections = detectionProvider.detections ?? [];
      final detections = allDetections
          .where((d) => d.patientCode == widget.patient.patientCode)
          .toList();

      // Handle each export type explicitly (no default case = no dead code)
      switch (type) {
        case ExportPatientType.reportPdf:
          await exportService.exportPatientReportPdf(
            widget.patient,
            detections,
            operator,
          );
        case ExportPatientType.detectionsPdf:
          await exportService.exportDetectionsPdf(
            detections,
            operator,
            patient: widget.patient,
          );
        case ExportPatientType.detectionsExcel:
          await exportService.exportDetectionsExcel(
            detections,
            patient: widget.patient,
          );
      }

      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackbar(
          context,
          'Export successful! File ready to share.',
        );
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Export failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
          _exportingType = null;
        });
      }
    }
  }
}
