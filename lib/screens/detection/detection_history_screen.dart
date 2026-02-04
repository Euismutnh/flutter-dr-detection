// lib/screens/detection/detection_history_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/detection_provider.dart';
import '../../widgets/medical_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/detection/detection_model.dart';

class DetectionHistoryScreen extends StatefulWidget {
  const DetectionHistoryScreen({super.key});

  @override
  State<DetectionHistoryScreen> createState() => _DetectionHistoryScreenState();
}

class _DetectionHistoryScreenState extends State<DetectionHistoryScreen> {
  final _searchController = TextEditingController();

  // Filter state — initialized to show ALL
  int? _selectedClassification; // null = All
  String _selectedGender = 'All';
  int? _minAge;
  int? _maxAge;
  String? _selectedPeriod; // null = All

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDetections();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDetections({bool forceRefresh = false}) async {
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<DetectionProvider>(context, listen: false);

    try {
      // Apply filters to provider BEFORE loading
      provider.setClassificationFilter(_selectedClassification);
      provider.setGenderFilter(
        _selectedGender == 'All' ? null : _selectedGender,
      );
      provider.setAgeRangeFilter(_minAge, _maxAge);
      provider.setPeriodFilter(_selectedPeriod);

      await provider.loadDetections(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.danger),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorUnknown),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _loadDetections(forceRefresh: true);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterDialog(
        initialClassification: _selectedClassification,
        initialGender: _selectedGender,
        initialMinAge: _minAge,
        initialMaxAge: _maxAge,
        initialPeriod: _selectedPeriod,
        onApply: (classification, gender, minAge, maxAge, period) {
          setState(() {
            _selectedClassification = classification;
            _selectedGender = gender;
            _minAge = minAge;
            _maxAge = maxAge;
            _selectedPeriod = period;
          });
          _loadDetections(forceRefresh: true);
        },
        onReset: () {
          setState(() {
            _selectedClassification = null;
            _selectedGender = 'All';
            _minAge = null;
            _maxAge = null;
            _selectedPeriod = null;
          });
          _loadDetections(forceRefresh: true);
        },
      ),
    );
  }

  bool get _hasActiveFilters {
    return _selectedClassification != null ||
        _selectedGender != 'All' ||
        _minAge != null ||
        _maxAge != null ||
        _selectedPeriod != null;
  }

  List<DetectionModel> _getFilteredDetections(List<DetectionModel> detections) {
    var filtered = detections;

    // Local search filter (by patient name or code)
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((d) {
        return d.patientName.toLowerCase().contains(query) ||
            d.patientCode.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                Spacing.verticalMD,

                _buildHeader(l10n),

                Spacing.verticalMD,

                _buildSearchAndFilter(l10n),

                if (_hasActiveFilters) ...[
                  Spacing.verticalMD,
                  _buildActiveFilters(l10n),
                ],

                Spacing.verticalMD,

                _buildDetectionList(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Padding(
      padding: Spacing.paddingLG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.detectionHistory,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchAndFilter(AppLocalizations l10n) {
    return Padding(
      padding: Spacing.paddingLG.copyWith(top: 0, bottom: 0),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.7),
                borderRadius: Spacing.radiusLG,
                border: Border.all(
                  color: AppColors.surface.withValues(alpha: 0.6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadowLight.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() {}),
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: l10n.searchPatients,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textDisabled,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                    size: Spacing.iconMD,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          Spacing.horizontalSM,

          // Filter button with badge
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: Spacing.radiusMD,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _showFilterDialog,
                    borderRadius: Spacing.radiusMD,
                    child: Padding(
                      padding: EdgeInsets.all(Spacing.sm + 2),
                      child: Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: Spacing.iconMD,
                      ),
                    ),
                  ),
                ),
              ),
              // Active filter badge
              if (_hasActiveFilters)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildActiveFilters(AppLocalizations l10n) {
    final filters = <Widget>[];

    if (_selectedClassification != null) {
      filters.add(
        _buildActiveFilterChip(
          label: AppConstants.drClassifications[_selectedClassification]!,
          color: AppColors.getClassificationColor(_selectedClassification!),
          onRemove: () {
            setState(() => _selectedClassification = null);
            _loadDetections(forceRefresh: true);
          },
        ),
      );
    }

    if (_selectedGender != 'All') {
      filters.add(
        _buildActiveFilterChip(
          label: _selectedGender,
          color: AppColors.primary,
          onRemove: () {
            setState(() => _selectedGender = 'All');
            _loadDetections(forceRefresh: true);
          },
        ),
      );
    }

    if (_minAge != null || _maxAge != null) {
      filters.add(
        _buildActiveFilterChip(
          label: '${_minAge ?? '0'} - ${_maxAge ?? '∞'} yrs',
          color: AppColors.primary,
          onRemove: () {
            setState(() {
              _minAge = null;
              _maxAge = null;
            });
            _loadDetections(forceRefresh: true);
          },
        ),
      );
    }

    if (_selectedPeriod != null) {
      filters.add(
        _buildActiveFilterChip(
          label: AppConstants.periodLabels[_selectedPeriod]!,
          color: AppColors.primary,
          onRemove: () {
            setState(() => _selectedPeriod = null);
            _loadDetections(forceRefresh: true);
          },
        ),
      );
    }

    return Padding(
      padding: Spacing.paddingLG.copyWith(top: 0, bottom: 0),
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: filters,
      ),
    );
  }

  Widget _buildActiveFilterChip({
    required String label,
    required Color color,
    required VoidCallback onRemove,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.sm + 2,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: Spacing.radiusMD,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacing.horizontalXS,
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectionList(AppLocalizations l10n) {
    return Consumer<DetectionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingHistory &&
            (provider.detections?.isEmpty ?? true)) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Spacing.verticalMD,
                Text(
                  l10n.loadingData,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if ((provider.detections?.isEmpty ?? true) &&
            !provider.isLoadingHistory) {
          return _buildEmptyState(l10n);
        }

        final filteredDetections = _getFilteredDetections(
          provider.detections ?? [],
        );

        if (filteredDetections.isEmpty) {
          return _buildNoResultsState(l10n);
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: Spacing.paddingLG,
          itemCount: filteredDetections.length,
          separatorBuilder: (context, index) => Spacing.verticalMD,
          itemBuilder: (context, index) {
            final detection = filteredDetections[index];
            return _buildDetectionCard(detection, index)
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0);
          },
        );
      },
    );
  }

  Widget _buildDetectionCard(DetectionModel detection, int index) {
    return DetectionCard(
      patientName: detection.patientName,
      patientCode: detection.patientCode,
      classificationLabel: detection.predictedLabel,
      classification: detection.classification,
      confidence: detection.confidence,
      sideEye: detection.sideEye,
      detectedAt: Helpers.formatDateTime(detection.detectedAt),
      detectedAtDateTime: detection.detectedAt,
      imageUrl: detection.imageUrl,
      compact: true, // ← COMPACT MODE same as Patient List
      onTap: () {
        final router = GoRouter.of(context);
        router.push('/history/${detection.id}');
      },
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: Spacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.document_scanner_outlined,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            Spacing.verticalXL,
            Text(
              l10n.noDataFound,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacing.verticalMD,
            Text(
              l10n.tryDifferentKeywords,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: Spacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.textDisabled),
            Spacing.verticalLG,
            Text(
              l10n.noDataFound,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            Spacing.verticalSM,
            Text(
              l10n.tryDifferentKeywords,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// FILTER DIALOG — Full-screen modal with expandable sections
// ============================================================================

class _FilterDialog extends StatefulWidget {
  final int? initialClassification;
  final String initialGender;
  final int? initialMinAge;
  final int? initialMaxAge;
  final String? initialPeriod;
  final Function(int?, String, int?, int?, String?) onApply;
  final VoidCallback onReset;

  const _FilterDialog({
    required this.initialClassification,
    required this.initialGender,
    required this.initialMinAge,
    required this.initialMaxAge,
    required this.initialPeriod,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late int? _classification;
  late String _gender;
  late int? _minAge;
  late int? _maxAge;
  late String? _period;

  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _classification = widget.initialClassification;
    _gender = widget.initialGender;
    _minAge = widget.initialMinAge;
    _maxAge = widget.initialMaxAge;
    _period = widget.initialPeriod;

    _minAgeController.text = _minAge?.toString() ?? '';
    _maxAgeController.text = _maxAge?.toString() ?? '';
  }

  @override
  void dispose() {
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _handleApply() {
    final l10n = AppLocalizations.of(context);

    // Validate age range
    final min = int.tryParse(_minAgeController.text);
    final max = int.tryParse(_maxAgeController.text);

    if (min != null && max != null && min > max) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.ageRangeError),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    widget.onApply(_classification, _gender, min, max, _period);
    Navigator.pop(context);
  }

  void _handleReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.scaffoldBackground,
            borderRadius: Spacing.customRadius(topLeft: 20, topRight: 20),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: Spacing.paddingLG,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: Spacing.customRadius(topLeft: 20, topRight: 20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                      color: AppColors.textPrimary,
                    ),
                    Text(
                      l10n.filter,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _handleReset,
                      child: Text(
                        l10n.reset,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.danger,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: Spacing.paddingLG,
                  children: [
                    _buildClassificationSection(l10n),
                    Spacing.verticalLG,
                    _buildGenderSection(l10n),
                    Spacing.verticalLG,
                    _buildAgeRangeSection(l10n),
                    Spacing.verticalLG,
                    _buildPeriodSection(l10n),
                    Spacing.verticalXXL,
                  ],
                ),
              ),

              // Apply Button
              Container(
                padding: Spacing.paddingLG,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: Spacing.buttonHeightLG -5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: Spacing.radiusXXL,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _handleApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: Spacing.radiusXXL,
                        ),
                      ),
                      child: Text(l10n.apply, style: AppTextStyles.buttonLarge),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassificationSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.classification,
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          _buildFilterChip(
            label: l10n.all,
            isSelected: _classification == null,
            onTap: () => setState(() => _classification = null),
          ),
          ...List.generate(5, (index) {
            return _buildFilterChip(
              label: AppConstants.drClassifications[index]!,
              isSelected: _classification == index,
              color: AppColors.getClassificationColor(index),
              onTap: () => setState(() => _classification = index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGenderSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.gender,
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          _buildFilterChip(
            label: l10n.all,
            isSelected: _gender == 'All',
            onTap: () => setState(() => _gender = 'All'),
          ),
          _buildFilterChip(
            label: l10n.male,
            isSelected: _gender == 'Male',
            onTap: () => setState(() => _gender = 'Male'),
          ),
          _buildFilterChip(
            label: l10n.female,
            isSelected: _gender == 'Female',
            onTap: () => setState(() => _gender = 'Female'),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeRangeSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.age,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _minAgeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                labelText: l10n.minAge,
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
            ),
          ),
          Spacing.horizontalMD,
          Expanded(
            child: TextField(
              controller: _maxAgeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                labelText: l10n.maxAge,
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSection(AppLocalizations l10n) {
    return _buildSection(
      title: l10n.period,
      child: Wrap(
        spacing: Spacing.sm,
        runSpacing: Spacing.sm,
        children: [
          _buildFilterChip(
            label: l10n.all,
            isSelected: _period == null,
            onTap: () => setState(() => _period = null),
          ),
          ...AppConstants.periodOptions.map((key) {
            return _buildFilterChip(
              label: AppConstants.periodLabels[key]!,
              isSelected: _period == key,
              onTap: () => setState(() => _period = key),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: Spacing.paddingMD,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Spacing.verticalMD,
          child,
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm - 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: Spacing.radiusXXL,
          border: Border.all(
            color: isSelected ? chipColor : AppColors.border,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? chipColor : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
