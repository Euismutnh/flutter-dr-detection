// lib/widgets/patient_avatar.dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';

/// Patient Avatar Widget
/// Displays patient initials with gender-based gradient background
///
/// Usage:
/// ```dart
/// PatientAvatar(
///   name: 'John Doe',
///   gender: 'Male',
///   size: 64,
/// )
/// ```
class PatientAvatar extends StatelessWidget {
  final String name;
  final String gender; 
  final double size;
  final String? imageUrl;
  final bool showBorder;
  final VoidCallback? onTap;

  const PatientAvatar({
    super.key,
    required this.name,
    required this.gender,
    this.size = 56,
    this.imageUrl,
    this.showBorder = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: _getGradient(),
          shape: BoxShape.circle,
          border: showBorder ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: _getGradient().colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials();
                  },
                )
              : _buildInitials(),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials();
    final fontSize = size * 0.35; // 35% of avatar size

    return Container(
      decoration: BoxDecoration(gradient: _getGradient()),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      // Single word - take first 2 characters
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    // Multiple words - take first letter of first two words
    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
  }

  LinearGradient _getGradient() {
    final isMale = gender.toLowerCase() == 'male';
    return isMale ? AppGradients.male : AppGradients.female;
  }
}

/// User Avatar Widget (for doctor profile)
/// Similar to PatientAvatar but with primary gradient as default
class UserAvatar extends StatelessWidget {
  final String name;
  final double size;
  final String? imageUrl;
  final bool showBorder;
  final VoidCallback? onTap;
  final bool useGradient;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 56,
    this.imageUrl,
    this.showBorder = true,
    this.onTap,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: useGradient ? AppGradients.primary : null,
          color: useGradient ? null : AppColors.primary,
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(color: AppColors.primary, width: 3)
              : null,
        ),
        child: ClipOval(
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildInitials();
                  },
                )
              : _buildInitials(),
        ),
      ),
    );
  }

  Widget _buildInitials() {
    final initials = _getInitials();
    final fontSize = size * 0.35;

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  String _getInitials() {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words[0].substring(0, words[0].length >= 2 ? 2 : 1).toUpperCase();
    }

    return words
        .take(2)
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .join('');
  }
}

/// Avatar Group Widget (for showing multiple avatars)
class AvatarGroup extends StatelessWidget {
  final List<String> names;
  final List<String> genders;
  final int maxVisible;
  final double size;

  const AvatarGroup({
    super.key,
    required this.names,
    required this.genders,
    this.maxVisible = 3,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final visible = names.take(maxVisible).toList();
    final remaining = names.length - maxVisible;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(visible.length, (index) {
          return Transform.translate(
            offset: Offset(-index * (size * 0.3), 0),
            child: PatientAvatar(
              name: visible[index],
              gender: genders[index],
              size: size,
              showBorder: true,
            ),
          );
        }),
        if (remaining > 0)
          Transform.translate(
            offset: Offset(-maxVisible * (size * 0.3), 0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Center(
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: size * 0.3,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
