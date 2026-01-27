// lib/screens/patient/add_patient_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/patient_provider.dart';
import '../../widgets/custom_button.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/patient/patient_model.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientCodeController = TextEditingController();
  final _nameController = TextEditingController();

  String? _selectedGender;
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _patientCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // --- LOGIC UI HANDLERS (Sama seperti file asli) ---

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  // --- LOGIC BARU (DEFERRED EXECUTION) ---

  /// 1. Helper: Proses Simpan ke API (Dipanggil dari Popup)
  Future<PatientModel?> _processCreatePatient(Map<String, dynamic> data) async {
    // Menggunakan this.context (aman karena di dalam State)
    Helpers.showLoadingDialog(context);
    final provider = Provider.of<PatientProvider>(context, listen: false);

    try {
      final newPatient = await provider.createPatient(
        patientCode: data['patientCode'],
        name: data['name'],
        gender: data['gender'],
        dateOfBirth: data['dateOfBirth'],
      );

      // Cek mounted sebelum pakai context lagi
      if (mounted) Navigator.of(context).pop(); // Tutup Loading
      return newPatient;
    } catch (e) {
      // Cek mounted sebelum pakai context lagi
      if (mounted) {
        Navigator.of(context).pop(); // Tutup Loading
        Helpers.showErrorSnackbar(context, e.toString());
      }
      return null;
    }
  }

  /// 2. Dialog Konfirmasi (Menggantikan Success Popup Lama)
  /// PERBAIKAN: Menghapus parameter context agar menggunakan context global
  void _showActionDialog(Map<String, dynamic> patientData) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context, // Menggunakan this.context
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: Spacing.radiusXL),
        title: Text(
          l10n.confirm, // "Confirm"
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.patientCode, patientData['patientCode']),
            _buildDetailRow(l10n.fullName, patientData['name']),
            _buildDetailRow(l10n.gender, patientData['gender']),
            _buildDetailRow(
              l10n.dateOfBirth,
              Helpers.formatDate(patientData['dateOfBirth']),
            ),

            Spacing.verticalLG,

            Text(
              l10n.chooseNextAction, // "Choose what to do..."
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // TOMBOL CANCEL (Tutup saja, Data AMAN belum tersimpan)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              l10n.cancel,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // TOMBOL SAVE ONLY (Simpan -> Balik ke List)
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi

              // Mulai proses Async
              final result = await _processCreatePatient(patientData);

              // FIX ERROR ASYNC GAP:
              // Cek apakah widget masih 'mounted' sebelum pakai context
              if (!mounted) return;

              if (result != null) {
                Helpers.showSuccessSnackbar(context, l10n.successSave);
                GoRouter.of(context).go(RouteNames.patients);
              }
            },
            child: Text(
              l10n.save, // "Save"
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // TOMBOL START DETECTION (Simpan -> Lanjut Deteksi)
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Tutup dialog konfirmasi

              // Mulai proses Async
              final result = await _processCreatePatient(patientData);

              // FIX ERROR ASYNC GAP:
              if (!mounted) return;

              if (result != null) {
                // Pindah ke Detection
                GoRouter.of(
                  context,
                ).push('/detection/start?patientCode=${result.patientCode}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.startDetection),
          ),
        ],
      ),
    );
  }

  /// 3. Helper Widget untuk Baris Detail di Dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Handler Tombol Utama (Hanya Validasi)
  Future<void> _handleSubmit() async {
    final l10n = AppLocalizations.of(context);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedGender == null) {
      Helpers.showErrorSnackbar(context, l10n.errorGenderRequired);
      return;
    }

    if (_selectedDateOfBirth == null) {
      Helpers.showErrorSnackbar(context, l10n.errorDateOfBirthRequired);
      return;
    }

    Helpers.hideKeyboard(context);

    // Kumpulkan data (Belum Simpan ke DB)
    final Map<String, dynamic> patientData = {
      'patientCode': _patientCodeController.text.trim().toUpperCase(),
      'name': _nameController.text.trim(),
      'gender': _selectedGender!,
      'dateOfBirth': _selectedDateOfBirth!,
    };

    // Tampilkan Dialog Konfirmasi
    // FIX: Tidak perlu kirim context lagi
    _showActionDialog(patientData);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.addNewPatient), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: Spacing.paddingLG,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Instructions Card
                Container(
                  padding: Spacing.paddingMD,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: Spacing.radiusLG,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      Spacing.horizontalSM,
                      Expanded(
                        child: Text(
                          l10n.fillPatientInfo,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.1, end: 0),

                Spacing.verticalXL,

                // Patient Code Field
                _buildTextField(
                  label: l10n.patientCode,
                  hint: l10n.patientCodeHint,
                  controller: _patientCodeController,
                  prefixIcon: Icons.badge_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.errorPatientCodeRequired;
                    }
                    final error = Validators.patientCode(value.trim());
                    if (error != null) {
                      return l10n
                          .errorPatientCodeInvalid; // Dianggap error jika format salah
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_-]')),
                    LengthLimitingTextInputFormatter(50),
                  ],
                  textCapitalization: TextCapitalization.characters,
                ).animate(delay: 100.ms).fadeIn().slideX(begin: 0.1, end: 0),

                Spacing.verticalLG,

                // Name Field
                _buildTextField(
                  label: l10n.patientName,
                  hint: l10n.patientNameHint,
                  controller: _nameController,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.errorNameRequired;
                    }
                    final error = Validators.name(value.trim());
                    if (error != null) {
                      return error;
                    }
                    return null;
                  },
                  textCapitalization: TextCapitalization.words,
                ).animate(delay: 200.ms).fadeIn().slideX(begin: 0.1, end: 0),

                Spacing.verticalLG,

                // Gender Selection
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.gender,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Spacing.verticalSM,
                    Row(
                      children: [
                        Expanded(
                          child: _buildGenderCard(
                            label: l10n.male,
                            icon: Icons.male,
                            isSelected: _selectedGender == 'Male',
                            onTap: () =>
                                setState(() => _selectedGender = 'Male'),
                          ),
                        ),
                        Spacing.horizontalMD,
                        Expanded(
                          child: _buildGenderCard(
                            label: l10n.female,
                            icon: Icons.female,
                            isSelected: _selectedGender == 'Female',
                            onTap: () =>
                                setState(() => _selectedGender = 'Female'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).animate(delay: 300.ms).fadeIn().slideX(begin: 0.1, end: 0),

                Spacing.verticalLG,

                // Date of Birth Picker (DESAIN SAMA PERSIS DENGAN FILE LAMA)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateOfBirth,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Spacing.verticalSM,
                    GestureDetector(
                      onTap: _selectDateOfBirth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: Spacing.radiusLG,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.textSecondary,
                              size: Spacing.iconMD,
                            ),
                            Spacing.horizontalMD,
                            Expanded(
                              child: Text(
                                _selectedDateOfBirth != null
                                    ? Helpers.formatDate(_selectedDateOfBirth!)
                                    : l10n.selectDate,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _selectedDateOfBirth != null
                                      ? AppColors.textPrimary
                                      : AppColors.textDisabled,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 400.ms).fadeIn().slideX(begin: 0.1, end: 0),

                Spacing.verticalXXL,

                // Submit Button
                Consumer<PatientProvider>(
                  builder: (context, provider, child) {
                    return CustomButton(
                      // Text tombol diubah ke Next untuk Logic Baru
                      // Tapi Style (CustomButton) TETAP SAMA
                      text: l10n.next,
                      type: ButtonType.primary,
                      size: ButtonSize.large,
                      icon: Icons
                          .arrow_forward, // Icon panah untuk indikasi next step
                      isLoading: provider.isCreating,
                      onPressed: provider.isCreating ? null : _handleSubmit,
                    );
                  },
                ).animate(delay: 500.ms).fadeIn().scale(),

                Spacing.verticalLG,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- HELPER WIDGETS (SAMA PERSIS DARI FILE UPLOAD) ---

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Spacing.verticalSM,
        TextFormField(
          controller: controller,
          validator: validator,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(
              prefixIcon,
              color: AppColors.textSecondary,
              size: Spacing.iconMD,
            ),
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
            errorBorder: OutlineInputBorder(
              borderRadius: Spacing.radiusLG,
              borderSide: BorderSide(color: AppColors.danger, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: Spacing.radiusLG,
              borderSide: BorderSide(color: AppColors.danger, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (label == 'Male' ? AppGradients.male : AppGradients.female)
              : null,
          color: isSelected ? null : AppColors.cardBackground,
          borderRadius: Spacing.radiusLG,
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.border,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (label == 'Male'
                                ? AppColors.maleDark
                                : AppColors.femaleDark)
                            .withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 32,
            ),
            Spacing.verticalXS,
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
}
