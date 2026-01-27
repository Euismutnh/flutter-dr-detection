// lib/widgets/custom_text_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/l10n/app_localizations.dart';

/// Custom Text Field Widget
/// Modern input field with icons, validation, and animations
///
/// Usage:
/// ```dart
/// CustomTextField(
///   label: 'Email',
///   hint: 'Enter your email',
///   controller: emailController,
///   prefixIcon: Icons.mail,
///   keyboardType: TextInputType.emailAddress,
///   validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
/// )
/// ```
class CustomTextField extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final String? helperText;
  final String? errorText;
  final Widget? suffix;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.helperText,
    this.errorText,
    this.suffix,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double scale = _isFocused ? 1.02 : 1.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTextStyles.labelMedium.copyWith(
            color: _isFocused ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        Spacing.verticalSM,
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.diagonal3Values(scale, scale, 1.0),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onFieldSubmitted: widget.onSubmitted,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            textCapitalization: widget.textCapitalization,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textDisabled,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: Spacing.iconMD,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: widget.onSuffixIconTap,
                    )
                  : widget.suffix,
              filled: true,
              fillColor: widget.enabled
                  ? (_isFocused ? AppColors.surface : AppColors.cardBackground)
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
              errorBorder: OutlineInputBorder(
                borderRadius: Spacing.radiusLG,
                borderSide: BorderSide(color: AppColors.danger, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: Spacing.radiusLG,
                borderSide: BorderSide(color: AppColors.danger, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: Spacing.radiusLG,
                borderSide: BorderSide(color: AppColors.borderLight, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              helperText: widget.helperText,
              helperStyle: AppTextStyles.caption,
              errorText: widget.errorText,
              errorStyle: AppTextStyles.error,
              errorMaxLines: 2,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// SPECIALIZED TEXT FIELDS (FIXED)
// ============================================================================

/// Password Text Field with Toggle Visibility
class PasswordTextField extends StatefulWidget {
  final String? label; // Nullable
  final String? hint;  // Nullable
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomTextField(
      label: widget.label ?? l10n.password, 
      hint: widget.hint ?? l10n.enterPassword, 
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscureText ? Icons.visibility_off : Icons.visibility,
      onSuffixIconTap: () {
        setState(() {
          _obscureText = !_obscureText;
        });
      },
      obscureText: _obscureText,
      keyboardType: TextInputType.visiblePassword,
    );
  }
}

/// Email Text Field
class EmailTextField extends StatelessWidget {
  final String? label;
  final String? hint; 
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const EmailTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); 

    return CustomTextField(
      label: label ?? l10n.email, 
      hint: hint ?? l10n.enterEmail, 
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: Icons.mail_outline,
      keyboardType: TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
    );
  }
}

/// Phone Text Field
class PhoneTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); 

    return CustomTextField(
      label: label ?? l10n.phoneNumber,
      hint: hint ?? '08xxxxxxxxxx',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
      ],
    );
  }
}

/// Search Text Field
class SearchTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomTextField(
      label: '', 
      hint: hint ?? l10n.search, 
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: Icons.search,
      suffixIcon: controller?.text.isNotEmpty ?? false ? Icons.close : null,
      onSuffixIconTap: onClear,
    );
  }
}