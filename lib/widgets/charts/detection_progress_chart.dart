// lib/widgets/charts/detection_progress_chart.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/chart_helper.dart';
import '../../core/utils/stats_calculator.dart';
import '../../data/models/detection/detection_model.dart';
import 'chart_filter_widget.dart';
import 'chart_legend.dart';

/// Detection Progress Chart Widget
///
/// Complete chart widget with filters, line chart, legend, and stats
///
/// Usage:
/// ```dart
/// DetectionProgressChart(
///   detections: allDetections,
/// )
/// ```
class DetectionProgressChart extends StatefulWidget {
  final List<DetectionModel> detections;

  const DetectionProgressChart({
    super.key,
    required this.detections,
  });

  @override
  State<DetectionProgressChart> createState() =>
      _DetectionProgressChartState();
}

class _DetectionProgressChartState extends State<DetectionProgressChart> {
  String _chartFilter = 'all';
  DateTime? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // Filter detections based on selected filter
    final filteredDetections = ChartHelper.filterDetectionsByPeriod(
      widget.detections,
      _chartFilter,
      _selectedMonth,
    );

    return SingleChildScrollView(
      padding: Spacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chart Title
          Text(
            l10n.progressChart,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          Spacing.verticalSM,
          Text(
            l10n.trackClassification,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          Spacing.verticalXL,

          // Filter Options
          ChartFilterWidget(
            selectedFilter: _chartFilter,
            selectedMonth: _selectedMonth,
            onFilterChanged: (filter) {
              setState(() {
                _chartFilter = filter;
                if (filter == 'month') {
                  _selectedMonth = DateTime.now();
                }
              });
            },
          ),

          Spacing.verticalLG,

          // Show empty state if no data in filter
          if (filteredDetections.isEmpty)
            _buildEmptyState(l10n)
          else ...[
            // Line Chart
            Container(
              height: 300,
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
              child: _buildLineChart(filteredDetections),
            ),

            Spacing.verticalXL,

            // Legend
            ChartLegend.drClassification(
              title: 'Classification Legend',
            ),

            Spacing.verticalXL,

            // Statistics Summary
            _buildStatsSummary(filteredDetections, l10n),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_alt_off,
                size: 48,
                color: AppColors.info,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noDetectionsInPeriod,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.tryDifferentPeriod,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _chartFilter = 'all';
                  _selectedMonth = null;
                });
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.showAllData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<DetectionModel> detections) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: ChartHelper.prepareChartData(detections),
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        minY: ChartHelper.getMinY(),
        maxY: ChartHelper.getMaxY(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final labels = ChartHelper.getClassificationLabels();
                if (value.toInt() >= 0 && value.toInt() < labels.length) {
                  return SideTitleWidget(
                    meta: meta,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        labels[value.toInt()],
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: detections.length > 10 ? 2 : 1,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < detections.length) {
                  final detection = detections[value.toInt()];
                  final date = detection.detectedAt;
                  
                  // Format: "Jan 23" or "Feb 12"
                  const months = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
                  ];
                  final monthStr = months[date.month - 1];
                  final dayStr = date.day.toString();
                  
                  return SideTitleWidget(
                    meta: meta,
                    angle: -0.5, // Slight angle for better readability
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$monthStr $dayStr',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.borderLight,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            left: BorderSide(color: AppColors.borderLight),
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (touchedSpot) => AppColors.textPrimary,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final detection = detections[spot.x.toInt()];
                return LineTooltipItem(
                  '${detection.predictedLabel}\n${(detection.confidence * 100).toStringAsFixed(1)}%',
                  AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [],
                  textAlign: TextAlign.center,
                );
              }).toList();
            },
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).scale(delay: 300.ms);
  }

  Widget _buildStatsSummary(
    List<DetectionModel> detections,
    AppLocalizations l10n,
  ) {
    final avgConfidence =
        StatsCalculator.calculateAverageConfidence(detections);
    final breakdown = StatsCalculator.getClassificationBreakdown(detections);

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
        children: [
          Text(
            'Statistics Summary',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.verticalMD,
          _buildStatRow(
            l10n.totalDetections,
            detections.length.toString(),
          ),
          _buildStatRow(
            'Average Confidence',
            '${avgConfidence.toStringAsFixed(1)}%',
          ),
          
          // Classification Breakdown
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Classification Breakdown',
            style: AppTextStyles.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatRow('No DR', '${breakdown[0]} cases'),
          _buildStatRow('Mild NPDR', '${breakdown[1]} cases'),
          _buildStatRow('Moderate NPDR', '${breakdown[2]} cases'),
          _buildStatRow('Severe NPDR', '${breakdown[3]} cases'),
          _buildStatRow('Proliferative DR', '${breakdown[4]} cases'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}