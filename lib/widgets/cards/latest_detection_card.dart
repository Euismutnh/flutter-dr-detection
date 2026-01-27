// lib/widgets/cards/latest_detection_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/helpers.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/detection/detection_model.dart';

/// Latest Detection Card Widget
///
/// Displays detection information in a card with image, classification, confidence
///
/// Usage:
/// ```dart
/// LatestDetectionCard(
///   detection: detectionModel,
///   patientName: 'John Doe',
///   patientCode: 'P001',
///   onViewDetails: () => navigateToDetails(),
/// )
/// ```
class LatestDetectionCard extends StatelessWidget {
  final DetectionModel detection;
  final String patientName;
  final String patientCode;
  final VoidCallback onViewDetails;

  const LatestDetectionCard({
    super.key,
    required this.detection,
    required this.patientName,
    required this.patientCode,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final color = AppColors.getClassificationColor(detection.classification);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fundus Image
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Spacing.radiusXL.topLeft,
              topRight: Spacing.radiusXL.topRight,
            ),
            child: CachedNetworkImage(
              imageUrl: detection.imageUrl,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 180,
                color: AppColors.borderLight,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                height: 180,
                color: AppColors.borderLight,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    size: 48,
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
            ),
          ),

          // Detection Info
          Padding(
            padding: Spacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patientName,
                            style: AppTextStyles.h4.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Spacing.verticalXXS,
                          Text(
                            patientCode,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Spacing.verticalMD,

                // Classification & Confidence
                Row(
                  children: [
                    // Classification Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: Spacing.radiusMD,
                      ),
                      child: Text(
                        detection.predictedLabel,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Confidence
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(detection.confidence * 100).toStringAsFixed(1)}%',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          l10n.confidence,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                Spacing.verticalMD,

                // Eye Side & Date
                Row(
                  children: [
                    Icon(
                      Icons.visibility_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      detection.sideEye,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacing.horizontalMD,
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      Helpers.formatDate(detection.detectedAt),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                Spacing.verticalLG,

                // View Details Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: Spacing.radiusMD,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      l10n.viewDetails,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }
}