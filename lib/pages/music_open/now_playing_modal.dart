import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/theme/app_theme.dart';
import '/services/modal_visibility_notifier.dart';

class NowPlayingModal extends StatefulWidget {
  const NowPlayingModal({
    super.key,
    required this.songTitle,
    required this.artistName,
    this.coverUrl,
    this.currentPosition = Duration.zero,
    this.totalDuration = const Duration(minutes: 3, seconds: 30),
    this.isPlaying = false,
    this.onPlayPause,
    this.onNext,
    this.onPrevious,
    this.onSeek,
    this.onClose,
  });

  final String songTitle;
  final String artistName;
  final String? coverUrl;
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;
  final Function(Duration)? onSeek;
  final VoidCallback? onClose;

  @override
  State<NowPlayingModal> createState() => _NowPlayingModalState();
}

class _NowPlayingModalState extends State<NowPlayingModal>
    with TickerProviderStateMixin {
  late AnimationController _coverController;
  late AnimationController _waveController;
  double _dragOffset = 0;
  bool _isLiked = false;
  bool _isShuffled = false;
  bool _isRepeating = false;
  double _volume = 0.7;
  final ModalVisibilityNotifier _modalNotifier = ModalVisibilityNotifier();

  @override
  void initState() {
    super.initState();
    // Notify that modal is visible
    _modalNotifier.showModal();

    _coverController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    // Notify that modal is hidden
    _modalNotifier.hideModal();

    _coverController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.delta.dy;
          if (_dragOffset < 0) _dragOffset = 0;
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          widget.onClose?.call();
          Navigator.pop(context);
        } else {
          setState(() => _dragOffset = 0);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _dragOffset, 0),
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.darkBackground,
                    AppTheme.darkCard,
                    AppTheme.darkBackground,
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.lightBackground,
                    Colors.white,
                    AppTheme.lightSurface,
                  ],
                ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.space16,
                    vertical: AppTheme.space8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down),
                        color: isDark ? Colors.white : Colors.black,
                        iconSize: 32,
                        onPressed: () {
                          widget.onClose?.call();
                          Navigator.pop(context);
                        },
                      ),
                      Column(
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: AppTheme.caption.copyWith(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: AppTheme.space4),
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        color: isDark ? Colors.white : Colors.black,
                        onPressed: () => _showMoreOptions(context, isDark),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                ),

                SizedBox(height: AppTheme.space32),

                // Album Cover
                Expanded(
                  child: Center(
                    child: Hero(
                      tag: 'albumCover_${widget.songTitle}',
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow effect
                          if (widget.isPlaying)
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.harmonyOrange.withOpacity(0.3),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            )
                                .animate(
                                    onPlay: (controller) => controller.repeat())
                                .scale(
                                  begin: const Offset(0.8, 0.8),
                                  end: const Offset(1.2, 1.2),
                                  duration: 2000.ms,
                                )
                                .fadeOut(duration: 2000.ms),

                          // Album Cover
                          Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                              boxShadow: [
                                ...AppTheme.elevatedShadow,
                                ...AppTheme.glowShadow,
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                              child: widget.coverUrl != null
                                  ? Image.network(
                                      widget.coverUrl!,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: AppTheme.harmonyOrange
                                          .withOpacity(0.3),
                                      child: Icon(
                                        Icons.music_note,
                                        size: 120,
                                        color: AppTheme.harmonyOrange,
                                      ),
                                    ),
                            ),
                          )
                              .animate()
                              .scale(duration: 400.ms, curve: Curves.easeOut),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: AppTheme.space48),

                // Song Info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.space24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.songTitle,
                                  style: AppTheme.displayMedium.copyWith(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: AppTheme.space8),
                                Text(
                                  widget.artistName,
                                  style: AppTheme.bodyLarge.copyWith(
                                    color: Colors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              _isLiked ? Icons.favorite : Icons.favorite_border,
                              color: _isLiked
                                  ? AppTheme.harmonyOrange
                                  : Colors.grey,
                              size: 32,
                            ),
                            onPressed: () {
                              setState(() => _isLiked = !_isLiked);
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                      SizedBox(height: AppTheme.space32),

                      // Progress Bar
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                              activeTrackColor: AppTheme.harmonyOrange,
                              inactiveTrackColor: Colors.grey.withOpacity(0.3),
                              thumbColor: AppTheme.harmonyOrange,
                              overlayColor:
                                  AppTheme.harmonyOrange.withOpacity(0.2),
                            ),
                            child: Slider(
                              value:
                                  widget.currentPosition.inSeconds.toDouble(),
                              max: widget.totalDuration.inSeconds.toDouble(),
                              onChanged: (value) {
                                widget.onSeek
                                    ?.call(Duration(seconds: value.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppTheme.space8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(widget.currentPosition),
                                  style: AppTheme.caption.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  _formatDuration(widget.totalDuration),
                                  style: AppTheme.caption.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms),

                      SizedBox(height: AppTheme.space32),

                      // Playback Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Shuffle
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: _isShuffled
                                  ? AppTheme.harmonyOrange
                                  : Colors.grey,
                            ),
                            iconSize: 28,
                            onPressed: () {
                              setState(() => _isShuffled = !_isShuffled);
                            },
                          ),

                          // Previous
                          IconButton(
                            icon: const Icon(Icons.skip_previous),
                            color: isDark ? Colors.white : Colors.black,
                            iconSize: 40,
                            onPressed: widget.onPrevious,
                          ),

                          // Play/Pause
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                              boxShadow: AppTheme.glowShadow,
                            ),
                            child: IconButton(
                              icon: Icon(
                                widget.isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                size: 40,
                              ),
                              color: Colors.white,
                              onPressed: widget.onPlayPause,
                            ),
                          ).animate().scale(
                                duration: 200.ms,
                                curve: Curves.easeOut,
                              ),

                          // Next
                          IconButton(
                            icon: const Icon(Icons.skip_next),
                            color: isDark ? Colors.white : Colors.black,
                            iconSize: 40,
                            onPressed: widget.onNext,
                          ),

                          // Repeat
                          IconButton(
                            icon: Icon(
                              _isRepeating ? Icons.repeat_one : Icons.repeat,
                              color: _isRepeating
                                  ? AppTheme.harmonyOrange
                                  : Colors.grey,
                            ),
                            iconSize: 28,
                            onPressed: () {
                              setState(() => _isRepeating = !_isRepeating);
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                      SizedBox(height: AppTheme.space32),

                      // Bottom Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.queue_music),
                            color: Colors.grey,
                            iconSize: 28,
                            onPressed: () {
                              // TODO: Show queue
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _volume > 0 ? Icons.volume_up : Icons.volume_off,
                              color: Colors.grey,
                            ),
                            iconSize: 28,
                            onPressed: () => _showVolumeSlider(context, isDark),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            color: Colors.grey,
                            iconSize: 28,
                            onPressed: () {
                              // TODO: Share song
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.lyrics),
                            color: Colors.grey,
                            iconSize: 28,
                            onPressed: () {
                              // TODO: Show lyrics
                            },
                          ),
                        ],
                      ).animate().fadeIn(delay: 500.ms),

                      SizedBox(height: AppTheme.space24),
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

  void _showMoreOptions(BuildContext context, bool isDark) {
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
            _buildOption(Icons.playlist_add, 'Add to playlist', isDark),
            _buildOption(Icons.album, 'View album', isDark),
            _buildOption(Icons.person, 'View artist', isDark),
            _buildOption(Icons.share, 'Share', isDark),
            _buildOption(Icons.timer, 'Sleep timer', isDark),
            SizedBox(height: AppTheme.space32),
          ],
        ),
      ).animate().slideY(begin: 1, duration: 300.ms, curve: Curves.easeOut),
    );
  }

  void _showVolumeSlider(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.darkCard : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _volume > 0.5
                  ? Icons.volume_up
                  : _volume > 0
                      ? Icons.volume_down
                      : Icons.volume_off,
              color: AppTheme.harmonyOrange,
              size: 32,
            ),
            SizedBox(height: AppTheme.space16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppTheme.harmonyOrange,
                inactiveTrackColor: Colors.grey.withOpacity(0.3),
                thumbColor: AppTheme.harmonyOrange,
                overlayColor: AppTheme.harmonyOrange.withOpacity(0.2),
              ),
              child: Slider(
                value: _volume,
                onChanged: (value) {
                  setState(() => _volume = value);
                },
              ),
            ),
            Text(
              '${(_volume * 100).toInt()}%',
              style: AppTheme.bodyLarge.copyWith(
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 200.ms, curve: Curves.easeOut),
    );
  }

  Widget _buildOption(IconData icon, String title, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: isDark ? Colors.white : Colors.black),
      title: Text(
        title,
        style: AppTheme.bodyLarge.copyWith(
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }
}
