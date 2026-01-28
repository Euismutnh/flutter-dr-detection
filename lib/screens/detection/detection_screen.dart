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

    // Reload when preSelectedPatientCode changes
    if (widget.preSelectedPatientCode != oldWidget.preSelectedPatientCode &&
        widget.preSelectedPatientCode != null) {
      debugPrint(
        '🔄 [DetectionScreen] preSelectedPatientCode changed: '
        '${oldWidget.preSelectedPatientCode} → ${widget.preSelectedPatientCode}',
      );

      // Reset initialization flag to allow reload
      _isInitialized = false;

      // Reload with new patient
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

      // Pre-select patient if provided
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

    if (query.isEmpty) {
      setState(() {
        _filteredPatients = patients.take(5).toList();
      });
    } else {
      setState(() {
        _filteredPatients = patients
            .where(
              (p) =>
                  p.name.toLowerCase().contains(query.toLowerCase()) ||
                  p.patientCode.toLowerCase().contains(query.toLowerCase()),
            )
            .take(5)
            .toList();
      });
    }
  }

  Future<void> _uploadImage() async {
    final l10n = AppLocalizations.of(context);
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    try {
      // Step 1: Pick file
      await detectionProvider.pickFile();

      // Step 2: Crop image (user can position!)
      await detectionProvider.cropImage();

      // Success - image ready
      if (mounted) {
        setState(() {});
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showError(e.getTranslatedMessageFromL10n(l10n));
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.errorUnknown);
      }
    }
  }

  void _removeImage() {
    final detectionProvider = Provider.of<DetectionProvider>(
      context,
      listen: false,
    );

    detectionProvider.clearImage();
  }

  void _showAddPatientDialog() {
    final router = GoRouter.of(context);
    router.push('/patients/add');
  }

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

    // Validation
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
      debugPrint('🚀 [DetectionScreen] Starting detection (once)...');

      // Call detection API via provider
      await detectionProvider.startDetection(
        patientCode: _selectedPatient!.patientCode,
        sideEye: _eyeSide!,
      );

      debugPrint('✅ [DetectionScreen] Detection completed successfully');

      if (mounted) {
        // Auto-scroll to result
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
        final message = e.getTranslatedMessageFromL10n(l10n);
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
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

        // Scroll to top
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
        final message = e.getTranslatedMessageFromL10n(l10n);
        messenger.showSnackBar(
          SnackBar(
            content: Text(message),
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

  void _retryDetection() {
    _startDetection();
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: Spacing.radiusMD,
              ),
              child: const Icon(Icons.warning, color: AppColors.danger),
            ),
            Spacing.horizontalMD,
            Expanded(child: Text(l10n.confirm, style: AppTextStyles.h4)),
          ],
        ),
        content: Text(l10n.allUnsavedDataWillBeLost),
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
      appBar: AppBar(
        title: Text(
          l10n.detection,
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<DetectionProvider>(
        builder: (context, detectionProvider, child) {
          final hasResult = detectionProvider.previewData != null;

          return SingleChildScrollView(
            controller: _scrollController,
            padding: Spacing.paddingLG,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SECTION 1: INPUT FORM
                  _buildInputSection(l10n, detectionProvider),

                  // Show result if available
                  if (hasResult) ...[
                    Spacing.verticalXXL,
                    _buildResultSection(l10n, detectionProvider),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
          Text(
            l10n.detectionInformation,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          Spacing.verticalLG,

          // Patient Selection
          _buildPatientSelection(l10n),
          Spacing.verticalLG,

          // Eye Side Selection
          _buildEyeSideSelection(l10n),
          Spacing.verticalLG,

          // Image Upload
          _buildImageUpload(l10n, detectionProvider),
          Spacing.verticalXL,

          // Start Detection Button
          _buildStartButton(l10n, detectionProvider),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1, end: 0);
  }

  Widget _buildPatientSelection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.selectPatient} *',
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,
        TextFormField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchPatients,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _selectedPatient != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _selectedPatient = null;
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(borderRadius: Spacing.radiusMD),
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

        // Dropdown results
        if (_showPatientDropdown) ...[
          Spacing.verticalSM,
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
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
                // Patient options
                ..._filteredPatients.map(
                  (patient) => ListTile(
                    leading: PatientAvatar(
                      name: patient.name,
                      gender: patient.gender,
                      size: 40,
                    ),
                    title: Text(patient.name),
                    subtitle: Text(patient.patientCode),
                    onTap: () {
                      setState(() {
                        _selectedPatient = patient;
                        _searchController.text =
                            '${patient.name} - ${patient.patientCode}';
                        _showPatientDropdown = false;
                      });
                    },
                  ),
                ),

                // Add new patient option
                if (_filteredPatients.isEmpty ||
                    _searchController.text.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.add, color: Colors.white),
                    ),
                    title: Text(l10n.addNewPatient),
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
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,
        Row(
          children: [
            Expanded(
              child: _buildEyeSideOption(
                label: l10n.leftEye,
                value: 'OS',
                icon: Icons.visibility,
                selected: _eyeSide == 'OS',
              ),
            ),
            Spacing.horizontalMD,
            Expanded(
              child: _buildEyeSideOption(
                label: l10n.rightEye,
                value: 'OD',
                icon: Icons.visibility,
                selected: _eyeSide == 'OD',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEyeSideOption({
    required String label,
    required String value,
    required IconData icon,
    required bool selected,
  }) {
    return InkWell(
      onTap: () => setState(() => _eyeSide = value),
      borderRadius: Spacing.radiusMD,
      child: Container(
        padding: Spacing.paddingMD,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderLight,
            width: selected ? 2 : 1,
          ),
          borderRadius: Spacing.radiusMD,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            Spacing.verticalSM,
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

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
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacing.verticalSM,

        if (!hasImage) ...[
          // Upload button
          InkWell(
            onTap: isLoading ? null : _uploadImage,
            borderRadius: Spacing.radiusMD,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: Spacing.radiusMD,
                border: Border.all(color: AppColors.borderLight, width: 2),
              ),
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          Spacing.verticalMD,
                          Text(
                            detectionProvider.isPicking
                                ? 'Picking image...'
                                : 'Cropping image...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        Spacing.verticalMD,
                        Text(
                          l10n.uploadFundusImage,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacing.verticalSM,
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
          // Show cropped image
          Container(
            height: 300,
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
              Icon(Icons.check_circle, color: AppColors.success, size: 20),
              Spacing.horizontalXS,
              Text(
                l10n.imageCroppedReady,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(l10n.removeImage),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStartButton(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final isProcessing = detectionProvider.isProcessing;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (isProcessing || _isDetecting) ? null : _startDetection,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
        ),
        child: isProcessing
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 24),
                  Spacing.horizontalSM,
                  Text(
                    l10n.startDetection,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildResultSection(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final result = detectionProvider.previewData!;

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
            l10n.detectionResult,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
          ),
          Spacing.verticalLG,

          // Result details
          _buildResultDetails(result, l10n, detectionProvider),

          Spacing.verticalXL,

          // Action buttons (Save, Retry, Cancel)
          _buildActionButtons(l10n, detectionProvider),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildResultDetails(
    dynamic result,
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    return Column(
      children: [
        // Image
        if (detectionProvider.croppedImageBytes != null)
          Container(
            height: 280,
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

        // Classification Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Helpers.getClassificationColor(
              result.classification,
            ).withValues(alpha: 0.1),
            borderRadius: Spacing.radiusMD,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_hospital,
                color: Helpers.getClassificationColor(result.classification),
              ),
              Spacing.horizontalSM,
              Text(
                result.predictedLabel,
                style: AppTextStyles.h4.copyWith(
                  color: Helpers.getClassificationColor(result.classification),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Spacing.verticalLG,

        // Details
        _buildInfoRow(
          l10n.confidence,
          '${(result.confidence * 100).toStringAsFixed(1)}%',
          Icons.verified,
        ),
        _buildInfoRow(
          l10n.sideEye,
          result.sideEye == 'OD' ? l10n.rightEye : l10n.leftEye,
          Icons.visibility,
        ),
        _buildInfoRow(
          'Detected At',
          Helpers.formatDateTime(DateTime.now()),
          Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          Spacing.horizontalSM,
          Text(
            '$label:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AppLocalizations l10n,
    DetectionProvider detectionProvider,
  ) {
    final isSaving = detectionProvider.isSaving;

    return Row(
      children: [
        // Save
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _saveDetection,
            icon: const Icon(Icons.save, size: 18),
            label: Text(l10n.save),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
            ),
          ),
        ),
        Spacing.horizontalSM,

        // Retry
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isSaving ? null : _retryDetection,
            icon: const Icon(Icons.refresh, size: 18),
            label: Text(l10n.retry),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
            ),
          ),
        ),
        Spacing.horizontalSM,

        // Cancel
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isSaving ? null : _cancelDetection,
            icon: const Icon(Icons.close, size: 18),
            label: Text(l10n.cancel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusMD),
            ),
          ),
        ),
      ],
    );
  }
}
