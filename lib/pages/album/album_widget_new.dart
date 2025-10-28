import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/models/album.dart';
import '/models/song.dart';
import '/services/supabase_service.dart';
import 'album_model.dart';
export 'album_model.dart';

/// Modern Album Page - Spotify/Apple Music inspired
/// Features: Album art, track list, play all, shuffle
class AlbumWidgetNew extends StatefulWidget {
  final String? albumId;

  const AlbumWidgetNew({
    super.key,
    this.albumId,
  });

  @override
  State<AlbumWidgetNew> createState() => _AlbumWidgetNewState();
}

class _AlbumWidgetNewState extends State<AlbumWidgetNew> {
  late AlbumModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Album? currentAlbum;
  List<Song> albumSongs = [];
  bool isLoading = true;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AlbumModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'album'});
    _loadAlbumData();
  }

  Future<void> _loadAlbumData() async {
    try {
      if (widget.albumId != null) {
        final albums = await SupabaseService().fetchAlbums();
        currentAlbum = albums.firstWhere((a) => a.id == widget.albumId);

        // Fetch songs for this album
        final allSongs = await SupabaseService().fetchSongs();
        albumSongs =
            allSongs.where((s) => s.albumId == widget.albumId).toList();

        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.harmonyOrange),
          ),
        ),
      );
    }

    if (currentAlbum == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.album, size: 64, color: AppTheme.harmonyOrange),
              const SizedBox(height: 16),
              Text(
                'Album not found',
                style: AppTheme.headlineMedium.copyWith(
                  color:
                      isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.safePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.harmonyOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: AppTheme.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: CustomScrollView(
          slivers: [
            // App Bar with Album Art
            SliverAppBar(
              expandedHeight: 400,
              pinned: true,
              backgroundColor:
                  isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
              leading: IconButton(
                onPressed: () => context.safePop(),
                icon: Icon(
                  Icons.arrow_back,
                  color:
                      isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    // TODO: Share album
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => isFavorite = !isFavorite);
                    // TODO: Toggle favorite
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? AppTheme.harmonyOrange
                        : (isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.harmonyOrange.withOpacity(0.3),
                            isDark
                                ? AppTheme.darkBackground
                                : AppTheme.lightBackground,
                          ],
                        ),
                      ),
                    ),
                    // Album art
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 80,
                        left: 32,
                        right: 32,
                        bottom: 80,
                      ),
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: currentAlbum!.coverImage != null
                                  ? Image.network(
                                      currentAlbum!.coverImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return _buildPlaceholderArt();
                                      },
                                    )
                                  : _buildPlaceholderArt(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Album Info and Actions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.space24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAlbum!.title,
                      style: AppTheme.headlineLarge.copyWith(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.space8),
                    Text(
                      'Various Artists',
                      style: AppTheme.headlineMedium.copyWith(
                        color: isDark
                            ? AppTheme.textSecondary
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                    if (currentAlbum!.releaseDate != null) ...[
                      const SizedBox(height: AppTheme.space8),
                      Text(
                        'Released ${currentAlbum!.releaseDate!.year}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.space24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Play all songs
                              if (albumSongs.isNotEmpty) {
                                context.pushNamed(
                                  'musicOpen',
                                  pathParameters: {
                                    'songId': albumSongs.first.id
                                  },
                                  extra: albumSongs.first.toJson(),
                                );
                              }
                            },
                            icon: const Icon(Icons.play_arrow, size: 28),
                            label: const Text('Play All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.harmonyOrange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusMedium),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTheme.space12),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Shuffle play
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            foregroundColor: isDark
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimaryLight,
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMedium),
                              side: BorderSide(
                                color: AppTheme.harmonyOrange.withOpacity(0.3),
                              ),
                            ),
                          ),
                          child: const Icon(Icons.shuffle, size: 28),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 200.ms)
                  .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms),
            ),

            // Track List Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.space24,
                  AppTheme.space16,
                  AppTheme.space24,
                  AppTheme.space12,
                ),
                child: Text(
                  'Songs (${albumSongs.length})',
                  style: AppTheme.headlineSmall.copyWith(
                    color: isDark
                        ? AppTheme.textPrimary
                        : AppTheme.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Track List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final song = albumSongs[index];
                  return _buildSongTile(song, index, isDark);
                },
                childCount: albumSongs.length,
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.space64),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderArt() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.album,
          size: 100,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSongTile(Song song, int index, bool isDark) {
    return InkWell(
      onTap: () {
        context.pushNamed(
          'musicOpen',
          pathParameters: {'songId': song.id},
          extra: song.toJson(),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.space24,
          vertical: AppTheme.space12,
        ),
        child: Row(
          children: [
            // Track number
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: AppTheme.bodyMedium.copyWith(
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: AppTheme.space16),
            // Song info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
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
                    song.artistName ?? 'Unknown Artist',
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
            // Duration
            if (song.duration != null)
              Text(
                _formatDuration(song.duration!),
                style: AppTheme.bodySmall.copyWith(
                  color: isDark
                      ? AppTheme.textSecondary
                      : AppTheme.textSecondaryLight,
                ),
              ),
            const SizedBox(width: AppTheme.space8),
            // More options
            IconButton(
              onPressed: () {
                _showSongOptions(song);
              },
              icon: Icon(
                Icons.more_vert,
                color: isDark
                    ? AppTheme.textSecondary
                    : AppTheme.textSecondaryLight,
                size: 20,
              ),
            ),
          ],
        ),
      ),
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
  }

  void _showSongOptions(Song song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusLarge),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.space12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppTheme.space16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: currentAlbum!.coverImage != null
                            ? Image.network(
                                currentAlbum!.coverImage!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 50,
                                    height: 50,
                                    color: AppTheme.harmonyOrange,
                                    child: const Icon(Icons.music_note,
                                        color: Colors.white),
                                  );
                                },
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                color: AppTheme.harmonyOrange,
                                child: const Icon(Icons.music_note,
                                    color: Colors.white),
                              ),
                      ),
                      const SizedBox(width: AppTheme.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              style: AppTheme.bodyLarge.copyWith(
                                color: isDark
                                    ? AppTheme.textPrimary
                                    : AppTheme.textPrimaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              song.artistName ?? 'Unknown',
                              style: AppTheme.bodySmall.copyWith(
                                color: isDark
                                    ? AppTheme.textSecondary
                                    : AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                _buildOptionTile(
                  icon: Icons.favorite_border,
                  label: 'Add to Favorites',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Add to favorites
                  },
                  isDark: isDark,
                ),
                _buildOptionTile(
                  icon: Icons.playlist_add,
                  label: 'Add to Playlist',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Add to playlist
                  },
                  isDark: isDark,
                ),
                _buildOptionTile(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share song
                  },
                  isDark: isDark,
                ),
                _buildOptionTile(
                  icon: Icons.person_outline,
                  label: 'Go to Artist',
                  onTap: () {
                    Navigator.pop(context);
                    if (song.artistId != null) {
                      context.pushNamed(
                        'artistProfile',
                        pathParameters: {'artistId': song.artistId!},
                      );
                    }
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: AppTheme.space16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
      ),
      title: Text(
        label,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
