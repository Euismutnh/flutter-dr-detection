// lib/widgets/scaffold_with_navbar.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_gradients.dart';
import '../core/l10n/app_localizations.dart'; // Jangan lupa import ini

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context); // Akses Translation

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _goBranch,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 500),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(
                Icons.home_rounded,
                color: AppColors.primary,
              ),
              label: l10n.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.people_outline),
              selectedIcon: const Icon(
                Icons.people_rounded,
                color: AppColors.primary,
              ),
              label: l10n.patients,
            ),
            NavigationDestination(
              icon: Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.secondaryDark, width: 2),
                ),
                child: const Icon(
                  Icons.document_scanner_outlined,
                  color: AppColors.secondaryDark,
                ),
              ),
              selectedIcon: Container(
                height: 48,
                width: 48,
                decoration: const BoxDecoration(
                  gradient: AppGradients.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.document_scanner, color: Colors.white),
              ).animate().scale(duration: 300.ms, curve: Curves.easeOutBack),
              label: l10n.detection,
            ),
            NavigationDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(
                Icons.history_rounded,
                color: AppColors.primary,
              ),
              label: l10n.history,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
              ),
              label: l10n.profile,
            ),
          ],
        ),
      ),
    );
  }
}
