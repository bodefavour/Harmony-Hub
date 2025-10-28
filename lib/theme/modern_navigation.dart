import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';

/// Modern Bottom Navigation Bar - Spotify/Apple Music Style
/// Features: Separated design, smooth animations, haptic feedback
class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space8,
            vertical: AppTheme.space8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.library_music_rounded,
                label: 'Library',
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.space8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.harmonyOrange.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.harmonyOrange
                      : isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondaryLight,
                  size: isSelected ? 26 : 24,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTheme.caption.copyWith(
                  color: isSelected
                      ? AppTheme.harmonyOrange
                      : isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondaryLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ).animate(target: isSelected ? 1 : 0).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 200.ms,
          ),
    );
  }
}

/// Modern Now Playing Bar - Shows at bottom above navigation
class NowPlayingBar extends StatelessWidget {
  final String songTitle;
  final String artistName;
  final String? coverUrl;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;

  const NowPlayingBar({
    super.key,
    required this.songTitle,
    required this.artistName,
    this.coverUrl,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.space12,
          vertical: AppTheme.space8,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Row(
            children: [
              // Album Cover
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppTheme.radiusLarge),
                    bottomLeft: Radius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: coverUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusLarge),
                          bottomLeft: Radius.circular(AppTheme.radiusLarge),
                        ),
                        child: Image.network(
                          coverUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.music_note,
                              color: AppTheme.textSecondary,
                              size: 24,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.music_note,
                        color: AppTheme.textSecondary,
                        size: 24,
                      ),
              ),
              const SizedBox(width: AppTheme.space12),
              // Song Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      songTitle,
                      style: AppTheme.bodyLarge.copyWith(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      artistName,
                      style: AppTheme.bodySmall.copyWith(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Play/Pause Button
              Container(
                margin: const EdgeInsets.only(right: AppTheme.space8),
                decoration: BoxDecoration(
                  color: AppTheme.harmonyOrange,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: onPlayPause,
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                  iconSize: 28,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(
          begin: 1,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 300.ms);
  }
}
