// lib/screens/patient/patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/patient_provider.dart';
import '../../widgets/medical_card.dart'; // ✅ Gunakan PatientCard dari medical_card.dart
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/patient/patient_model.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();

  // Filter state
  String _selectedGender = 'All';
  int? _minAge;
  int? _maxAge;

  @override
  void initState() {
    super.initState();
    // Load patients on screen init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatients();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients({bool forceRefresh = false}) async {
    if (!mounted) return;

    // [SOP 1] CAPTURE: l10n, messenger BEFORE async
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final provider = Provider.of<PatientProvider>(context, listen: false);

    try {
      await provider.loadPatients(forceRefresh: forceRefresh);
    } on ApiException catch (e) {
      // [SOP 2] USE: messenger variable (BUKAN ScaffoldMessenger.of(context))
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
    await _loadPatients(forceRefresh: true);
  }

  void _showAgeRangeDialog() {
    final l10n = AppLocalizations.of(context);
    final minController = TextEditingController(
      text: _minAge?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxAge?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.filter, style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Min Age Input
            TextField(
              controller: minController,
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
                border: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            Spacing.verticalMD,
            // Max Age Input
            TextField(
              controller: maxController,
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
                border: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.border, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: Spacing.radiusLG,
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _minAge = null;
                _maxAge = null;
              });
              Navigator.pop(context);
            },
            child: Text(
              l10n.clear,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel, style: AppTextStyles.labelMedium),
          ),
          ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              final min = int.tryParse(minController.text);
              final max = int.tryParse(maxController.text);

              if (min != null && max != null && min > max) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.ageRangeError),
                    backgroundColor: AppColors.danger,
                  ),
                );
                return;
              }

              setState(() {
                _minAge = min;
                _maxAge = max;
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  List<PatientModel> _getFilteredPatients(List<PatientModel> patients) {
    var filtered = patients;

    // Filter by gender
    if (_selectedGender != 'All') {
      filtered = filtered
          .where((p) => p.gender.toLowerCase() == _selectedGender.toLowerCase())
          .toList();
    }

    
    if (_minAge != null) {
      filtered = filtered.where((p) => p.age! >= _minAge!).toList();
    }
    if (_maxAge != null) {
      filtered = filtered.where((p) => p.age! <= _maxAge!).toList();
    }

    // Filter by search query
    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((p) {
        return p.name.toLowerCase().contains(query) ||
            p.patientCode.toLowerCase().contains(query);
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

                _buildSearchBar(l10n),

                Spacing.verticalMD,

                _buildFilterChips(l10n),

                Spacing.verticalMD,

                _buildPatientList(l10n),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton:
          FloatingActionButton(
            onPressed: () {
              context.push(RouteNames.addPatient); 
            },
            backgroundColor: AppColors.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ).animate().scale(
            delay: 600.ms,
            duration: 300.ms,
            curve: Curves.easeOutBack,
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
            l10n.patients,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Padding(
      padding: Spacing.paddingLG.copyWith(top: 0, bottom: 0),
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
                    icon: Icon(Icons.clear, color: AppColors.textSecondary),
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
    ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final hasAgeFilter = _minAge != null || _maxAge != null;
    final ageFilterText = hasAgeFilter
        ? '${_minAge ?? '0'} - ${_maxAge ?? '∞'} ${l10n.age}'
        : l10n.age;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: Spacing.paddingLG.copyWith(top: 0, bottom: 0),
      child: Row(
        children: [
          _buildFilterChip(
            label: l10n.all,
            isSelected: _selectedGender == 'All',
            onTap: () => setState(() => _selectedGender = 'All'),
          ),
          Spacing.horizontalSM,
          _buildFilterChip(
            label: l10n.male,
            isSelected: _selectedGender == 'Male',
            onTap: () => setState(() => _selectedGender = 'Male'),
          ),
          Spacing.horizontalSM,
          _buildFilterChip(
            label: l10n.female,
            isSelected: _selectedGender == 'Female',
            onTap: () => setState(() => _selectedGender = 'Female'),
          ),
          Spacing.horizontalSM,
          _buildFilterChip(
            label: ageFilterText,
            isSelected: hasAgeFilter,
            onTap: _showAgeRangeDialog,
            icon: Icons.calendar_today,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0);
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primary : null,
          color: isSelected ? null : AppColors.surface.withValues(alpha: 0.7),
          borderRadius: Spacing.radiusXXL,
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : AppColors.border.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              Spacing.horizontalXS,
            ],
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientList(AppLocalizations l10n) {
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && (provider.patients?.isEmpty ?? true)) {
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

        // Error state (no cache available)
        if ((provider.patients?.isEmpty ?? true) && !provider.isLoading) {
          return _buildEmptyState(l10n);
        }

        // Filter patients
        final filteredPatients = _getFilteredPatients(provider.patients ?? []);

        // No results after filtering
        if (filteredPatients.isEmpty) {
          return _buildNoResultsState(l10n);
        }

        return ListView.separated(
          shrinkWrap: true, // ✅ TAMBAH INI
          physics: const NeverScrollableScrollPhysics(), // ✅ TAMBAH INI
          padding: Spacing.paddingLG,
          itemCount: filteredPatients.length,
          separatorBuilder: (context, index) => Spacing.verticalMD,
          itemBuilder: (context, index) {
            final patient = filteredPatients[index];
            return _buildPatientCard(patient, index)
                .animate(delay: (index * 50).ms)
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0);
          },
        );
      },
    );
  }

  Widget _buildPatientCard(PatientModel patient, int index) {
    return PatientCard(
      patientCode: patient.patientCode,
      patientName: patient.name,
      gender: patient.gender,
      age: patient.age??0,
      lastDetectionDate: Helpers.formatDate(patient.updatedAt),
      compact: true,
      onTap: () {
        final router = GoRouter.of(context);
        router.push('/patients/${patient.patientCode}');
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
                gradient: AppGradients.primary.scale(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.people_outline,
                size: 80,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
            ),
            Spacing.verticalXL,
            Text(
              l10n.noPatients, // ✅ Gunakan l10n
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            Spacing.verticalSM,
            Text(
              l10n.addFirstPatient, // ✅ Gunakan l10n
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            Spacing.verticalXL,
            ElevatedButton.icon(
              onPressed: () {
                // CAPTURE router BEFORE navigation
                final router = GoRouter.of(context);
                router.push(RouteNames.addPatient);
              },
              icon: const Icon(Icons.add),
              label: Text(l10n.addPatient), // ✅ Gunakan l10n
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 600.ms).scale(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildNoResultsState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: Spacing.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: AppColors.textDisabled),
            Spacing.verticalMD,
            Text(
              l10n.noSearchResults,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
              textAlign: TextAlign.center,
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
    ).animate().fadeIn();
  }
}
