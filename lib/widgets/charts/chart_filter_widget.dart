// lib/widgets/charts/chart_filter_widget.dart

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/chart_helper.dart';

/// Chart Filter Widget
///
/// Provides filter options for chart data (All, Year, Month)
///
/// Usage:
/// ```dart
/// ChartFilterWidget(
///   selectedFilter: 'all',
///   selectedMonth: DateTime.now(),
///   onFilterChanged: (filter) => setState(() => _filter = filter),
/// )
/// ```
class ChartFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final DateTime? selectedMonth;
  final ValueChanged<String> onFilterChanged;

  const ChartFilterWidget({
    super.key,
    required this.selectedFilter,
    this.selectedMonth,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter label
          Text(
            '${l10n.filterBy}:',
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          // Filter chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterChip(
                label: l10n.all,
                value: 'all',
                isSelected: selectedFilter == 'all',
                onTap: () => onFilterChanged('all'),
              ),
              _FilterChip(
                label: l10n.lastYear,
                value: 'year',
                isSelected: selectedFilter == 'year',
                onTap: () => onFilterChanged('year'),
              ),
              _FilterChip(
                label: l10n.thisMonth,
                value: 'month',
                isSelected: selectedFilter == 'month',
                onTap: () => onFilterChanged('month'),
              ),
            ],
          ),

          // Show selected month info if filter is 'month'
          if (selectedFilter == 'month' && selectedMonth != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${l10n.showing}: ${ChartHelper.getMonthName(selectedMonth!.month)} ${selectedMonth!.year}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Filter Chip (Private widget)
class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}