import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/theme/modern_navigation.dart';
import '/auth/supabase_auth/auth_util.dart';

class UserProfileWidgetNew extends StatefulWidget {
  const UserProfileWidgetNew({super.key});

  @override
  State<UserProfileWidgetNew> createState() => _UserProfileWidgetNewState();
}

class _UserProfileWidgetNewState extends State<UserProfileWidgetNew> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  String _audioQuality = 'High';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: CustomScrollView(
        slivers: [
          // App Bar with Profile Header
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: AppTheme.space48),

                      // Profile Picture
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                              boxShadow: AppTheme.elevatedShadow,
                            ),
                            child: ClipOval(
                              child: currentUserPhoto != null
                                  ? Image.network(
                                      currentUserPhoto!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppTheme.spotifyGreen,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Change profile picture
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppTheme.spotifyGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .scale(duration: 400.ms, curve: Curves.easeOut),

                      SizedBox(height: AppTheme.space16),

                      // Name
                      Text(
                        currentUserDisplayName ?? 'Music Lover',
                        style: AppTheme.displayMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      SizedBox(height: AppTheme.space8),

                      // Email
                      Text(
                        currentUserEmail,
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppTheme.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.music_note,
                          title: 'Songs',
                          value: '342',
                          isDark: isDark,
                        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                      ),
                      SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.playlist_play,
                          title: 'Playlists',
                          value: '12',
                          isDark: isDark,
                        ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1),
                      ),
                      SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.favorite,
                          title: 'Liked',
                          value: '89',
                          isDark: isDark,
                        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                      ),
                    ],
                  ),

                  SizedBox(height: AppTheme.space32),

                  // Account Section
                  Text(
                    'Account',
                    style: AppTheme.headlineLarge.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(delay: 550.ms),

                  SizedBox(height: AppTheme.space16),

                  _buildSettingTile(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Navigate to edit profile
                    },
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Navigate to change password
                    },
                  ).animate().fadeIn(delay: 650.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    isDark: isDark,
                    trailing: Switch(
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                      activeColor: AppTheme.spotifyGreen,
                    ),
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),

                  SizedBox(height: AppTheme.space32),

                  // Preferences Section
                  Text(
                    'Preferences',
                    style: AppTheme.headlineLarge.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(delay: 750.ms),

                  SizedBox(height: AppTheme.space16),

                  _buildSettingTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch(
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() => _darkModeEnabled = value);
                        // TODO: Toggle theme
                      },
                      activeColor: AppTheme.spotifyGreen,
                    ),
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.high_quality_outlined,
                    title: 'Audio Quality',
                    subtitle: _audioQuality,
                    isDark: isDark,
                    onTap: () => _showAudioQualitySheet(context, isDark),
                  ).animate().fadeIn(delay: 850.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.language_outlined,
                    title: 'Language',
                    subtitle: 'English',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Show language options
                    },
                  ).animate().fadeIn(delay: 900.ms).slideX(begin: -0.1),

                  SizedBox(height: AppTheme.space32),

                  // About Section
                  Text(
                    'About',
                    style: AppTheme.headlineLarge.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ).animate().fadeIn(delay: 950.ms),

                  SizedBox(height: AppTheme.space16),

                  _buildSettingTile(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Navigate to help
                    },
                  ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.info_outline,
                    title: 'About Harmony Hub',
                    subtitle: 'Version 1.0.0',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Show about dialog
                    },
                  ).animate().fadeIn(delay: 1050.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Show privacy policy
                    },
                  ).animate().fadeIn(delay: 1100.ms).slideX(begin: -0.1),

                  _buildSettingTile(
                    icon: Icons.description_outlined,
                    title: 'Terms of Service',
                    isDark: isDark,
                    onTap: () {
                      // TODO: Show terms
                    },
                  ).animate().fadeIn(delay: 1150.ms).slideX(begin: -0.1),

                  SizedBox(height: AppTheme.space32),

                  // Logout Button
                  ModernButton(
                    text: 'Sign Out',
                    onPressed: () async {
                      await authManager.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          'login',
                          (route) => false,
                        );
                      }
                    },
                    isOutline: true,
                    icon: Icons.logout,
                  )
                      .animate()
                      .fadeIn(delay: 1200.ms)
                      .scale(begin: const Offset(0.9, 0.9)),

                  SizedBox(height: AppTheme.space16),

                  // Delete Account Button
                  TextButton(
                    onPressed: () => _showDeleteAccountDialog(context, isDark),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Delete Account'),
                  ).animate().fadeIn(delay: 1250.ms),

                  SizedBox(height: AppTheme.space48),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ModernBottomNav(
        currentIndex: 3, // Profile tab
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/search');
          if (index == 2) Navigator.pushReplacementNamed(context, '/library');
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return GlassCard(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(height: AppTheme.space8),
          Text(
            value,
            style: AppTheme.displayMedium.copyWith(
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppTheme.space4),
          Text(
            title,
            style: AppTheme.caption.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppTheme.space8),
      decoration: BoxDecoration(
        color:
            isDark ? AppTheme.darkCard.withOpacity(0.3) : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.spotifyGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(
            icon,
            color: AppTheme.spotifyGreen,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.bodyLarge.copyWith(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.grey,
                ),
              )
            : null,
        trailing: trailing ??
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
        onTap: onTap,
      ),
    );
  }

  void _showAudioQualitySheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppTheme.space8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppTheme.space24),
            Text(
              'Audio Quality',
              style: AppTheme.headlineLarge.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: AppTheme.space16),
            _buildQualityOption('Low', '96 kbps', isDark),
            _buildQualityOption('Normal', '160 kbps', isDark),
            _buildQualityOption('High', '320 kbps', isDark),
            _buildQualityOption('Very High', 'Lossless', isDark),
            SizedBox(height: AppTheme.space32),
          ],
        ),
      ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildQualityOption(String quality, String bitrate, bool isDark) {
    final isSelected = _audioQuality == quality;
    return ListTile(
      title: Text(
        quality,
        style: AppTheme.bodyLarge.copyWith(
          color: isSelected
              ? AppTheme.spotifyGreen
              : isDark
                  ? Colors.white
                  : Colors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        bitrate,
        style: AppTheme.bodySmall.copyWith(
          color: Colors.grey,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: AppTheme.spotifyGreen)
          : null,
      onTap: () {
        setState(() => _audioQuality = quality);
        Navigator.pop(context);
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text(
          'Delete Account?',
          style: AppTheme.headlineLarge.copyWith(
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        content: Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              // TODO: Delete account
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
    );
  }
}
