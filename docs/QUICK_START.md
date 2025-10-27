# Harmony Hub - Quick Start Guide

## 🚀 New Features Available

This guide shows you how to quickly access and use the newly implemented features.

## 📱 Available Routes

### 1. Podcasts Section
Browse and play gospel podcast episodes.

```dart
// Navigate to podcasts list
context.pushNamed('Podcasts');

// Navigate to specific podcast detail
context.pushNamed(
  'PodcastDetail',
  pathParameters: {'podcastId': 'podcast-123'},
  extra: {'podcast': podcastObject}, // Optional
);
```

**Features:**
- Grid view of all podcasts
- Play podcast with full controls
- View episode descriptions
- Navigate between episodes

### 2. Artist Upload
Artists can upload new content for admin review.

```dart
// Navigate to upload page
context.pushNamed('ArtistUpload');
```

**Features:**
- Upload audio files (MP3, AAC, WAV)
- Add cover images (JPG, PNG)
- Fill song details (title, artist, genre, album)
- Track upload progress
- Submit for admin review

**Form Fields:**
- Title* (required)
- Artist Name* (required)
- Album (optional)
- Genre (optional)
- Description/Language (optional)
- Audio File* (required)
- Cover Image (optional)

### 3. Admin Dashboard
Admins can review and moderate uploaded content.

```dart
// Navigate to admin dashboard (admin users only)
context.pushNamed('AdminDashboard');
```

**Features:**
- Three tabs: Pending / Approved / Rejected
- View upload details
- Preview audio before approval
- Approve uploads
- Reject with reason
- Real-time upload counts

**Admin Actions:**
```dart
// In admin_dashboard_controller.dart
await controller.approveUpload(uploadId, adminUserId);
await controller.rejectUpload(uploadId, adminUserId, reason);
```

## 🎵 Using Services

### Play Audio
```dart
import '../../services/audio_service.dart';

final audioService = AudioService();

// Play a song
await audioService.playSong(song);

// Play a podcast
await audioService.playPodcast(podcast);

// Stop playback
await audioService.stop();
```

### Manage Favorites
```dart
import '../../services/favorites_service.dart';

final favService = FavoritesService();

// Add to favorites
await favService.addFavorite(userId, songId, 'song');

// Remove from favorites
await favService.removeFavorite(userId, songId);

// Check if favorited
final isFav = await favService.isFavorite(userId, songId);

// Get user's favorites
final favorites = await favService.getUserFavorites(userId);
```

### Get Recommendations
```dart
import '../../services/recommendation_service.dart';

final recService = RecommendationService();

// Get personalized recommendations
final recommended = await recService.getRecommendedSongs(userId);

// Get trending songs
final trending = await recService.getTrendingSongs(limit: 20);

// Get genre-based recommendations
final gospel = await recService.getSongsByGenre('Gospel', limit: 10);
```

### Upload Content (Artists)
```dart
import '../../services/admin_service.dart';
import 'dart:io';

final adminService = AdminService();

// Submit upload
final upload = await adminService.submitUpload(
  uploaderId: currentUserId,
  artistName: 'Mercy Chinwo',
  songTitle: 'New Song',
  albumTitle: 'Album Name',
  genre: 'Gospel',
  language: 'en',
  audioFile: File('/path/to/audio.mp3'),
  coverImage: File('/path/to/cover.jpg'), // optional
);

// Get user's uploads
final uploads = await adminService.getUserUploads(userId);
```

## 🧭 Adding Navigation UI Elements

