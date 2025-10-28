import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/theme/modern_navigation.dart';
import '/services/supabase_service.dart';
import '/services/recommendation_service.dart';
import '/services/audio_service.dart';
import '/models/album.dart';
import '/models/daily_feed.dart';
import '/components/global_mini_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'home_page_model.dart';
import 'home_page_controller.dart';
export 'home_page_model.dart';

/// Modern Home Page - Spotify/Apple Music inspired
/// Features: Clean feed design, smooth scrolling, beautiful animations
class HomePageWidget extends StatefulWidget {
  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {
  late HomePageModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'homePage'});
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlobalMiniPlayer(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
      body: Column(
        children: [
          // Main Content
          Expanded(
            child: CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 80,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            isDark
                                ? AppTheme.darkSurface
                                : AppTheme.lightSurface,
                            isDark
                                ? AppTheme.darkBackground.withOpacity(0)
                                : AppTheme.lightBackground.withOpacity(0),
                          ],
                        ),
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space16,
                            vertical: AppTheme.space16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  // Profile Picture
                                  GestureDetector(
                                    onTap: () {
                                      context.pushNamed('userProfile');
                                    },
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppTheme.space12),
                                  // Greeting
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _getGreeting(),
                                          style: AppTheme.bodySmall.copyWith(
                                            color: isDark
                                                ? AppTheme.textSecondary
                                                : AppTheme.textSecondaryLight,
                                          ),
                                        ),
                                        Text(
                                          (currentUserDisplayName?.isNotEmpty ??
                                                  false)
                                              ? currentUserDisplayName!
                                              : 'Music Lover',
                                          style:
                                              AppTheme.headlineMedium.copyWith(
                                            color: isDark
                                                ? AppTheme.textPrimary
                                                : AppTheme.textPrimaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Notifications
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Show notifications
                                    },
                                    icon: Icon(
                                      Icons.notifications_outlined,
                                      color: isDark
                                          ? AppTheme.textPrimary
                                          : AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Daily Worship Feed Section (AI-Powered)
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.space12),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.space16),
                        child: FutureBuilder<DailyFeed?>(
                          future: RecommendationService()
                              .generateDailyFeed(currentUserUid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const ShimmerLoader(
                                width: double.infinity,
                                height: 200,
                              );
                            }

                            if (!snapshot.hasData || snapshot.data == null) {
                              return const SizedBox.shrink();
                            }

                            final dailyFeed = snapshot.data!;

                            return Container(
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppTheme.darkCard
                                    : AppTheme.lightCard,
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                                boxShadow: AppTheme.cardShadow,
                              ),
                              padding: const EdgeInsets.all(AppTheme.space16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with AI badge
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppTheme.space8,
                                          vertical: AppTheme.space4,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: AppTheme.primaryGradient,
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusSmall),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.auto_awesome,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                                width: AppTheme.space4),
                                            Text(
                                              'AI Generated',
                                              style: AppTheme.caption.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        _getTimeBasedIcon(),
                                        size: 28,
                                        color: AppTheme.harmonyOrange,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTheme.space12),

                                  // Title and description
                                  Text(
                                    dailyFeed.title,
                                    style: AppTheme.headlineMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.textPrimary
                                          : AppTheme.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space4),
                                  Text(
                                    dailyFeed.description ?? '',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: isDark
                                          ? AppTheme.textSecondary
                                          : AppTheme.textSecondaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.space16),

                                  // Song count and play button
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        size: 16,
                                        color: isDark
                                            ? AppTheme.textSecondary
                                            : AppTheme.textSecondaryLight,
                                      ),
                                      const SizedBox(width: AppTheme.space4),
                                      Text(
                                        '${dailyFeed.songs?.length ?? dailyFeed.songIds.length} songs',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: isDark
                                              ? AppTheme.textSecondary
                                              : AppTheme.textSecondaryLight,
                                        ),
                                      ),
                                      const Spacer(),
                                      ModernButton(
                                        text: 'Play Now',
                                        onPressed: () {
                                          if (dailyFeed.songs != null &&
                                              dailyFeed.songs!.isNotEmpty) {
                                            // TODO: Play the daily feed
                                            context.pushNamed('music_open');
                                          }
                                        },
                                        icon: Icons.play_arrow_rounded,
                                        isCompact: true,
                                        useGradient: true,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideY(begin: 0.2, end: 0, duration: 400.ms);
                          },
                        ),
                      ),
                      const SizedBox(height: AppTheme.space24),
                    ],
                  ),
                ),

                // Recommended For You Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.space32),
                      SectionHeader(
                        title: 'Recommended For You',
                        onSeeAll: () {
                          // TODO: Navigate to recommended
                        },
                      ),
                      const SizedBox(height: AppTheme.space16),
                    ],
                  ),
                ),

                // Recommended Albums Grid
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                  sliver: FutureBuilder<List<Album>>(
                    future: SupabaseService().fetchAlbums(limit: 6),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const ShimmerLoader(
                              width: double.infinity,
                              height: 200,
                            ),
                            childCount: 6,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: AppTheme.space16,
                            crossAxisSpacing: AppTheme.space16,
                            childAspectRatio: 0.75,
                          ),
                        );
                      }

                      final albums = snapshot.data!;

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final album = albums[index];
                            return _AlbumCard(
                              title: album.title,
                              artist: 'Various Artists',
                              coverUrl: album.coverImage,
                              onTap: () {
                                context.pushNamed('album');
                              },
                              isDark: isDark,
                            )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                  delay: (index * 100).ms,
                                )
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1, 1),
                                  duration: 400.ms,
                                  delay: (index * 100).ms,
                                );
                          },
                          childCount: albums.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppTheme.space16,
                          crossAxisSpacing: AppTheme.space16,
                          childAspectRatio: 0.75,
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Spacing
                const SliverToBoxAdapter(
                  child: SizedBox(
                      height: AppTheme.space64 + 80), // Extra space for nav bar
                ),
              ],
            ),
          ),
        ],
      ),
      // Modern Bottom Navigation
      bottomNavigationBar: ModernBottomNav(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              // Already on home
              break;
            case 1:
              context.pushReplacementNamed('Search');
              break;
            case 2:
              context.pushReplacementNamed('Library');
              break;
            case 3:
              context.pushReplacementNamed('userProfile');
              break;
          }
        },
      ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _getTimeBasedIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 12) return Icons.wb_sunny; // Morning
    if (hour >= 12 && hour < 17) return Icons.sunny; // Afternoon
    if (hour >= 17 && hour < 21) return Icons.wb_twilight; // Evening
    return Icons.nightlight_round; // Night
  }
}

/// Album Card Widget
class _AlbumCard extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverUrl;
  final VoidCallback onTap;
  final bool isDark;

  const _AlbumCard({
    required this.title,
    required this.artist,
    this.coverUrl,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDark ? AppTheme.darkCard.withOpacity(0.5) : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        padding: const EdgeInsets.all(AppTheme.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Album Cover
            Expanded(
              child: ModernCover(
                imageUrl: coverUrl ?? '',
                size: double.infinity,
                showPlayButton: false,
              ),
            ),
            const SizedBox(height: AppTheme.space8),
            // Album Title
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color:
                    isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            // Artist Name
            Text(
              artist,
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
    );
  }
}
