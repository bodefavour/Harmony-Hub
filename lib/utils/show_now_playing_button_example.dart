import 'package:flutter/material.dart';
import '/utils/show_now_playing_modal.dart';
import '/theme/app_theme.dart';

/// Example: How to add a button to show the Now Playing Modal
/// Add this anywhere in your app where you want to show the modal

class ShowNowPlayingButton extends StatelessWidget {
  const ShowNowPlayingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => showNowPlayingModal(context),
      icon: const Icon(Icons.music_note),
      label: const Text('Show Now Playing'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.harmonyOrange,
        foregroundColor: Colors.white,
      ),
    );
  }
}

/// Or use an IconButton version:
class ShowNowPlayingIconButton extends StatelessWidget {
  const ShowNowPlayingIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.queue_music),
      onPressed: () => showNowPlayingModal(context),
      tooltip: 'Show Now Playing',
    );
  }
}

/// Or use a FloatingActionButton:
class ShowNowPlayingFAB extends StatelessWidget {
  const ShowNowPlayingFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showNowPlayingModal(context),
      backgroundColor: AppTheme.harmonyOrange,
      child: const Icon(Icons.music_note),
    );
  }
}
