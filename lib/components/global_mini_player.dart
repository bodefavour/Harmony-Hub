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
  String _currentRoute = '';

  @override
  void initState() {
    super.initState();
    _audioService.initialize();

    // Listen to router location changes
    widget.router.routerDelegate.addListener(_onRouteChanged);
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    // Update current route when router changes
    final location = widget.router.routerDelegate.currentConfiguration;
    setState(() {
      _currentRoute = location.uri.toString();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update current route whenever dependencies change
    final route = ModalRoute.of(context);
    if (route != null && route.settings.name != null) {
      _currentRoute = route.settings.name!;
    }
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
          bottom: 80, // Position above bottom nav (80px height)
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
              // Use widget.child's runtimeType as a more reliable check
              final childType = widget.child.runtimeType.toString();
              final isOnMusicOpenPage = childType.contains('MusicOpen') ||
                  _currentRoute.toLowerCase().contains('musicopen') ||
                  _currentRoute.toLowerCase().contains('/music');

              // Hide mini player on music open page
              if (isOnMusicOpenPage) {
                return const SizedBox.shrink();
              }

              final isPlaying = playerState == PlayerState.playing;

              return Material(
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
                                valueColor: const AlwaysStoppedAnimation<Color>(
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
                        // Navigate to full music player using the passed router
                        try {
                          widget.router.pushNamed(
                            'musicOpen',
                            pathParameters: {'songId': currentSong.id},
                            extra: currentSong.toJson(),
                          );
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
    _audioService.initialize();
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
