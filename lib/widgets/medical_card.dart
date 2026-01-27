// lib/widgets/medical_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/constants/spacing.dart';

/// Medical Card Widget
/// Modern card with subtle shadow and rounded corners
class MedicalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;
  final bool showShadow;

  const MedicalCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.border,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? Spacing.paddingMD,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          borderRadius: borderRadius ?? Spacing.radiusMD,
          border: border,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}

/// Patient Card Widget (for list items)
/// Displays patient info with avatar, name, code, and status
///
/// Set [compact] = true for smaller version (HomeScreen dashboard)
class PatientCard extends StatelessWidget {
  final String patientCode;
  final String patientName;
  final String gender;
  final int age;
  final String? lastDetectionDate;
  final String? classificationLabel;
  final int? classification;
  final VoidCallback? onTap;
  final bool compact; 

  const PatientCard({
    super.key,
    required this.patientCode,
    required this.patientName,
    required this.gender,
    required this.age,
    this.lastDetectionDate,
    this.classificationLabel,
    this.classification,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return MedicalCard(
      onTap: onTap,
      padding: compact ? EdgeInsets.all(Spacing.sm + 4) : Spacing.paddingMD,
      child: Row(
        children: [
          // Avatar with gender-based gradient
          _buildAvatar(),

          compact ? Spacing.horizontalSM : Spacing.horizontalMD,

          // Patient Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Name
                Text(
                  patientName,
                  style: compact
                      ? AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        )
                      : const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                compact ? Spacing.verticalXXS : Spacing.verticalXS,

                // Compact: Single line info | Full: Multiple lines
                if (compact)
                  Text(
                    '$patientCode • $gender, $age yrs',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  )
                else ...[
                  // Patient Code
                  Text(
                    'ID: $patientCode',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  Spacing.verticalXS,

                  // Gender & Age
                  Row(
                    children: [
                      Icon(
                        gender.toLowerCase() == 'male'
                            ? Icons.male
                            : Icons.female,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$gender, $age yrs',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),

                  if (lastDetectionDate != null) ...[
                    Spacing.verticalXS,
                    Text(
                      'Last Detection: $lastDetectionDate',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          // Classification Badge (if available) - Only in full mode
          if (!compact &&
              classificationLabel != null &&
              classification != null) ...[
            Spacing.horizontalSM,
            _buildClassificationBadge(),
          ],

          // Chevron icon
          Spacing.horizontalSM,
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textDisabled,
            size: compact ? Spacing.iconMD : 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = patientName
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');

    final isMale = gender.toLowerCase() == 'male';
    final gradientColors = isMale
        ? [const Color(0xFF3B82F6), const Color(0xFF60A5FA)]
        : [const Color(0xFFEC4899), const Color(0xFFF472B6)];

    final size = compact ? 44.0 : 56.0;
    final fontSize = compact ? 16.0 : 20.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.3),
            blurRadius: compact ? 8 : 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildClassificationBadge() {
    final color = AppColors.getClassificationColor(classification!);
    final bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        classificationLabel!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Detection Card Widget (for detection history)
///
/// Set [compact] = true for smaller version (HomeScreen dashboard)
class DetectionCard extends StatelessWidget {
  final String patientName;
  final String patientCode;
  final String classificationLabel;
  final int classification;
  final double confidence;
  final String sideEye;
  final String detectedAt;
  final DateTime? detectedAtDateTime; // NEW: For relative time in compact mode
  final String? imageUrl;
  final VoidCallback? onTap;
  final bool compact; // NEW: For HomeScreen compact mode

  const DetectionCard({
    super.key,
    required this.patientName,
    required this.patientCode,
    required this.classificationLabel,
    required this.classification,
    required this.confidence,
    required this.sideEye,
    required this.detectedAt,
    this.detectedAtDateTime,
    this.imageUrl,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactCard();
    }
    return _buildFullCard();
  }

  /// Compact version for HomeScreen - with fundus image thumbnail
  /// ✅ COMPACT version with Date inline (48x48 image, 2 lines)
  /// Line 1: Patient Name
  /// Line 2: Classification + Confidence + Date (all inline!)
  Widget _buildCompactCard() {
    final color = AppColors.getClassificationColor(classification);

    return MedicalCard(
      onTap: onTap,
      padding: EdgeInsets.all(Spacing.sm + 4), // 12dp padding
      child: Row(
        children: [
          // Fundus Image Thumbnail (48x48)
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.borderLight,
                      child: const Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 48,
                      height: 48,
                      color: AppColors.borderLight,
                      child: const Icon(Icons.image_not_supported, size: 20),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.visibility_outlined,
                      color: color,
                      size: 22,
                    ),
                  ),
          ),

          Spacing.horizontalSM,

          // Detection Info (2 lines: Name, Classification+Confidence+Date)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Line 1: Patient Name
                Text(
                  patientName,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 4),

                // Line 2: Classification + Confidence + Date (ALL INLINE!)
                Row(
                  children: [
                    // Classification Badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Spacing.xs + 2,
                        vertical: Spacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        classificationLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 6),
                    
                    // Confidence
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    
                    const SizedBox(width: 6),
                    
                    // Bullet separator
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppColors.textDisabled,
                        fontSize: 11,
                      ),
                    ),
                    
                    const SizedBox(width: 6),
                    
                    // Date (inline with confidence!)
                    Flexible(
                      child: Text(
                        detectedAt,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron Icon
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textDisabled,
            size: Spacing.iconMD,
          ),
        ],
      ),
    );
  }

  /// Full version for History List
  Widget _buildFullCard() {
    return MedicalCard(
      onTap: onTap,
      padding: Spacing.paddingMD,
      child: Row(
        children: [
          // Fundus Image Thumbnail
          if (imageUrl != null)
            ClipRRect(
              borderRadius: Spacing.radiusMD,
              child: CachedNetworkImage(
                imageUrl: imageUrl!,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.borderLight,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported, size: 24),
                ),
              ),
            ),

          Spacing.horizontalMD,

          // Detection Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Patient Name
                Text(
                  patientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                Spacing.verticalXS,

                // Patient Code
                Text(
                  patientCode,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),

                Spacing.verticalSM,

                // Classification Badge & Confidence
                Row(
                  children: [
                    _buildClassificationBadge(),
                    Spacing.horizontalSM,
                    Text(
                      '${confidence.toStringAsFixed(1)}% Conf.',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                Spacing.verticalXS,

                // Side Eye & Date
                Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sideEye,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Spacing.horizontalSM,
                    Text(
                      detectedAt,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Chevron
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationBadge() {
    final color = AppColors.getClassificationColor(classification);
    final bgColor = color.withValues(alpha: 0.1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        classificationLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Stat Card Widget (for dashboard statistics)
/// Modern Stat Card Widget
/// 
/// Reusable card for displaying statistics with icon, value, and label
/// with animation support
///
/// Usage:
/// ```dart
/// StatCard(
///   icon: Icons.assessment_outlined,
///   label: 'Total Detections',
///   value: '15',
///   color: AppColors.info,
/// )
/// ```
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color? bgColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: Spacing.paddingMD,
      decoration: BoxDecoration(
        color: bgColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon container
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: Spacing.radiusSM,
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          Spacing.verticalSM,

          // Value
          Text(
            value,
            style: AppTextStyles.h2.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          Spacing.verticalXXS,

          // Label
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    // Wrap with InkWell if onTap provided
    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: card,
      );
    }

    return card;
  }
}


/// Classification Stat Card Widget
class ClassificationStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const ClassificationStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: Spacing.paddingMD,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: Spacing.radiusLG,
          border: Border(left: BorderSide(color: color, width: 6)),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: color,
                height: 1.0,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}