// lib/screens/detection/detection_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/patient_provider.dart';
import '../../providers/detection_provider.dart';
import '../../data/models/patient/patient_model.dart';
import '../../widgets/patient_avatar.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class StartDetectionScreen extends StatefulWidget {
  final String? preSelectedPatientCode;

  const StartDetectionScreen({super.key, this.preSelectedPatientCode});

  @override
  State<StartDetectionScreen> createState() => _StartDetectionScreenState();
}

class _StartDetectionScreenState extends State<StartDetectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isInitialized = false;
  bool _isDetecting = false;
  bool _isRetrying = false;

  // Form data
  PatientModel? _selectedPatient;
  String? _eyeSide;

  // UI state
  bool _showPatientDropdown = false;
  List<PatientModel> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(StartDetectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.preSelectedPatientCode != oldWidget.preSelectedPatientCode &&
        widget.preSelectedPatientCode != null) {
      debugPrint(
        '🔄 [DetectionScreen] preSelectedPatientCode changed: '
        '${oldWidget.preSelectedPatientCode} → ${widget.preSelectedPatientCode}',
      );
      _isInitialized = false;
      _loadInitialData();
    }
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );

    try {
      await patientProvider.loadPatients();

      if (widget.preSelectedPatientCode != null && mounted) {
        final patients = patientProvider.patients ?? [];
        final patient = patients
            .where((p) => p.patientCode == widget.preSelectedPatientCode)
            .firstOrNull;

        if (patient != null) {
          setState(() {
            _selectedPatient = patient;
            _searchController.text = '${patient.name} - ${patient.patientCode}';
          });
        }
      }
    } catch (e) {
      debugPrint('⚠️ [StartDetectionScreen] Failed to load patients: $e');
    }
  }

  void _filterPatients(String query) {
    final patientProvider = Provider.of<PatientProvider>(
      context,
      listen: false,
    );
    final patients = patientProvider.patients ?? [];

    setState(() {
      _filteredPatients = query.isEmpty
          ? patients.take(5).toList()
          : patients
                .where(
                  (p) =>
                      p.name.toLowerCase().contains(query.toLowerCase()) ||
                      p.patientCode.toLowerCase().contains(query.toLowerCase()),
                )
                .take(5)
                .toList();
    });
  }

  Future<void> _uploadImage() async {
    final l10n = AppLocalizations.of(context);
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    try {
      await detectionProvider.pickFile();
      await detectionProvider.cropImage();
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      if (mounted) _showError(e.getTranslatedMessageFromL10n(l10n));
    } catch (e) {
      if (mounted) _showError(l10n.errorUnknown);
    }
  }

  void _removeImage() {
    Provider.of<DetectionProvider>(context, listen: false).clearImage();
  }

  void _showAddPatientDialog() {
    GoRouter.of(context).push('/patients/add');
  }

  // ============================================================================
  // START DETECTION
  // ============================================================================

  Future<void> _startDetection() async {
    if (_isDetecting) {
      debugPrint('⚠️ [DetectionScreen] Already detecting, ignore tap');
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _isDetecting = false;
      });
      return;
    }

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (_selectedPatient == null) {
      _showError(l10n.pleaseSelectPatient);
      setState(() {
        _isDetecting = false;
      });
      return;
    }
    if (_eyeSide == null) {
      _showError(l10n.pleaseSelectEyeSide);
      setState(() {
        _isDetecting = false;
      });
      return;
    }

    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    if (!detectionProvider.hasImageReady) {
      _showError(l10n.pleaseUploadAndCropImage);
      setState(() {
        _isDetecting = false;
      });
      return;
    }

    try {
      debugPrint('🚀 [DetectionScreen] Starting detection...');

      await detectionProvider.startDetection(
        patientCode: _selectedPatient!.patientCode,
        sideEye: _eyeSide!,
      );

      debugPrint('✅ [DetectionScreen] Detection completed successfully');

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
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
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnknown),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDetecting = false;
        });
      }
    }
  }

  // ============================================================================
  // RETRY — shows loading dialog while API call runs
  // ============================================================================

  Future<void> _retryDetection() async {
    if (_isRetrying) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    setState(() {
      _isRetrying = true;
    });

    // Show overlay so user knows retry is happening
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => const _RetryLoadingDialog(),
    );

    // Let dialog render before starting work
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      // startDetection() overwrites _sessionId & _previewData internally,
      // and _croppedImageBytes is still valid — so just call it directly.
      debugPrint('🔄 [DetectionScreen] Retrying detection...');

      await detectionProvider.startDetection(
        patientCode: _selectedPatient!.patientCode,
        sideEye: _eyeSide!,
      );

      debugPrint('✅ [DetectionScreen] Retry completed successfully');
    } on ApiException catch (e) {
      if (mounted) {
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
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.errorUnknown),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  // ============================================================================
  // SAVE
  // ============================================================================

  Future<void> _saveDetection() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    if (detectionProvider.previewData == null) return;

    try {
      await detectionProvider.saveDetection();

      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.successDetectionSaved),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
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

  Future<void> _cancelDetection() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
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
          l10n.allUnsavedDataWillBeLost,
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
            ),
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (confirmed == true) {
      final detectionProvider = Provider.of<DetectionProvider>(
        context,
        listen: false,
      );
      detectionProvider.cancelDetection();

      if (mounted) {
        setState(() {
          _selectedPatient = null;
          _eyeSide = null;
          _searchController.clear();
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Consumer<DetectionProvider>(
        builder: (context, detectionProvider, child) {
          final hasResult = detectionProvider.previewData != null;

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Spacing.verticalXXL,
                _buildHeader(l10n),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Spacing.verticalLG,
                        _buildInputSection(l10n, detectionProvider),

                        if (hasResult) ...[
                          Spacing.verticalLG,
                          _buildResultSection(l10n, detectionProvider),
                        ],

                        Spacing.verticalXXXL,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
            l10n.detection,
            style: AppTextStyles.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2, end: 0);
  }

  // ============================================================================
  // INPUT SECTION
  // ============================================================================

  Widget _buildInputSection(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
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
          _buildPatientSelection(l10n),
          Spacing.verticalLG,
          _buildEyeSideSelection(l10n),
          Spacing.verticalLG,
          _buildImageUpload(l10n, detectionProvider),
          Spacing.verticalLG,
          _buildStartButton(l10n, detectionProvider),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.05, end: 0);
  }

  // ============================================================================
  // PATIENT SELECTION
  // ============================================================================

  Widget _buildPatientSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.selectPatient} *',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchPatients,
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _selectedPatient != null
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    onPressed: () => setState(() {
                      _selectedPatient = null;
                      _searchController.clear();
                    }),
                  )
                : null,
          ),
          onTap: () {
            setState(() => _showPatientDropdown = true);
            _filterPatients(_searchController.text);
          },
          onChanged: (value) {
            _filterPatients(value);
            setState(() => _showPatientDropdown = true);
          },
        ),

        if (_showPatientDropdown) ...[
          Spacing.verticalXS,
          Container(
            constraints: const BoxConstraints(maxHeight: 240),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: Spacing.radiusMD,
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._filteredPatients.map(
                  (patient) => ListTile(
                    leading: PatientAvatar(
                      name: patient.name,
                      gender: patient.gender,
                      size: 36,
                    ),
                    title: Text(
                      patient.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      patient.patientCode,
                      style: AppTextStyles.bodySmall,
                    ),
                    onTap: () => setState(() {
                      _selectedPatient = patient;
                      _searchController.text =
                          '${patient.name} - ${patient.patientCode}';
                      _showPatientDropdown = false;
                    }),
                  ),
                ),

                if (_filteredPatients.isEmpty ||
                    _searchController.text.isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Spacing.md,
                      vertical: Spacing.xs,
                    ),
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: Spacing.radiusSM,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      l10n.addNewPatient,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      setState(() => _showPatientDropdown = false);
                      _showAddPatientDialog();
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEyeSideSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.sideEye} *',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,
        Row(
          children: [
            Expanded(child: _buildEyeChip(l10n.leftEye, 'Left')),
            Spacing.horizontalSM,
            Expanded(child: _buildEyeChip(l10n.rightEye, 'Right')),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeChip(String label, String value) {
    final selected = _eyeSide == value;

    return InkWell(
      onTap: () => setState(() => _eyeSide = value),
      borderRadius: Spacing.radiusMD,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 44,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1.5,
          ),
          borderRadius: Spacing.radiusMD,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_rounded,
              size: 18,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            Spacing.horizontalSM,
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // IMAGE UPLOAD
  // ============================================================================

  Widget _buildImageUpload(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final hasImage = detectionProvider.hasImageReady;
    final isLoading =
        detectionProvider.isPicking || detectionProvider.isCropping;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.fundusImage} *',
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,

        if (!hasImage) ...[
          InkWell(
            onTap: isLoading ? null : _uploadImage,
            borderRadius: Spacing.radiusMD,
            child: Container(
              height: 180,
              width: double.maxFinite,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: Spacing.radiusMD,
                border: Border.all(color: AppColors.borderLight, width: 1.5),
              ),
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                          Spacing.verticalMD,
                          Text(
                            detectionProvider.isPicking
                                ? 'Picking image...'
                                : 'Cropping image...',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(Spacing.sm + 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: Spacing.radiusMD,
                          ),
                          child: const Icon(
                            Icons.cloud_upload_rounded,
                            size: 28,
                            color: AppColors.primary,
                          ),
                        ),
                        Spacing.verticalMD,
                        Text(
                          l10n.uploadFundusImage,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacing.verticalXS,
                        Text(
                          l10n.imageCropTo299,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ] else ...[
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: Spacing.radiusMD,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: ClipRRect(
              borderRadius: Spacing.radiusMD,
              child: Image.memory(
                detectionProvider.croppedImageBytes!,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          Spacing.verticalSM,
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 16,
              ),
              Spacing.horizontalSM,
              Expanded(
                child: Text(
                  l10n.imageCroppedReady,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: AppColors.danger,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: l10n.removeImage,
              ),
            ],
          ),
        ],
      ],
    );
  }

  // ============================================================================
  // START BUTTON — gradient pill with shadow (same as DetectionsTodayCard)
  // ============================================================================

  Widget _buildStartButton(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final isProcessing = detectionProvider.isProcessing;
    final disabled = isProcessing || _isDetecting;

    return SizedBox(
      width: double.infinity,
      height: Spacing.buttonHeightMD,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: disabled ? null : AppGradients.primary,
          borderRadius: Spacing.radiusXXL,
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: disabled ? null : _startDetection,
          style: ElevatedButton.styleFrom(
            backgroundColor: disabled
                ? AppColors.primary.withValues(alpha: 0.4)
                : Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: Spacing.radiusXXL),
          ),
          child: (isProcessing || _isDetecting)
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, size: 22),
                    Spacing.horizontalSM,
                    Text(l10n.startDetection, style: AppTextStyles.buttonLarge),
                  ],
                ),
        ),
      ),
    );
  }

  // ============================================================================
  // RESULT SECTION
  // ============================================================================

  Widget _buildResultSection(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final result = detectionProvider.previewData!;
    final classColor = AppColors.getClassificationColor(result.classification);

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
          // ── Result header — gradient banner, same inline card pattern
          //     as home_screen DetectionsTodayCard
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Spacing.md + 2,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.getClassificationGradient(
                result.classification,
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
                        result.predictedLabel,
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

          // ── Body
          Padding(
            padding: Spacing.paddingLG,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fundus image
                if (detectionProvider.croppedImageBytes != null) ...[
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: Spacing.radiusMD,
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: ClipRRect(
                      borderRadius: Spacing.radiusMD,
                      child: Image.memory(
                        detectionProvider.croppedImageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ),
                  Spacing.verticalLG,
                ],

                // Classification badge — left-border card
                // (exact same pattern as home_screen _buildClassificationCard)
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
                            result.predictedLabel,
                            style: AppTextStyles.h3.copyWith(
                              color: classColor,
                              fontWeight: FontWeight.w700,
                              height: 1.0,
                            ),
                          ),
                          Spacing.verticalXXS,
                          Text(
                            '${(result.confidence * 100).toStringAsFixed(1)}% confidence',
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
                  '${(result.confidence * 100).toStringAsFixed(1)}%',
                  Icons.verified_rounded,
                ),
                _buildInfoRow(
                  l10n.sideEye,
                  result.sideEye == 'Right' ? l10n.rightEye : l10n.leftEye,
                  Icons.visibility_rounded,
                ),
                _buildInfoRow(
                  'Detected At',
                  Helpers.formatDateTime(DateTime.now()),
                  Icons.access_time_rounded,
                ),

                Spacing.verticalLG,

                // Action buttons
                _buildActionButtons(l10n, detectionProvider),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.08, end: 0);
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
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ACTION BUTTONS
  // ============================================================================

  Widget _buildActionButtons(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final isSaving = detectionProvider.isSaving;

    return Column(
      children: [
        // Row: Save (gradient pill) + Retry (outlined)
        Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 46,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: isSaving ? null : AppGradients.success,
                    borderRadius: Spacing.radiusXXL,
                    boxShadow: isSaving
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.success.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: isSaving ? null : _saveDetection,
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text(l10n.save),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaving
                          ? AppColors.success.withValues(alpha: 0.4)
                          : Colors.transparent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: Spacing.radiusXXL,
                      ),
                      textStyle: AppTextStyles.labelMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Spacing.horizontalSM,

            Expanded(
              flex: 2,
              child: SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: (isSaving || _isRetrying) ? null : _retryDetection,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.retry),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: Spacing.radiusXXL,
                    ),
                    textStyle: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        Spacing.verticalSM,

        // Cancel — full width, subtle text button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: TextButton.icon(
            onPressed: isSaving ? null : _cancelDetection,
            icon: const Icon(Icons.close_rounded, size: 16),
            label: Text(l10n.cancel),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusXXL),
              textStyle: AppTextStyles.labelSmall.copyWith(
                color: AppColors.danger,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// RETRY LOADING DIALOG
// ============================================================================

class _RetryLoadingDialog extends StatefulWidget {
  const _RetryLoadingDialog();

  @override
  State<_RetryLoadingDialog> createState() => _RetryLoadingDialogState();
}

class _RetryLoadingDialogState extends State<_RetryLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Container(
        padding: EdgeInsets.all(Spacing.xl),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: Spacing.radiusXL,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulsing gradient icon
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final t = _pulseController.value;
                final scale = 1.0 + 0.08 * (t < 0.5 ? t * 2 : (1 - t) * 2);
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Spacing.verticalMD,
            Text(
              l10n.retry,
              style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
            ),
            Spacing.verticalXS,
            Text(
              'Processing...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Spacing.verticalMD,
            SizedBox(
              width: 100,
              child: LinearProgressIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.borderLight,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
