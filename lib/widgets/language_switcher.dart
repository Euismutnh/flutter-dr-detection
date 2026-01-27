// lib/widgets/language_switcher.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LanguageProvider>(context);
    final isEn = provider.isEnglish;

    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16), // Jarak dari pojok
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5), // Glass effect
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.surface.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context,
            text: 'ID',
            isSelected: !isEn,
            onTap: () => provider.changeLanguage('id'),
          ),
          _buildOption(
            context,
            text: 'EN',
            isSelected: isEn,
            onTap: () => provider.changeLanguage('en'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}