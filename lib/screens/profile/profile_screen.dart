// lib/screens/profile/profile_screen.dart

import 'dart:io';
import 'package:dio/dio.dart'; // Wajib untuk MultipartFile
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';

// Providers
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/language_provider.dart';

// Widgets & Features
import '../../widgets/patient_avatar.dart';
import '../../features/export/widget/export_dialog.dart';

// Core
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/error_mapper.dart';
import '../../core/network/api_error_handler.dart';
import '../../core/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Memastikan data dimuat setelah frame pertama dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInitialized) {
        _loadData();
        _isInitialized = true;
      }
    });
  }

  /// Memuat data dashboard (Stats)
  Future<void> _loadData() async {
    if (!mounted) return;
    try {
      // Menggunakan listen: false karena ini di dalam fungsi async/init
      await Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).loadDashboardStats();
    } catch (e) {
      debugPrint('⚠️ [ProfileScreen] Failed to load stats: $e');
    }
  }

  /// Fungsi Pull-to-Refresh dengan Reference Capture Pattern
  Future<void> _refreshData() async {
    // 1. CAPTURE
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dashboardProvider = Provider.of<DashboardProvider>(
      context,
      listen: false,
    );

    try {
      // 2. ASYNC
      await Future.wait([
        authProvider.refreshUser(),
        dashboardProvider.refreshDashboardStats(),
      ]);

      // 3. RESULT
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successDataRefreshed),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      // Gunakan method BARU
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: _buildProfileCard(context),
                ),
                Spacing.verticalLG,
                // ===== STATS ROW =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: _buildStatsRow(context),
                ),

                Spacing.verticalXL,

                // ===== MENU SECTIONS =====
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
                  child: Column(
                    children: [
                      _buildAccountSection(context),
                      Spacing.verticalLG,
                      _buildDataSection(context),
                      Spacing.verticalLG,
                      _buildSettingsSection(context),
                      Spacing.verticalLG,
                      _buildAboutSection(context),
                      Spacing.verticalXL,
                      _buildAppVersion(context),
                      Spacing.verticalLG,
                      _buildSignOutButton(context),
                      Spacing.verticalXXXL,
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // WIDGET BUILDERS
  // ============================================================================

  Widget _buildProfileCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        final displayName = authProvider.displayName;
        final profession = user?.profession ?? 'Healthcare Professional';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: UserAvatar(
                      name: user?.fullName ?? 'User',
                      size: 85,
                      imageUrl: user?.photoUrl,
                      showBorder: false,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showPhotoOptions(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Text(
                displayName,
                style: AppTextStyles.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              Text(
                profession,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2), // Jarak dipersempit

              Text(
                user?.email ?? '',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<DashboardProvider>(
      builder: (context, dashboardProvider, child) {
        final stats = dashboardProvider.dashboardStats;
        return Container(
          padding: Spacing.paddingMD,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Spacing.radiusLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  value: '${stats?.totalDetections ?? 0}',
                  label: l10n.scans,
                  icon: Icons.document_scanner_outlined,
                  color: AppColors.primary,
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  value: '${stats?.totalPatients ?? 0}',
                  label: l10n.patients,
                  icon: Icons.people_outline_rounded,
                  color: AppColors.secondary,
                ),
              ),
              _buildVerticalDivider(),
              Expanded(
                child: _buildStatItem(
                  value: '${stats?.detectionsToday ?? 0}',
                  label: l10n.today,
                  icon: Icons.today_rounded,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        Spacing.verticalSM,
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacing.verticalXXS,
        Text(
          label,
          style: AppTextStyles.caption2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 50, width: 1, color: AppColors.borderLight);
  }

  // ===== MENU BUILDING BLOCKS =====

  Widget _buildAccountSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _buildMenuSection(
      title: l10n.account,
      children: [
        _buildMenuItem(
          icon: Icons.edit_outlined,
          iconColor: AppColors.primary,
          title: l10n.editProfile,
          onTap: () => context.push(RouteNames.editProfile),
        ),
        _buildMenuDivider(),
      ],
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildDataSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _buildMenuSection(
      title: l10n.data,
      children: [
        _buildMenuItem(
          icon: Icons.download_rounded,
          iconColor: AppColors.success,
          title: l10n.exportData,
          subtitle: l10n.exportDataSubtitle,
          onTap: () => showExportDialog(context),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSettingsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _buildMenuSection(
      title: l10n.settings,
      children: [
        Consumer<LanguageProvider>(
          builder: (context, languageProvider, _) {
            return _buildMenuItem(
              icon: Icons.language_rounded,
              iconColor: AppColors.info,
              title: l10n.language,
              onTap: () {},
              trailing: _buildLanguageToggle(context, languageProvider),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildAboutSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _buildMenuSection(
      title: l10n.about,
      children: [
        _buildMenuItem(
          icon: Icons.help_outline_rounded,
          iconColor: AppColors.info,
          title: l10n.helpSupport,
          onTap: () => _showComingSoonSnackbar(context),
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.description_outlined,
          iconColor: AppColors.textSecondary,
          title: l10n.termsOfService,
          onTap: () => _showComingSoonSnackbar(context),
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          icon: Icons.shield_outlined,
          iconColor: AppColors.textSecondary,
          title: l10n.privacyPolicy,
          onTap: () => _showComingSoonSnackbar(context),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: Spacing.xs, bottom: Spacing.sm),
          child: Text(
            title.toUpperCase(),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: Spacing.radiusLG,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Spacing.radiusLG,
        child: Padding(
          padding: EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Spacing.horizontalMD,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      Spacing.verticalXXS,
                      Text(
                        subtitle,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textDisabled,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: Spacing.lg + 40,
      endIndent: Spacing.md,
      color: AppColors.borderLight,
    );
  }

  Widget _buildLanguageToggle(
    BuildContext context,
    LanguageProvider languageProvider,
  ) {
    final isEnglish = languageProvider.isEnglish;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLangOption(
            label: 'EN',
            isSelected: isEnglish,
            onTap: () => languageProvider.changeLanguage('en'),
          ),
          _buildLangOption(
            label: 'ID',
            isSelected: !isEnglish,
            onTap: () => languageProvider.changeLanguage('id'),
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppGradients.primary : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppVersion(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Text(
      '${l10n.appVersion} ${AppConstants.appVersion}',
      style: AppTextStyles.caption.copyWith(color: AppColors.textDisabled),
      textAlign: TextAlign.center,
    ).animate().fadeIn(delay: 800.ms);
  }

  Widget _buildSignOutButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: Spacing.sm),
          child: OutlinedButton(
            onPressed: authProvider.isLoading
                ? null
                : () => _handleLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger, width: 1.5),
              padding: EdgeInsets.symmetric(horizontal: Spacing.lg),
              shape: RoundedRectangleBorder(borderRadius: Spacing.radiusLG),
              overlayColor: AppColors.danger.withValues(alpha: 0.1),
            ),
            child: authProvider.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.danger,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout_rounded),
                      const SizedBox(width: 8),
                      Text(
                        l10n.signOut,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.1, end: 0);
  }

  // ============================================================================
  // ACTION HANDLERS
  // ============================================================================

  void _showPhotoOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final hasPhoto = authProvider.hasProfilePhoto;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Spacing.verticalLG,
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(l10n.chooseFromGallery),
                onTap: () {
                  Navigator.pop(ctx);
                  _handleChangePhoto(context);
                },
              ),
              if (hasPhoto) ...[
                Divider(indent: Spacing.lg, endIndent: Spacing.lg),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.danger,
                    ),
                  ),
                  title: Text(
                    l10n.removePhoto,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _handleDeletePhoto(context);
                  },
                ),
              ],
              Spacing.verticalLG,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePhoto(BuildContext context) async {
    // 1. CAPTURE REFERENCES
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 2. FILE PICKER
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result == null || result.files.single.path == null) return;

      final File imageFile = File(result.files.single.path!);
      final String fileName = imageFile.path.split('/').last;

      // 3. CONVERT (Bisa lama)
      final multipartFile = await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      );

      if (!mounted) return;

      // 4. UPLOAD (Async)
      await authProvider.updateProfilePhoto(photo: multipartFile);

      // 5. GUNAKAN CAPTURED MESSENGER
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successProfileUpdated),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('Error upload photo: $e');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorUnknown),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleDeletePhoto(BuildContext context) async {
    // 1. CAPTURE REFERENCES
    final l10n = AppLocalizations.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);

    try {
      // 2. EXECUTE
      await authProvider.deleteProfilePhoto();

      // 3. GUNAKAN CAPTURED MESSENGER
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.successPhotoDeleted),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      final message = e.getTranslatedMessageFromL10n(l10n);
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.errorUnknown),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showComingSoonSnackbar(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.comingSoon),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 1. CONFIRM DIALOG
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.danger,
                size: 24,
              ),
            ),
            Spacing.horizontalSM,
            Expanded(child: Text(l10n.confirmLogout, style: AppTextStyles.h4)),
          ],
        ),
        content: Text(
          l10n.logoutMessage,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    // 2. CAPTURE REFERENCES

    try {
      // [SOP] 3. ASYNC PROCESS
      await authProvider.logout();

      // [SOP] 4. NAVIGASI AMAN (Pakai 'router', bukan 'context')
      router.go(RouteNames.login);
    } catch (e) {
      // [SOP] 5. ERROR HANDLING AMAN (Pakai 'messenger', bukan 'context')
      debugPrint('Logout error: $e');
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
