import 'package:flutter/material.dart';
import '/pages/music_open/now_playing_modal.dart';
import '/services/audio_service.dart';

/// Helper function to show the Now Playing Modal from anywhere in the app
/// The modal automatically handles hiding/showing the mini player
void showNowPlayingModal(BuildContext context) {
  final audioService = AudioService();
  final currentSong = audioService.currentSong;

  if (currentSong == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No song is currently playing')),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => StreamBuilder<PlayerState>(
      stream: audioService.playerStateStream,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data == PlayerState.playing;

        return StreamBuilder<Duration>(
          stream: audioService.positionStream,
          builder: (context, positionSnapshot) {
            return StreamBuilder<Duration?>(
              stream: audioService.durationStream,
              builder: (context, durationSnapshot) {
                final position = positionSnapshot.data ?? Duration.zero;
                final duration =
                    durationSnapshot.data ?? const Duration(minutes: 3);

                return NowPlayingModal(
                  songTitle: currentSong.title,
                  artistName: currentSong.artistName ?? 'Unknown Artist',
                  coverUrl: currentSong.album?.coverImage,
                  currentPosition: position,
                  totalDuration: duration,
                  isPlaying: isPlaying,
                  onPlayPause: () {
                    if (isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.resume();
                    }
                  },
                  onNext: () => audioService.skipToNext(),
                  onPrevious: () => audioService.skipToPrevious(),
                  onSeek: (newPosition) => audioService.seek(newPosition),
                  onClose: () => Navigator.pop(context),
                );
              },
            );
          },
        );
      },
    ),
  );
}
