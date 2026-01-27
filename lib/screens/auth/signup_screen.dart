// lib/screens/auth/signup_screen.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';

import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/language_switcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Text Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _detailedAddressController = TextEditingController();
  final _assignmentLocationController = TextEditingController();

  // Form State
  DateTime? _selectedDateOfBirth;
  String? _selectedProfession;
  File? _selectedPhoto;

  // Loading State
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _isInitialized = true;
        _initializeLocation();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _detailedAddressController.dispose();
    _assignmentLocationController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    // Reset previous data
    locationProvider.resetAll();

    // Load provinces
    final success = await locationProvider.loadProvinces();

    if (!success && mounted) {
      // Show error if load failed
      debugPrint('❌ [SignupScreen] Failed to load provinces');
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.networkError} - ${l10n.retry}'),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: l10n.retry,
            textColor: Colors.white,
            onPressed: _initializeLocation,
          ),
        ),
      );
    } else {
      debugPrint(
        '✅ [SignupScreen] Provinces loaded: ${locationProvider.provinces?.length ?? 0}',
      );
    }
  }

  Future<void> _handleSignup() async {
    Helpers.hideKeyboard(context);

    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      return;
    }

    // Validate date of birth
    if (_selectedDateOfBirth == null) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDateRequired),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Validate location selection
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    if (!locationProvider.isCompleteAddressSelected) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorCompleteAddress),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // [SOP] CAPTURE references before async
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      MultipartFile? photoFile;
      if (_selectedPhoto != null) {
        photoFile = await MultipartFile.fromFile(
          _selectedPhoto!.path,
          filename: 'profile_photo.jpg',
        );
      }

      await authProvider.signup(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        profession: _selectedProfession,
        dateOfBirth: _selectedDateOfBirth,
        provinceName: locationProvider.selectedProvince?.name,
        cityName: locationProvider.selectedRegency?.name,
        districtName: locationProvider.selectedDistrict?.name,
        villageName: locationProvider.selectedVillage?.name,
        detailedAddress: _detailedAddressController.text.trim(),
        assignmentLocation: _assignmentLocationController.text.trim(),
        photo: photoFile,
      );
      final email = _emailController.text.trim();
      router.push(
        '${RouteNames.otpSignUp}?email=${Uri.encodeComponent(email)}',
      );

      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successOtpSent),
          backgroundColor: AppColors.success,
        ),
      );
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

  Future<void> _selectDateOfBirth() async {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final initialDate = _selectedDateOfBirth ?? DateTime(now.year - 25);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: l10n.selectDateOfBirth,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPhoto = File(result.files.single.path!);
        });
      }
    } catch (e) {
      debugPrint('❌ [SignupScreen] Photo pick error: $e');
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient - IDENTIK dengan login
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.background),
          ),

          // Main content - wrapped in SafeArea
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: Spacing.screenPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacing for Language Switcher (so content doesn't overlap)
                    const SizedBox(height: 40),

                    // Logo - IDENTIK dengan login
                    Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/app_logo2.png',
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                    ).animate().scale(
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    ),

                    Spacing.verticalXXXL,

                    // Title & Subtitle - IDENTIK style dengan login
                    Column(
                          children: [
                            Text(
                              l10n.createYourAccount,
                              style: AppTextStyles.h1.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Spacing.verticalXS,
                            Text(
                              l10n.fillFormToRegister,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2, end: 0),

                    Spacing.verticalXL,

                    // Form Card - IDENTIK style dengan login
                    Container(
                          padding: Spacing.paddingLG,
                          decoration: BoxDecoration(
                            color: AppColors.surface.withValues(alpha: 0.5),
                            borderRadius: Spacing.radiusXL,
                            border: Border.all(
                              color: AppColors.surface.withValues(alpha: 0.6),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowLight.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ========================================
                              // PERSONAL INFORMATION
                              // ========================================
                              _buildPhotoPicker(),
                              Spacing.verticalXL,
                              _buildSectionTitle(l10n.personalInformation),
                              Spacing.verticalMD,

                              // Full Name
                              CustomTextField(
                                label: l10n.fullName,
                                hint: l10n.enterFullName,
                                controller: _fullNameController,
                                prefixIcon: Icons.person_outline,
                                validator: Validators.name,
                                textCapitalization: TextCapitalization.words,
                              ),
                              Spacing.verticalLG,

                              // Email
                              EmailTextField(
                                controller: _emailController,
                                validator: Validators.email,
                              ),
                              Spacing.verticalLG,

                              // Phone
                              PhoneTextField(
                                controller: _phoneController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.errorPhoneRequired;
                                  }
                                  return Validators.phoneNumber(value);
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  l10n.phoneRequirements,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Spacing.verticalLG,

                              // Date of Birth
                              _buildDateOfBirthField(),
                              Spacing.verticalLG,

                              // Profession
                              _buildProfessionDropdown(),

                              Spacing.verticalXL,

                              // ========================================
                              // SECURITY
                              // ========================================
                              _buildSectionTitle(l10n.security),
                              Spacing.verticalMD,

                              // Password
                              PasswordTextField(
                                controller: _passwordController,
                                validator: Validators.password,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 4),
                                child: Text(
                                  l10n.passwordRequirements,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Spacing.verticalLG,

                              // Confirm Password
                              PasswordTextField(
                                label: l10n.confirmPassword,
                                hint: l10n.reenterPassword,
                                controller: _confirmPasswordController,
                                validator: (value) =>
                                    Validators.confirmPassword(
                                      value,
                                      _passwordController.text,
                                    ),
                              ),

                              Spacing.verticalXL,

                              // ========================================
                              // ADDRESS
                              // ========================================
                              _buildSectionTitle(l10n.addressInformation),
                              Spacing.verticalMD,

                              // Location Cascade Dropdowns
                              _buildLocationDropdowns(),

                              Spacing.verticalLG,

                              CustomTextField(
                                label: l10n.assignmentLocation,
                                hint: l10n.assignmentLocationHint,
                                controller: _assignmentLocationController,
                                prefixIcon: Icons.pin_drop_outlined,
                                maxLines: 1,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.errorAddressRequired;
                                  }
                                  return null;
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                              Spacing.verticalLG,
                              // Detailed Address
                              CustomTextField(
                                label: l10n.detailedAddress,
                                hint: l10n.detailedAddressHint,
                                controller: _detailedAddressController,
                                prefixIcon: Icons.home_outlined,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.errorAddressRequired;
                                  }
                                  return null;
                                },
                                textCapitalization:
                                    TextCapitalization.sentences,
                              ),
                            ],
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 400.ms)
                        .slideY(begin: 0.1, end: 0),

                    Spacing.verticalXL,

                    // Submit Button - IDENTIK style dengan login
                    Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: Spacing.radiusXXL,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: CustomButton(
                                text: l10n.signup,
                                onPressed: authProvider.isLoading
                                    ? null
                                    : _handleSignup,
                                isLoading: authProvider.isLoading,
                                type: ButtonType.primary,
                                size: ButtonSize.large,
                              ),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 600.ms)
                        .slideY(begin: 0.1, end: 0),

                    Spacing.verticalLG,

                    // Already have account - IDENTIK style dengan login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.alreadyHaveAccount,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Spacing.horizontalXS,
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            l10n.login,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 800.ms),

                    Spacing.verticalXXL,
                  ],
                ),
              ),
            ),
          ),

          // Language Switcher - Fixed position, won't scroll
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(child: const LanguageSwitcher()),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================

  Widget _buildPhotoPicker() {
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickPhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 43,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: _selectedPhoto != null
                      ? FileImage(_selectedPhoto!)
                      : null,
                  child: _selectedPhoto == null
                      ? Icon(
                          Icons.camera_alt_outlined,
                          size: 32,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                if (_selectedPhoto != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _removePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Spacing.verticalSM,
          Text(
            _selectedPhoto != null ? l10n.changePhoto : l10n.addPhoto,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Spacing.horizontalSM,
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    final l10n = AppLocalizations.of(context);

    return Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: Spacing.radiusLG,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textSecondary,
                  size: Spacing.iconMD,
                ),
                Spacing.horizontalMD,
                Expanded(
                  child: Text(
                    _selectedDateOfBirth != null
                        ? Helpers.formatDate(_selectedDateOfBirth!)
                        : l10n.selectDateOfBirth,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: _selectedDateOfBirth != null
                          ? AppColors.textPrimary
                          : AppColors.textDisabled,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionDropdown() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profession,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        Spacing.verticalSM,
        DropdownButtonFormField<String>(
          initialValue: _selectedProfession,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: l10n.selectProfession,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: Icon(
              Icons.work_outline,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: AppConstants.professionOptions.map((profKey) {
            return DropdownMenuItem<String>(
              value: profKey,
              child: Text(
                AppConstants.getProfessionLabel(context, profKey),
                overflow: TextOverflow.ellipsis, // FIX: Truncate long text
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedProfession = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.errorProfessionRequired;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildLocationDropdowns() {
    final l10n = AppLocalizations.of(context);

    return Consumer<LocationProvider>(
      builder: (context, locationProvider, child) {
        return Column(
          children: [
            // Province
            _buildLocationDropdown(
              label: l10n.province,
              hint: l10n.selectProvince,
              icon: Icons.location_on_outlined,
              isLoading: locationProvider.isLoadingProvinces,
              items: locationProvider.provinces ?? [],
              selectedValue: locationProvider.selectedProvince,
              onChanged: (location) {
                if (location != null) {
                  locationProvider.selectProvince(location);
                }
              },
              validator: (value) {
                if (locationProvider.selectedProvince == null) {
                  return l10n.errorProvinceRequired;
                }
                return null;
              },
            ),
            Spacing.verticalLG,

            // City/Regency
            _buildLocationDropdown(
              label: l10n.city,
              hint: l10n.selectCity,
              icon: Icons.location_city_outlined,
              isLoading: locationProvider.isLoadingRegencies,
              items: locationProvider.regencies ?? [],
              selectedValue: locationProvider.selectedRegency,
              enabled: locationProvider.selectedProvince != null,
              onChanged: (location) {
                if (location != null) {
                  locationProvider.selectRegency(location);
                }
              },
              validator: (value) {
                if (locationProvider.selectedProvince != null &&
                    locationProvider.selectedRegency == null) {
                  return l10n.errorCityRequired;
                }
                return null;
              },
            ),
            Spacing.verticalLG,

            // District
            _buildLocationDropdown(
              label: l10n.district,
              hint: l10n.selectDistrict,
              icon: Icons.map_outlined,
              isLoading: locationProvider.isLoadingDistricts,
              items: locationProvider.districts ?? [],
              selectedValue: locationProvider.selectedDistrict,
              enabled: locationProvider.selectedRegency != null,
              onChanged: (location) {
                if (location != null) {
                  locationProvider.selectDistrict(location);
                }
              },
              validator: (value) {
                if (locationProvider.selectedRegency != null &&
                    locationProvider.selectedDistrict == null) {
                  return l10n.errorDistrictRequired;
                }
                return null;
              },
            ),
            Spacing.verticalLG,

            // Village
            _buildLocationDropdown(
              label: l10n.village,
              hint: l10n.selectVillage,
              icon: Icons.holiday_village_outlined,
              isLoading: locationProvider.isLoadingVillages,
              items: locationProvider.villages ?? [],
              selectedValue: locationProvider.selectedVillage,
              enabled: locationProvider.selectedDistrict != null,
              onChanged: (location) {
                if (location != null) {
                  locationProvider.selectVillage(location);
                }
              },
              validator: (value) {
                if (locationProvider.selectedDistrict != null &&
                    locationProvider.selectedVillage == null) {
                  return l10n.errorVillageRequired;
                }
                return null;
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required bool isLoading,
    required List<dynamic> items,
    required dynamic selectedValue,
    required void Function(dynamic) onChanged,
    required String? Function(dynamic)? validator,
    bool enabled = true,
  }) {
    // Determine if dropdown should be interactive
    final bool isInteractive = enabled && !isLoading && items.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: enabled ? AppColors.textPrimary : AppColors.textDisabled,
          ),
        ),
        Spacing.verticalSM,
        DropdownButtonFormField<dynamic>(
          initialValue: selectedValue,
          decoration: InputDecoration(
            hintText: isLoading
                ? AppLocalizations.of(context).loading
                : (items.isEmpty && enabled)
                ? 'No data available'
                : hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textDisabled,
            ),
            prefixIcon: isLoading
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Icon(
                    icon,
                    color: isInteractive
                        ? AppColors.textSecondary
                        : AppColors.textDisabled,
                    size: Spacing.iconMD,
                  ),
            filled: true,
            fillColor: isInteractive
                ? AppColors.cardBackground
                : AppColors.borderLight,
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
            disabledBorder: OutlineInputBorder(
              borderRadius: Spacing.radiusLG,
              borderSide: BorderSide(color: AppColors.borderLight, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: Spacing.radiusLG,
              borderSide: BorderSide(color: AppColors.danger, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(item.name ?? '', overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: isInteractive ? onChanged : null,
          validator: validator,
          isExpanded: true,
        ),
      ],
    );
  }
}