### Bottom Navigation Bar
Add podcasts to your bottom nav:

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(icon: Icon(Icons.podcasts), label: 'Podcasts'), // NEW
    BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
  ],
  onTap: (index) {
    switch (index) {
      case 0:
        context.pushNamed('HomePage');
        break;
      case 1:
        context.pushNamed('Search');
        break;
      case 2:
        context.pushNamed('Podcasts'); // NEW
        break;
      case 3:
        context.pushNamed('Library');
        break;
    }
  },
)
```

### Drawer Menu
Add upload and admin options:

```dart
Drawer(
  child: ListView(
    children: [
      ListTile(
        leading: Icon(Icons.home),
        title: Text('Home'),
        onTap: () => context.pushNamed('HomePage'),
      ),
      ListTile(
        leading: Icon(Icons.podcasts),
        title: Text('Podcasts'),
        onTap: () => context.pushNamed('Podcasts'),
      ),
      // Show for artists
      if (isArtist)
        ListTile(
          leading: Icon(Icons.upload),
          title: Text('Upload Content'),
          onTap: () => context.pushNamed('ArtistUpload'),
        ),
      // Show for admins
      if (isAdmin)
        ListTile(
          leading: Icon(Icons.admin_panel_settings),
          title: Text('Admin Dashboard'),
          onTap: () => context.pushNamed('AdminDashboard'),
        ),
    ],
  ),
)
```

### Artist Profile Menu
Add upload button to artist profiles:

```dart
// In artist_profile_widget.dart
FloatingActionButton(
  onPressed: () => context.pushNamed('ArtistUpload'),
  child: Icon(Icons.upload),
  tooltip: 'Upload Content',
)
```

## 📦 Models & Data Structure

### Podcast Model
```dart
class Podcast {
  final String id;
  final String title;
  final String host;           // Artist/host name
  final String coverImage;     // Cover image URL
  final String storagePath;    // Audio file path
  final DateTime publishedAt;
  final String? description;
  final int? duration;
  final String? category;
}
```

### AdminUpload Model
```dart
class AdminUpload {
  final String id;
  final String uploaderId;     // User who uploaded
  final String artistName;
  final String songTitle;
  final String storagePath;    // Audio file path in storage
  final String? albumTitle;
  final String? genre;
  final String? language;
  final String? coverImage;
  final UploadStatus status;   // pending, approved, rejected
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? reviewedBy;    // Admin who reviewed
  final DateTime? reviewedAt;
  final String? rejectionReason;
}

enum UploadStatus {
  pending,
  approved,
  rejected
}
```

## 🎨 UI Components

### Loading States
All controllers include loading states:

```dart
if (controller.isLoading) {
  return Center(child: CircularProgressIndicator());
}
```

### Error Handling
All controllers include error handling:

```dart
if (controller.error != null) {
  return Center(
    child: Text(
      'Error: ${controller.error}',
      style: TextStyle(color: Colors.red),
    ),
  );
}
```

### Upload Progress
Artist upload shows progress:

```dart
if (controller.isUploading) {
  return Column(
    children: [
      CircularProgressIndicator(value: controller.uploadProgress),
      Text('${(controller.uploadProgress * 100).toInt()}%'),
    ],
  );
}
```

## 🔐 Authentication

All new routes require authentication:

```dart
// In nav.dart
FFRoute(
  name: 'Podcasts',
  path: '/podcasts',
  requireAuth: true, // User must be logged in
  builder: (context, params) => PodcastsWidget(),
)
```

Unauthenticated users will be redirected to login.

## 📊 Supabase Integration

### Database Tables Used
- `songs` - Production music tracks
- `podcasts` - Podcast episodes
- `admin_uploads` - Pending uploads for review
- `artists` - Artist profiles
- `favorites` - User favorites
- `listening_history` - User listening data

### Storage Buckets
- `uploads` - Temporary uploads pending review
- `songs` - Approved song files
- `podcasts` - Podcast audio files
- `images` - Cover images and artwork

## 🛠️ Development Tips

### Testing Navigation
```dart
// In any widget, test navigation:
ElevatedButton(
  onPressed: () {
    context.pushNamed('Podcasts');
  },
  child: Text('Test Podcasts'),
)
```

### Debugging Controllers
```dart
// Add debug prints to controllers:
@override
void initState() {
  super.initState();
  controller.addListener(() {
    print('Controller state changed: ${controller.isLoading}');
  });
}
```

### Hot Reload vs Hot Restart
- **Hot Reload** (`r` in terminal) - For UI changes
- **Hot Restart** (`R` in terminal) - For route/navigation changes

## 📝 Next Implementation Targets

### 1. Wire Music Player
Update `music_open_widget.dart`:
```dart
// Replace hardcoded player with:
final audioService = AudioService();
await audioService.playSong(song);
```

### 2. Update Library Page
Update `library_widget.dart` with real data:
```dart
final favorites = await favService.getUserFavorites(userId);
final playlists = await supabaseService.getUserPlaylists(userId);
```

### 3. Update Search Page
Update `search_widget.dart` with recommendations:
```dart
final results = await recService.searchSongs(query);
final trending = await recService.getTrendingSongs();
```

## 🎯 Quick Commands

```bash
# Run app
flutter run

# Hot reload
r

# Hot restart
R

# Check for errors
flutter analyze

# Format code
flutter format lib/

# Clean build
flutter clean && flutter pub get
```

## 📚 Documentation References

- **Navigation Guide:** `docs/NAVIGATION_GUIDE.md`
- **Session Summary:** `docs/SESSION_SUMMARY.md`
- **Implementation Plan:** `docs/IMPLEMENTATION_PLAN.md`

---

**Last Updated:** Current Session  
**Status:** All features functional with 0 compilation errors ✅
