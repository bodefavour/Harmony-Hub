import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../theme/modern_navigation.dart';
import '../flutter_flow/flutter_flow_util.dart';

/// Global Mini Player that shows above the bottom navigation
/// Shows when a song is playing
class GlobalMiniPlayer extends StatefulWidget {
  final Widget child;

  const GlobalMiniPlayer({
    super.key,
    required this.child,
  });

  @override
  State<GlobalMiniPlayer> createState() => _GlobalMiniPlayerState();
}

class _GlobalMiniPlayerState extends State<GlobalMiniPlayer> {
  final AudioService _audioService = AudioService();

  @override
  void initState() {
    super.initState();
    _audioService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        widget.child,
        
        // Mini player overlay at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
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
                    coverUrl: currentSong.coverImage,
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
                  
                  // Bottom padding for navigation bar
                  const SizedBox(height: 80),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
