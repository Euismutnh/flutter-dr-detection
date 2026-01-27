// lib/widgets/charts/chart_legend.dart

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';

/// Chart Legend Widget
///
/// Displays color-coded legend for classification chart
///
/// Usage:
/// ```dart
/// ChartLegend(
///   title: 'Classification Legend',
///   items: [
///     LegendItem('No DR', AppColors.success),
///     LegendItem('Mild NPDR', AppColors.warning),
///   ],
/// )
/// ```
class ChartLegend extends StatelessWidget {
  final String? title;
  final List<LegendItem> items;

  const ChartLegend({
    super.key,
    this.title,
    required this.items,
  });

  /// Default DR classification legend
  factory ChartLegend.drClassification({String? title}) {
    return ChartLegend(
      title: title ?? 'Classification Legend',
      items: [
        LegendItem('No DR', AppColors.success),
        LegendItem('Mild NPDR', AppColors.warning),
        LegendItem('Moderate NPDR', const Color(0xFFFFA726)),
        LegendItem('Severe NPDR', const Color(0xFFFF7043)),
        LegendItem('Proliferative DR', AppColors.danger),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          if (title != null) ...[
            Text(
              title!,
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Spacing.verticalMD,
          ],

          // Legend items
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: items.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Color indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Label
                  Text(
                    item.label,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Legend Item Model
class LegendItem {
  final String label;
  final Color color;

  const LegendItem(this.label, this.color);
}