// lib/widgets/states/empty_detection_state.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';

/// Empty Detection State Widget
///
/// Displays empty state with icon, title, subtitle, and action button
///
/// Usage:
/// ```dart
/// EmptyDetectionState(
///   title: 'No Detections Yet',
///   subtitle: 'Start your first detection',
///   onAction: () => navigateToDetection(),
///   actionLabel: 'Start Detection',
/// )
/// ```
class EmptyDetectionState extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onAction;
  final String? actionLabel;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final bool showButton;

  const EmptyDetectionState({
    super.key,
    required this.title,
    required this.subtitle,
    this.onAction,
    this.actionLabel,
    this.icon = Icons.document_scanner_outlined,
    this.iconColor,
    this.iconBgColor,
    this.showButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Spacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: Spacing.radiusXL,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: iconBgColor ?? AppColors.primaryVeryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor ?? AppColors.primary,
            ),
          ),

          Spacing.verticalXL,

          // Title
          Text(
            title,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          Spacing.verticalSM,

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          // Button (if enabled)
          if (showButton && onAction != null) ...[
            Spacing.verticalLG,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: Spacing.radiusMD,
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  actionLabel ?? 'Start Detection',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms);
  }
}