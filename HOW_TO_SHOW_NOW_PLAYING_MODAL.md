# How to Show the Now Playing Modal

## ✅ Quick & Easy (Recommended)

Use the helper function that handles everything automatically:

```dart
import 'package:harmony_hub/index.dart';

// From anywhere in your app - just call this:
showNowPlayingModal(context);
```

That's it! The helper function:
- Gets the current song from AudioService
- Shows the NowPlayingModal with all the correct parameters
- Automatically hides the mini player
- Automatically shows the mini player when closed
- Handles all the StreamBuilders for real-time updates

## 📝 Manual Approach

If you need more control, use `showModalBottomSheet` directly:

```dart
import 'package:harmony_hub/index.dart';

showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => NowPlayingModal(
    songTitle: audioService.currentSong?.title ?? 'Unknown',
    artistName: audioService.currentSong?.artistName ?? 'Unknown Artist',
    coverUrl: audioService.currentSong?.album?.coverImage,
    isPlaying: audioService.isPlaying,
    onPlayPause: () => audioService.togglePlayPause(),
    onNext: () => audioService.skipToNext(),
    onPrevious: () => audioService.skipToPrevious(),
    onClose: () => Navigator.pop(context),
  ),
);
```

The modal will automatically:
1. Hide the mini player when it opens (in `initState`)
2. Show the mini player again when it closes (in `dispose`)

## 📌 How It Works

- **Mini player tap** → Navigates to the full music open page (`/musicOpen`)
- **Mini player visibility** → Automatically hides when:
  - On the `/musicOpen` page
  - When `NowPlayingModal` is displayed
- The mini player uses a `ModalVisibilityNotifier` singleton to track modal state

## 🔧 For Other Modals

If you want other modals to also hide the mini player, use the helper function:

If you need more control, you can manually use the `ModalVisibilityNotifier`:

```dart
import 'package:harmony_hub/index.dart';

final modalNotifier = ModalVisibilityNotifier();

// Before showing modal
modalNotifier.showModal();

// Show your modal
await showModalBottomSheet(...);

// After modal closes
modalNotifier.hideModal();
```
