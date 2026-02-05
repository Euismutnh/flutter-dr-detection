// lib/screens/history/detection_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
import '../../data/models/detection/detection_model.dart';

class DetectionDetailScreen extends StatefulWidget {
  final String detectionId;

  const DetectionDetailScreen({super.key, required this.detectionId});

  @override
  State<DetectionDetailScreen> createState() => _DetectionDetailScreenState();
}

class _DetectionDetailScreenState extends State<DetectionDetailScreen> {
  bool _isInitialized = false;
  DetectionModel? _detection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadDetection();
        _isInitialized = true;
      }
    });
  }

  void _loadDetection() {
    if (!mounted) return;

    final provider = Provider.of<DetectionProvider>(context, listen: false);
    final detections = provider.detections ?? [];

    final detection = detections
        .where((d) => d.id.toString() == widget.detectionId)
        .firstOrNull;

    if (detection != null) {
      setState(() => _detection = detection);
      provider.setSelectedDetection(detection);
    }
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
                Icons.delete_outline,
                color: AppColors.danger,
              ),
              title: Text(
                l10n.deleteDetection,
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

  void _showDeleteConfirmation() {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Spacing.radiusXL),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Spacing.sm),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: Spacing.radiusSM,
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: AppColors.danger,
                size: 22,
              ),
            ),
            Spacing.horizontalMD,
            Expanded(child: Text(l10n.confirm, style: AppTextStyles.h4)),
          ],
        ),
        content: Text(
          l10n.deleteDetectionConfirmation,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
            ),
            child: Text(l10n.yesDelete),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    if (_detection == null) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final provider = Provider.of<DetectionProvider>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(Spacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Spacing.radiusXL,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              Spacing.verticalMD,
              Text(l10n.deletingDetection, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ),
    );

    try {
      await provider.deleteDetection(_detection!.id);
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.successDetectionDeleted),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        navigator.pop();
      }
    } on ApiException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(e.getTranslatedMessageFromL10n(l10n)),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnknown),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          l10n.detectionDetails,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showMoreMenu,
          ),
        ],
      ),
      body: _detection == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  Spacing.verticalMD,
                  Text(
                    l10n.loadingData,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: Spacing.paddingLG,
              child: Column(
                children: [
                  // PATIENT INFO CARD (ATAS) — Same as Patient Detail
                  _buildPatientInfoCard(_detection!)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.05, end: 0),

                  Spacing.verticalLG,

                  // DETECTION RESULT CARD — Same as Detection Screen
                  _buildDetectionResultCard(
                    _detection!,
                    l10n,
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.05, end: 0),

                  Spacing.verticalXXL,
                ],
              ),
            ),
    );
  }

  // Patient Info Card — Exact copy from Patient Detail header
  Widget _buildPatientInfoCard(DetectionModel detection) {
    return Container(
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
          PatientAvatar(
            name: detection.patientName,
            gender: detection.patientGender,
            size: 64,
          ),
          Spacing.horizontalMD,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detection.patientName,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Spacing.verticalXXS,
                Text(
                  'ID: ${detection.patientCode}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Spacing.verticalXS,
                Text(
                  '${detection.patientGender}, ${detection.patientAge} years',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Detection Result Card — Same structure as Detection Screen result section
  Widget _buildDetectionResultCard(
    DetectionModel detection,
    AppLocalizations l10n,
  ) {
    final classColor = AppColors.getClassificationColor(
      detection.classification,
    );

    return Container(
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
      child: Column(
        children: [
          // Header Banner — Gradient
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md + 2,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.getClassificationGradient(
                detection.classification,
              ),
              borderRadius: Spacing.customRadius(topLeft: 20, topRight: 20),
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
                    Icons.medical_services_rounded,
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
                        l10n.detectionResult,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Spacing.verticalXXS,
                      Text(
                        detection.predictedLabel,
                        style: AppTextStyles.h3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: Spacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fundus Image with Zoom
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: Spacing.radiusMD,
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: ClipRRect(
                    borderRadius: Spacing.radiusMD,
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: CachedNetworkImage(
                        imageUrl: detection.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: AppColors.background,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.background,
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: AppColors.textDisabled,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacing.verticalLG,

                // Classification Badge — Left-border card style
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: Spacing.sm + 4,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: Spacing.radiusMD,
                    border: Border(
                      left: BorderSide(color: classColor, width: 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        color: classColor,
                        size: 20,
                      ),
                      Spacing.horizontalSM,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            detection.predictedLabel,
                            style: AppTextStyles.h3.copyWith(
                              color: classColor,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          Spacing.verticalXXS,
                          Text(
                            '${(detection.confidence * 100).toStringAsFixed(1)}% confidence',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Spacing.verticalLG,

                // Info rows
                _buildInfoRow(
                  l10n.confidence,
                  '${(detection.confidence * 100).toStringAsFixed(1)}%',
                  Icons.verified_rounded,
                ),
                _buildInfoRow(
                  l10n.sideEye,
                  detection.sideEye == 'Right' ? l10n.rightEye : l10n.leftEye,
                  Icons.visibility_rounded,
                ),
                _buildInfoRow(
                  l10n.detectedAt,
                  Helpers.formatDateTime(detection.detectedAt),
                  Icons.access_time_rounded,
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Spacing.sm - 2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: Spacing.radiusSM,
            ),
            child: Icon(icon, size: 17, color: AppColors.textSecondary),
          ),
          Spacing.horizontalSM,
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
