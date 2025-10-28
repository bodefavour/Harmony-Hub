import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../theme/modern_navigation.dart';
import '../flutter_flow/flutter_flow_util.dart';

/// Global Mini Player Overlay - Wraps the entire app
/// Shows mini player persistently across all pages
class GlobalMiniPlayerOverlay extends StatefulWidget {
  final Widget child;
  final GoRouter router;

  const GlobalMiniPlayerOverlay({
    super.key,
    required this.child,
    required this.router,
  });

  @override
  State<GlobalMiniPlayerOverlay> createState() =>
      _GlobalMiniPlayerOverlayState();
}

class _GlobalMiniPlayerOverlayState extends State<GlobalMiniPlayerOverlay> {
  final AudioService _audioService = AudioService();
  final ValueNotifier<String> _currentRouteNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    // Don't initialize AudioService here - it's already initialized elsewhere
    // Calling initialize() multiple times causes GlobalKey conflicts
    
    // Update route on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateRoute();
    });
  }

  @override
  void didUpdateWidget(GlobalMiniPlayerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Widget rebuilds when route changes, so we can detect it here
    if (oldWidget.child != widget.child) {
      _updateRoute();
    }
  }

  void _updateRoute() {
    final newRoute = widget.router.routerDelegate.currentConfiguration.uri.toString();
    if (_currentRouteNotifier.value != newRoute) {
      _currentRouteNotifier.value = newRoute;
      print('DEBUG ROUTE UPDATED: $newRoute');
    }
  }

  @override
  void dispose() {
    _currentRouteNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Main app content
        widget.child,

        // Mini player overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom:
              84, // Position above bottom nav - increased to prevent overflow
          child: StreamBuilder<PlayerState>(
            stream: _audioService.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data ?? PlayerState.idle;
              final currentSong = _audioService.currentSong;

              // Only show mini player when there's a current song
              if (currentSong == null ||
                  playerState == PlayerState.idle ||
                  playerState == PlayerState.error) {
                return const SizedBox.shrink();
              }

              // Check if we're on the music open page
              // Get current route from the router
              final currentRoute = widget.router.routerDelegate.currentConfiguration.uri.toString();
              final isOnMusicOpenPage = currentRoute.contains('/musicOpen');

              print(
                  'DEBUG MINI PLAYER: currentRoute: "$currentRoute", hide: $isOnMusicOpenPage');

              // Hide mini player on music open page
              if (isOnMusicOpenPage) {
                return const SizedBox.shrink();
              }

              final isPlaying = playerState == PlayerState.playing;

              return ClipRect(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress indicator - only show if we have a valid duration
                      StreamBuilder<Duration?>(
                        stream: _audioService.durationStream,
                        builder: (context, durationSnapshot) {
                          final duration = durationSnapshot.data;
                          if (duration == null || duration.inMilliseconds <= 0) {
                            return const SizedBox.shrink();
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppTheme.space12),
                            child: StreamBuilder<Duration>(
                              stream: _audioService.positionStream,
                              builder: (context, positionSnapshot) {
                                final position =
                                    positionSnapshot.data ?? Duration.zero;
                                final progress = duration.inMilliseconds > 0
                                    ? position.inMilliseconds /
                                        duration.inMilliseconds
                                    : 0.0;

                                return LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.withOpacity(0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppTheme.harmonyOrange),
                                  minHeight: 3,
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Now Playing Bar
                      NowPlayingBar(
                        songTitle: currentSong.title,
                        artistName: currentSong.artistName ?? 'Unknown Artist',
                        coverUrl: currentSong.album?.coverImage,
                        isPlaying: isPlaying,
                        onTap: () {
                          // Navigate to full music player
                          // Use the router's pushNamed with required songId parameter
                          try {
                            widget.router.pushNamed(
                              'musicOpen',
                              pathParameters: {'songId': currentSong.id},
                            );
                            print('DEBUG: Navigation to musicOpen successful');
                          } catch (e) {
                            print('Navigation error: $e');
                          }
                        },
                        onPlayPause: () {
                          if (isPlaying) {
                            _audioService.pause();
                          } else {
                            _audioService.resume();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .slideY(
                      begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut)
                  .fadeIn(duration: 200.ms);
            },
          ),
        ),
      ],
    );
  }
}

/// Mini Player Widget - For use in persistentFooterButtons (deprecated, use overlay instead)
/// Kept for backward compatibility
class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({super.key});

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    // Don't initialize AudioService here - it's a singleton already initialized
    // _audioService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _audioService.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data ?? PlayerState.idle;
        final currentSong = _audioService.currentSong;

        // Only show mini player when there's a current song
        if (currentSong == null ||
            playerState == PlayerState.idle ||
            playerState == PlayerState.error) {
          return const SizedBox.shrink();
        }

        final isPlaying = playerState == PlayerState.playing;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            StreamBuilder<Duration>(
              stream: _audioService.positionStream,
              builder: (context, positionSnapshot) {
                return StreamBuilder<Duration?>(
                  stream: _audioService.durationStream,
                  builder: (context, durationSnapshot) {
                    final position = positionSnapshot.data ?? Duration.zero;
                    final duration = durationSnapshot.data ?? Duration.zero;
                    final progress = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;

                    return LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppTheme.harmonyOrange),
                      minHeight: 2,
                    );
                  },
                );
              },
            ),

            // Now Playing Bar
            NowPlayingBar(
              songTitle: currentSong.title,
              artistName: currentSong.artistName ?? 'Unknown Artist',
              coverUrl: currentSong.album?.coverImage,
              isPlaying: isPlaying,
              onTap: () {
                // Navigate to full music player
                context.pushNamed(
                  'musicOpen',
                  pathParameters: {'songId': currentSong.id},
                  extra: currentSong.toJson(),
                );
              },
              onPlayPause: () {
                if (isPlaying) {
                  _audioService.pause();
                } else {
                  _audioService.resume();
                }
              },
            ),
          ],
        )
            .animate()
            .slideY(begin: 1, end: 0, duration: 300.ms, curve: Curves.easeOut)
            .fadeIn(duration: 200.ms);
      },
    );
  }
}
