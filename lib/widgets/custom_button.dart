// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';

/// Custom Button Widget
/// Modern button with gradient, loading state, and multiple styles
/// 
/// Usage:
/// ```dart
/// CustomButton(
///   text: 'Sign In',
///   onPressed: () => handleLogin(),
///   type: ButtonType.primary,
///   isLoading: isLoading,
/// )
/// ```
class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final ButtonSize size;
  final IconData? icon;
  final bool iconRight;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.size = ButtonSize.large,
    this.icon,
    this.iconRight = false,
    this.width,
    this.height,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? _getHeight(),
          decoration: _getDecoration(isDisabled),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: Spacing.radiusXXL,
              child: Container(
                padding: _getPadding(),
                child: _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getDecoration(bool isDisabled) {
    if (isDisabled) {
      return BoxDecoration(
        color: AppColors.border,
        borderRadius: Spacing.radiusXXL,
      );
    }

    switch (widget.type) {
      case ButtonType.primary:
        return BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: Spacing.radiusXXL,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowButton,
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case ButtonType.secondary:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: Spacing.radiusXXL,
          border: Border.all(color: AppColors.primary, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case ButtonType.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: Spacing.radiusXXL,
          border: Border.all(color: AppColors.border, width: 2),
        );
      case ButtonType.text:
        return const BoxDecoration();
      case ButtonType.success:
        return BoxDecoration(
          gradient: AppGradients.success,
          borderRadius: Spacing.radiusXXL,
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case ButtonType.danger:
        return BoxDecoration(
          gradient: AppGradients.danger,
          borderRadius: Spacing.radiusXXL,
          boxShadow: [
            BoxShadow(
              color: AppColors.danger.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return Spacing.buttonHeightSM;
      case ButtonSize.medium:
        return Spacing.buttonHeightMD;
      case ButtonSize.large:
        return Spacing.buttonHeightLG;
    }
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTextColor(),
            ),
          ),
        ),
      );
    }

    final textWidget = Text(
      widget.text,
      style: _getTextStyle(),
      textAlign: TextAlign.center,
    );

    if (widget.icon == null) {
      return Center(child: textWidget);
    }

    final iconWidget = Icon(
      widget.icon,
      color: _getTextColor(),
      size: _getIconSize(),
    );

    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: widget.iconRight
            ? [textWidget, Spacing.horizontalSM, iconWidget]
            : [iconWidget, Spacing.horizontalSM, textWidget],
      ),
    );
  }

  TextStyle _getTextStyle() {
    final baseStyle = widget.size == ButtonSize.small
        ? AppTextStyles.buttonSmall
        : widget.size == ButtonSize.medium
            ? AppTextStyles.buttonMedium
            : AppTextStyles.buttonLarge;

    return baseStyle.copyWith(color: _getTextColor());
  }

  Color _getTextColor() {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    if (isDisabled) {
      return AppColors.textDisabled;
    }

    switch (widget.type) {
      case ButtonType.primary:
      case ButtonType.success:
      case ButtonType.danger:
        return AppColors.textOnPrimary;
      case ButtonType.secondary:
        return AppColors.primary;
      case ButtonType.outlined:
      case ButtonType.text:
        return AppColors.textPrimary;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return Spacing.iconSM;
      case ButtonSize.medium:
        return Spacing.iconMD;
      case ButtonSize.large:
        return Spacing.iconMD;
    }
  }
}

/// Button Types
enum ButtonType {
  primary,    // Gradient blue button
  secondary,  // Outlined with primary color
  outlined,   // Simple outlined
  text,       // Text only
  success,    // Green gradient
  danger,     // Red gradient
}

/// Button Sizes
enum ButtonSize {
  small,   // 36dp height
  medium,  // 48dp height
  large,   // 56dp height
}