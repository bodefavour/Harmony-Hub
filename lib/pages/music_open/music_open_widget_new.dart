import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/theme/app_theme.dart';
import '/theme/modern_components.dart';
import '/models/song.dart';
import '/services/supabase_service.dart';
import '/services/audio_service.dart';
import 'music_open_model.dart';
export 'music_open_model.dart';

/// Modern Music Player Page - Full-screen immersive player
/// Features: Album art, playback controls, lyrics, share, artist profile
class MusicOpenWidgetNew extends StatefulWidget {
  final String? songId;
  final dynamic song;

  const MusicOpenWidgetNew({
    super.key,
    this.songId,
    this.song,
  });

  @override
  State<MusicOpenWidgetNew> createState() => _MusicOpenWidgetNewState();
}

class _MusicOpenWidgetNewState extends State<MusicOpenWidgetNew> {
  late MusicOpenModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Song? currentSong;
  bool isLoading = true;
  bool isPlaying = false;
  bool isFavorite = false;
  bool showLyrics = false;
  double currentPosition = 0.0;
  double totalDuration = 300.0; // Default 5 minutes

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MusicOpenModel());
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'musicOpen'});
    _loadSongData();
  }

  Future<void> _loadSongData() async {
    try {
      if (widget.song != null) {
        setState(() {
          currentSong = Song.fromJson(widget.song);
          isLoading = false;
        });
      } else if (widget.songId != null) {
        final songs = await SupabaseService().fetchSongs();
        currentSong = songs.firstWhere((s) => s.id == widget.songId);
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

    if (currentSong == null) {
      return Scaffold(
        backgroundColor:
            isDark ? AppTheme.darkBackground : AppTheme.lightBackground,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppTheme.harmonyOrange),
              const SizedBox(height: 16),
              Text(
                'Song not found',
                style: AppTheme.headlineMedium.copyWith(
                  color:
                      isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ModernButton(
                text: 'Go Back',
                onPressed: () => context.safePop(),
                variant: ModernButtonVariant.secondary,
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
        body: Stack(
          children: [
            // Background gradient based on album art
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
                    isDark
                        ? AppTheme.darkBackground
                        : AppTheme.lightBackground,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  _buildTopBar(isDark),

                  // Album Art
                  Expanded(
                    flex: 3,
                    child: _buildAlbumArt(isDark),
                  ),

                  // Song Info
                  _buildSongInfo(isDark),

                  // Progress Bar
                  _buildProgressBar(isDark),

                  // Playback Controls
                  _buildPlaybackControls(isDark),

                  // Action Buttons
                  _buildActionButtons(isDark),

                  const SizedBox(height: AppTheme.space32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => context.safePop(),
            icon: Icon(
              Icons.keyboard_arrow_down,
              size: 32,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
          Text(
            'Now Playing',
            style: AppTheme.bodyMedium.copyWith(
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show queue
            },
            icon: Icon(
              Icons.queue_music,
              size: 28,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(bool isDark) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.space32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppTheme.harmonyOrange.withOpacity(0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: AspectRatio(
            aspectRatio: 1,
            child: currentSong!.album?.coverImage != null
                ? Image.network(
                    currentSong!.album!.coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderArt(isDark);
                    },
                  )
                : _buildPlaceholderArt(isDark),
          ),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 600.ms,
          curve: Curves.easeOutBack,
        )
        .fadeIn(duration: 400.ms);
  }

  Widget _buildPlaceholderArt(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 120,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSongInfo(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space32),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.space24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentSong!.title,
                      style: AppTheme.headlineMedium.copyWith(
                        color: isDark
                            ? AppTheme.textPrimary
                            : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppTheme.space4),
                    GestureDetector(
                      onTap: () {
                        // Navigate to artist profile
                        if (currentSong!.artistId != null) {
                          context.pushNamed(
                            'artistProfile',
                            pathParameters: {
                              'artistId': currentSong!.artistId!
                            },
                          );
                        }
                      },
                      child: Text(
                        currentSong!.artistName ?? 'Unknown Artist',
                        style: AppTheme.bodyLarge.copyWith(
                          color: isDark
                              ? AppTheme.textSecondary
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => isFavorite = !isFavorite);
                  // TODO: Toggle favorite in database
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  size: 32,
                  color: isFavorite
                      ? AppTheme.harmonyOrange
                      : (isDark
                          ? AppTheme.textSecondary
                          : AppTheme.textSecondaryLight),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 200.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space32),
      child: Column(
        children: [
          const SizedBox(height: AppTheme.space24),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: AppTheme.harmonyOrange,
              inactiveTrackColor: isDark
                  ? AppTheme.textSecondary.withOpacity(0.2)
                  : AppTheme.textSecondaryLight.withOpacity(0.2),
              thumbColor: AppTheme.harmonyOrange,
              overlayColor: AppTheme.harmonyOrange.withOpacity(0.2),
            ),
            child: Slider(
              value: currentPosition,
              max: totalDuration,
              onChanged: (value) {
                setState(() => currentPosition = value);
                // TODO: Seek to position
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppTheme.space8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(currentPosition.toInt()),
                  style: AppTheme.caption.copyWith(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                Text(
                  _formatDuration(totalDuration.toInt()),
                  style: AppTheme.caption.copyWith(
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
    );
  }

  Widget _buildPlaybackControls(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.space16,
        vertical: AppTheme.space24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              // TODO: Toggle shuffle
            },
            icon: Icon(
              Icons.shuffle,
              size: 28,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Previous song
            },
            icon: Icon(
              Icons.skip_previous,
              size: 40,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.harmonyOrange.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {
                setState(() => isPlaying = !isPlaying);
                // TODO: Toggle play/pause
              },
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
          ).animate(target: isPlaying ? 1 : 0).scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 200.ms,
              ),
          IconButton(
            onPressed: () {
              // TODO: Next song
            },
            icon: Icon(
              Icons.skip_next,
              size: 40,
              color: isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Toggle repeat
            },
            icon: Icon(
              Icons.repeat,
              size: 28,
              color: isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 300.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 300.ms);
  }

  Widget _buildActionButtons(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: () {
              // TODO: Share song
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Share'),
                  content: Text('Share "${currentSong!.title}"'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            isDark: isDark,
          ),
          _ActionButton(
            icon: showLyrics ? Icons.music_note : Icons.lyrics_outlined,
            label: 'Lyrics',
            onTap: () {
              setState(() => showLyrics = !showLyrics);
              if (showLyrics) {
                _showLyricsBottomSheet(isDark);
              }
            },
            isDark: isDark,
          ),
          _ActionButton(
            icon: Icons.person_outline,
            label: 'Artist',
            onTap: () {
              if (currentSong!.artistId != null) {
                context.pushNamed(
                  'artistProfile',
                  pathParameters: {'artistId': currentSong!.artistId!},
                );
              }
            },
            isDark: isDark,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, delay: 400.ms);
  }

  void _showLyricsBottomSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: Column(
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
              padding: const EdgeInsets.all(AppTheme.space24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lyrics',
                    style: AppTheme.headlineMedium.copyWith(
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? AppTheme.textPrimary
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.space24),
                child: Text(
                  'Lyrics for "${currentSong!.title}" will be displayed here.\n\n'
                  'This feature can be enhanced to fetch lyrics from an API or database.',
                  style: AppTheme.bodyLarge.copyWith(
                    color: isDark
                        ? AppTheme.textSecondary
                        : AppTheme.textSecondaryLight,
                    height: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => showLyrics = false));
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkCard.withOpacity(0.5)
                  : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: isDark
                    ? AppTheme.textSecondary.withOpacity(0.1)
                    : AppTheme.textSecondaryLight.withOpacity(0.1),
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color:
                  isDark ? AppTheme.textPrimary : AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.space8),
          Text(
            label,
            style: AppTheme.caption.copyWith(
              color:
                  isDark ? AppTheme.textSecondary : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
