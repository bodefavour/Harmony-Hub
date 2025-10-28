import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/theme/modern_navigation.dart';
import '/services/supabase_service.dart';
import '/models/song.dart';
import '/models/album.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_page_model.dart';
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

    return Scaffold(
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
                  expandedHeight: 120,
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

                // Recently Played Section
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.space24),
                      SectionHeader(
                        title: 'Recently Played',
                        onSeeAll: () {
                          // TODO: Navigate to recently played
                        },
                      ),
                      const SizedBox(height: AppTheme.space16),
                    ],
                  ),
                ),

                // Recently Played List
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                  sliver: FutureBuilder<List<Song>>(
                    future: SupabaseService().fetchSongs(limit: 10),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const Padding(
                              padding:
                                  EdgeInsets.only(bottom: AppTheme.space12),
                              child: ShimmerLoader(
                                width: double.infinity,
                                height: 70,
                              ),
                            ),
                            childCount: 5,
                          ),
                        );
                      }

                      final songs = snapshot.data!;

                      if (songs.isEmpty) {
                        return const SliverToBoxAdapter(
                          child: EmptyState(
                            icon: Icons.music_note_outlined,
                            title: 'No songs yet',
                            message:
                                'Start exploring and add songs to your library',
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return _SongTile(
                              title: song.title,
                              artist: song.artistName ?? 'Unknown Artist',
                              coverUrl: song.album?.coverImage,
                              onTap: () {
                                context.pushNamed(
                                  'musicOpen',
                                  pathParameters: {'songId': song.id},
                                  extra: song.toJson(),
                                );
                              },
                              isDark: isDark,
                            )
                                .animate()
                                .fadeIn(
                                  duration: 300.ms,
                                  delay: (index * 50).ms,
                                )
                                .slideX(
                                  begin: 0.2,
                                  end: 0,
                                  duration: 400.ms,
                                  delay: (index * 50).ms,
                                );
                          },
                          childCount: songs.length,
                        ),
                      );
                    },
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
              context.pushNamed('Search');
              break;
            case 2:
              context.pushNamed('Library');
              break;
            case 3:
              context.pushNamed('userProfile');
              break;
          }
        },
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Song Tile Widget
class _SongTile extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverUrl;
  final VoidCallback onTap;
  final bool isDark;

  const _SongTile({
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
        margin: const EdgeInsets.only(bottom: AppTheme.space12),
        padding: const EdgeInsets.all(AppTheme.space12),
        decoration: BoxDecoration(
          color:
              isDark ? AppTheme.darkCard.withOpacity(0.5) : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Row(
          children: [
            // Cover Image
            ModernCover(
              imageUrl: coverUrl ?? '',
              size: 50,
            ),
            const SizedBox(width: AppTheme.space12),
            // Song Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyLarge.copyWith(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
            // More Options
            IconButton(
              onPressed: () {
                // TODO: Show options menu
              },
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
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
                showPlayButton: true,
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
