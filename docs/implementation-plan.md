# Harmony Hub - Implementation Plan

**Project:** Harmony Hub - Christian/Gospel Music & Podcast Platform  
**Backend:** Supabase (Auth, PostgreSQL, Storage)  
**Target Market:** Nigeria (Local-first content)  
**Status:** In Development  
**Last Updated:** October 27, 2025

---

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Implementation Phases](#implementation-phases)
4. [Database Schema](#database-schema)
5. [Core Services](#core-services)
6. [Feature Specifications](#feature-specifications)
7. [Acceptance Criteria](#acceptance-criteria)
8. [Deployment & Security](#deployment--security)
9. [Legal Considerations](#legal-considerations)

---

## Overview

Harmony Hub is a Flutter mobile application providing:
- **Christian/Gospel Music Streaming** (Nigerian artists priority)
- **Podcast Platform** (Devotionals, sermons, Christian content)
- **AI-Powered Daily Worship Feed** (Personalized playlists)
- **Artist Upload System** (With admin verification)
- **Offline Downloads** (Premium feature)
- **Playlists & Favorites**
- **Background Playback** with lock-screen controls

**Core Principle:** DO NOT modify existing theme/UI. Only extend and wire functionality.

---

## Architecture

### Tech Stack
- **Frontend:** Flutter/Dart (null-safe)
- **Backend:** Supabase
  - PostgreSQL database
  - Authentication (Google OAuth + Email)
  - Storage (Audio files, images)
  - Realtime subscriptions
- **Audio Engine:** just_audio + audio_session
- **State Management:** Provider (already in use)
- **AI Integration:** OpenAI/Gemini (serverless function)

### Project Structure
```
lib/
├── auth/
│   └── supabase_auth/         # ✅ Already implemented
├── backend/
│   └── supabase/              # ✅ Already configured
├── models/                    # 🔨 To create
│   ├── song.dart
│   ├── artist.dart
│   ├── album.dart
│   ├── podcast.dart
│   └── playlist.dart
├── services/                  # 🔨 To create
│   ├── supabase_service.dart
│   ├── audio_service.dart
│   ├── podcast_service.dart
│   ├── recommendation_service.dart
│   └── admin_service.dart
├── features/                  # 🔨 To create/enhance
│   ├── home/
│   ├── podcast/
│   ├── artist/
│   └── admin/
└── pages/                     # ✅ Already exist
```

---

## Implementation Phases

### Phase 1: Database & Infrastructure ⏱️ 2-3 days
- [x] Supabase project setup
- [ ] Create database schema (00_schema.sql)
- [ ] Seed test data (01_seed.sql)
- [ ] Create data models (Dart classes)
- [ ] Implement SupabaseService

### Phase 2: Core Audio Functionality ⏱️ 3-4 days
- [ ] Implement AudioService (streaming)
- [ ] Wire existing Music Open page to AudioService
- [ ] Add background playback
- [ ] Add lock-screen controls
- [ ] Implement download functionality
- [ ] Add offline playback support

### Phase 3: Content Features ⏱️ 4-5 days
- [ ] Create PodcastService
- [ ] Build Podcast UI (list, detail, player)
- [ ] Implement RecommendationService (rule-based)
- [ ] Build Daily Worship Feed UI
- [ ] Add playlist management
- [ ] Implement favorites/library

### Phase 4: Content Management ⏱️ 3-4 days
- [ ] Build Artist Upload screen
- [ ] Implement file upload to Supabase Storage
- [ ] Build Admin Dashboard
- [ ] Implement approval workflow
- [ ] Add content verification system

### Phase 5: AI Integration ⏱️ 2-3 days
- [ ] Create serverless function for AI recommendations
- [ ] Integrate with RecommendationService
- [ ] Implement scheduled daily feed generation
- [ ] Add personalization based on listening history

### Phase 6: Polish & Testing ⏱️ 3-4 days
- [ ] Write unit tests
- [ ] Write integration tests
- [ ] Add error handling
- [ ] Add analytics
- [ ] Performance optimization
- [ ] Create CI/CD pipeline

### Phase 7: Deployment Prep ⏱️ 2-3 days
- [ ] Security audit
- [ ] Legal compliance review
- [ ] Create deployment documentation
- [ ] Staging environment setup
- [ ] App store preparation

**Total Estimated Time:** 19-26 days

---

## Database Schema

### Core Tables

#### users (Profile Extension)
```sql
- id (uuid, FK to auth.users)
- display_name (text)
- email (text)
- country (text, default 'NG')
- preferences (jsonb) - genres, morning_pref, etc.
- created_at (timestamptz)
```

#### artists
```sql
- id (uuid, PK)
- name (text, NOT NULL)
- bio (text)
- country (text, default 'NG')
- verified (boolean, default false)
- profile_image (text) - storage path
- created_at (timestamptz)
```

#### albums
```sql
- id (uuid, PK)
- artist_id (uuid, FK)
- title (text, NOT NULL)
- cover_image (text)
- release_date (date)
- created_at (timestamptz)
```

#### songs
```sql
- id (uuid, PK)
- album_id (uuid, FK, nullable)
- artist_id (uuid, FK, nullable)
- title (text, NOT NULL)
- duration (integer) - seconds
- genre (text)
- language (text, default 'en')
- storage_path (text) - Supabase Storage path
- spotify_uri (text, nullable) - metadata only
- is_local (boolean, default true)
- explicit (boolean, default false)
- created_at (timestamptz)
```

#### podcasts
```sql
- id (uuid, PK)
- title (text, NOT NULL)
- host (text)
- description (text)
- cover_image (text)
- storage_path (text) - audio file path
- external_feed (text) - RSS feed URL
- category (text)
- language (text, default 'en')
- duration (integer)
- created_at (timestamptz)
```

#### playlists
```sql
- id (uuid, PK)
- user_id (uuid, FK)
- title (text)
- description (text)
- is_public (boolean, default false)
- created_at (timestamptz)
```

#### playlist_items
```sql
- playlist_id (uuid, FK)
- song_id (uuid, FK)
- position (integer)
- PRIMARY KEY (playlist_id, song_id)
```

#### user_library (Favorites & Downloads)
```sql
- user_id (uuid, FK)
- song_id (uuid, FK)
- is_downloaded (boolean, default false)
- downloaded_at (timestamptz)
- PRIMARY KEY (user_id, song_id)
```

#### admin_uploads (Staging)
```sql
- id (uuid, PK)
- uploader_id (uuid, FK)
- artist_name (text)
- song_title (text)
- album_title (text)
- genre (text)
- storage_path (text)
- cover_image (text)
- status (text) - pending/approved/rejected
- created_at (timestamptz)
- reviewed_by (uuid, FK, nullable)
- reviewed_at (timestamptz, nullable)
- rejection_reason (text, nullable)
```

### Indexes (Performance)
```sql
CREATE INDEX idx_songs_genre ON songs(genre);
CREATE INDEX idx_songs_artist ON songs(artist_id);
CREATE INDEX idx_podcasts_category ON podcasts(category);
CREATE INDEX idx_admin_uploads_status ON admin_uploads(status);
```

---

## Core Services

### 1. SupabaseService (`lib/services/supabase_service.dart`)

**Purpose:** Centralized Supabase client and database operations

**Key Methods:**
```dart
Future<void> initSupabase()
Future<Map<String, dynamic>> getUserProfile(String userId)
Future<void> upsertProfile(Map<String, dynamic> profile)
Future<List<Map<String, dynamic>>> fetchSongs({filters, limit, offset})
Future<List<Map<String, dynamic>>> fetchAlbums({String? artistId})
Future<List<Map<String, dynamic>>> fetchPodcasts({String? category})
Future<String> uploadToStorage(File file, String path)
Future<String> createSignedUrl(String path, Duration expiry)
```

### 2. AudioService (`lib/services/audio_service.dart`)

**Purpose:** Manage audio playback using just_audio

**Key Methods:**
```dart
Future<void> playSong(Song song)
Future<void> pause()
Future<void> resume()
Future<void> seek(Duration position)
Future<void> setVolume(double volume)
Future<void> setSpeed(double speed)
Stream<PlayerState> get playerStateStream
Stream<Duration> get positionStream
Stream<Duration?> get durationStream
Future<void> downloadSong(Song song)
Future<bool> isSongDownloaded(String songId)
```

**Features:**
- Background playback
- Lock-screen controls (audio_session)
- Buffering management
- Offline playback from cache
- Queue management

### 3. PodcastService (`lib/services/podcast_service.dart`)

**Purpose:** Manage podcast content and playback

**Key Methods:**
```dart
Future<List<Podcast>> fetchPodcasts({String? category})
Future<Podcast> getPodcastDetail(String podcastId)
Future<List<Episode>> fetchEpisodes(String podcastId)
Future<void> playEpisode(Episode episode)
Future<void> downloadEpisode(Episode episode)
Future<List<String>> getCategories()
```

### 4. RecommendationService (`lib/services/recommendation_service.dart`)

**Purpose:** Generate personalized recommendations

**Key Methods:**
```dart
Future<DailyFeed> generateDailyFeed(String userId)
Future<List<Song>> getRecommendations(filters)
Future<List<Song>> getTrendingSongs({String? genre})
Future<List<Song>> getNewReleases({String? genre})
```

**Logic:**
- **Phase 1:** Rule-based (time of day, genre preferences, tempo)
- **Phase 2:** AI-powered (call serverless function with user context)

### 5. AdminService (`lib/services/admin_service.dart`)

**Purpose:** Handle content moderation

**Key Methods:**
```dart
Future<List<AdminUpload>> getPendingUploads()
Future<void> approveUpload(String uploadId, String reviewerId)
Future<void> rejectUpload(String uploadId, String reason)
Future<void> submitUpload(UploadData data, File audioFile, File? coverImage)
```

---

## Feature Specifications

### Feature 1: Daily Worship Feed

**Screen:** Home (`lib/pages/home_page/home_page_widget.dart`)

**Requirements:**
1. Show personalized greeting: "Good morning, [Name]"
2. Display Daily Worship Feed card:
   - Cover art (collage of playlist songs)
   - Title: "Your Daily Worship"
   - Description: "10 songs curated for your morning"
   - Preview: First 3 song titles
   - Play button
3. Horizontal carousels:
   - "New Releases (Gospel Nigeria)"
   - "Trending Worship Albums"
   - "Top Podcasts This Week"
4. Optional mood picker: Worship / Praise / Reflection

**Data Flow:**
```
User opens app
  → home_controller loads
  → calls recommendation_service.generateDailyFeed(userId)
  → fetches personalized playlist
  → displays in UI
```

**AI Integration (Future):**
```
Cloud Function:
  Input: {userId, timeOfDay, last10Plays, mood, preferences}
  Process: Call OpenAI with prompt
  Output: {playlistTitle, description, songs[{songId, reason}]}
```

### Feature 2: Podcast Section

**New Screens:**
- `lib/features/podcast/podcast_screen.dart`
- `lib/features/podcast/podcast_detail.dart`

**podcast_screen.dart:**
- Category tabs: All / Devotional / Sermon / Teaching / Music
- List of podcasts with:
  - Cover image
  - Title
  - Host
  - Last episode date
  - Play button
- Search functionality
- Sort by: Latest / Popular / Alphabetical

**podcast_detail.dart:**
- Hero image/cover
- Title, host, description
- "Follow" button (save to library)
- Episodes list:
  - Episode title
  - Duration
  - Date
  - Play/Download buttons
- Share button
- External links (if RSS feed)

**Playback:**
- Reuse Music Open (Now Playing) page
- Show "Podcast" badge
- Add 15s skip forward/back buttons
- Remember playback position

### Feature 3: Artist Upload Flow

**New Screen:** `lib/features/artist/artist_upload_screen.dart`

**Form Fields:**
1. Artist Information
   - Artist name (text)
   - Bio (textarea, optional)
   - Profile image (file picker)
2. Song Details
   - Song title (text, required)
   - Album title (text, optional)
   - Genre (dropdown: Gospel, Worship, Praise, Afro-Gospel, etc.)
   - Language (dropdown: English, Yoruba, Igbo, Hausa, etc.)
   - Audio file (file picker, mp3/wav, max 50MB)
   - Cover art (file picker, jpg/png, max 5MB)
3. Rights Confirmation
   - Checkbox: "I confirm I own rights to this content"
   - Checkbox: "I agree to terms of service"

**Upload Process:**
```
1. Validate form inputs
2. Upload audio file to: uploads/{userId}/{timestamp}-{filename}
3. Upload cover art to: uploads/{userId}/covers/{timestamp}-{filename}
4. Create admin_uploads record with status='pending'
5. Show success message: "Upload submitted! Review within 24-48 hours"
6. Send notification to admin (optional)
```

**Validations:**
- Audio: mp3/wav only, max 50MB
- Image: jpg/png only, max 5MB
- All required fields filled
- File integrity check

### Feature 4: Admin Dashboard

**New Screen:** `lib/features/admin/admin_dashboard.dart`

**Layout:**
- Tab 1: Pending Uploads
  - List of admin_uploads where status='pending'
  - Each item shows:
    - Artist name
    - Song title
    - Upload date
    - Preview button (play 30s sample)
    - Approve/Reject buttons
- Tab 2: Approved Content
  - Recently approved songs
  - Quick stats
- Tab 3: Rejected Content
  - Rejected uploads with reasons

**Approval Flow:**
```
Admin reviews upload:
  → Plays audio preview
  → Checks metadata
  → Clicks Approve:
    1. Copy storage files to production paths
    2. Create/update artist record (set verified=true)
    3. Create/update album record (if provided)
    4. Create song record with production paths
    5. Update admin_uploads: status='approved', reviewed_by, reviewed_at
    6. Notify uploader (optional)
  → Clicks Reject:
    1. Show rejection reason modal
    2. Update admin_uploads: status='rejected', reason
    3. Keep files in uploads folder for appeal
    4. Notify uploader (optional)
```

**Admin Access:**
- Check user role in users table
- Add `is_admin` boolean to users table
- Protect route with admin check

### Feature 5: Offline Downloads

**Implementation:**
```dart
// In AudioService
Future<void> downloadSong(Song song) async {
  // 1. Get signed URL from Supabase Storage
  final signedUrl = await supabase_service.createSignedUrl(
    song.storagePath,
    Duration(hours: 1),
  );
  
  // 2. Download file using http
  final response = await http.get(Uri.parse(signedUrl));
  
  // 3. Save to app's internal storage
  final appDir = await getApplicationDocumentsDirectory();
  final file = File('${appDir.path}/downloads/${song.id}.mp3');
  await file.writeAsBytes(response.bodyBytes);
  
  // 4. Update user_library in Supabase
  await supabase_service.markAsDownloaded(song.id, userId);
  
  // 5. Emit download complete event
  downloadController.add(DownloadEvent(songId: song.id, status: 'complete'));
}
```

**UI Indicators:**
- Download icon on song tiles
- Progress indicator during download
- Downloaded badge when complete
- Play from cache when offline

**Premium Gate (Future):**
```dart
if (!user.isPremium && downloadCount >= 3) {
  showPremiumUpgradeDialog();
  return;
}
```

---

## Acceptance Criteria

### Phase 1: Database & Infrastructure
- [ ] Supabase schema applied without errors
- [ ] Seed data inserted (at least 5 artists, 20 songs, 5 podcasts)
- [ ] All data models created with proper serialization
- [ ] SupabaseService can fetch songs, artists, podcasts
- [ ] Signed URLs generate correctly for audio files

### Phase 2: Core Audio
- [ ] Can stream a song from Supabase Storage
- [ ] Play/Pause/Seek works correctly
- [ ] Background playback continues when app is minimized
- [ ] Lock-screen controls show song info and work
- [ ] Can download a song and play it offline
- [ ] Downloaded songs show "Downloaded" badge

### Phase 3: Content Features
- [ ] Podcast screen lists podcasts by category
- [ ] Can play a podcast episode
- [ ] Daily Worship Feed shows personalized content
- [ ] Can create a playlist
- [ ] Can add songs to favorites
- [ ] Favorites sync across devices

### Phase 4: Content Management
- [ ] Artist can submit upload via upload form
- [ ] Upload appears in admin dashboard
- [ ] Admin can approve upload → song appears in app
- [ ] Admin can reject upload → uploader gets reason
- [ ] Approved artists show "Verified" badge

### Phase 5: AI Integration
- [ ] Serverless function accepts user context
- [ ] Returns structured playlist recommendation
- [ ] Daily feed updates at 4 AM Nigeria time
- [ ] Recommendations improve with listening history

### Phase 6: Testing
- [ ] Unit tests pass for all services (>80% coverage)
- [ ] Integration test: Login → Browse → Play
- [ ] Integration test: Upload → Approve → Play
- [ ] No crashes under normal usage
- [ ] App works offline (cached content)

### Phase 7: Deployment
- [ ] Environment variables documented
- [ ] Staging environment deployed
- [ ] Security audit completed
- [ ] LEGAL.md reviewed by counsel
- [ ] App store assets prepared
- [ ] Privacy policy and terms created

---

## Deployment & Security

### Environment Variables
```env
# Supabase
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ...  # SERVER ONLY

# AI (Optional)
OPENAI_API_KEY=sk-...
# OR
GEMINI_API_KEY=...

# Spotify (Optional - Metadata only)
SPOTIFY_CLIENT_ID=...
SPOTIFY_CLIENT_SECRET=...

# Analytics (Optional)
MIXPANEL_TOKEN=...
```

### Security Checklist
- [ ] Never expose service_role_key in mobile app
- [ ] Use Row Level Security (RLS) on all tables
- [ ] Validate file uploads (type, size, content)
- [ ] Rate limit API calls
- [ ] Sanitize user inputs
- [ ] Use signed URLs with short expiry for storage
- [ ] Encrypt local downloads (optional)
- [ ] Implement CORS properly
- [ ] Add CSP headers

### Supabase RLS Policies

**songs table:**
```sql
-- Anyone can read
CREATE POLICY "songs_select" ON songs FOR SELECT TO authenticated, anon USING (true);

-- Only admins can insert/update
CREATE POLICY "songs_insert" ON songs FOR INSERT TO authenticated 
  WITH CHECK (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));
```

**user_library table:**
```sql
-- Users can only access their own library
CREATE POLICY "library_select" ON user_library FOR SELECT TO authenticated 
  USING (auth.uid() = user_id);

CREATE POLICY "library_insert" ON user_library FOR INSERT TO authenticated 
  WITH CHECK (auth.uid() = user_id);
```

**admin_uploads table:**
```sql
-- Users can see their own uploads
CREATE POLICY "uploads_select_own" ON admin_uploads FOR SELECT TO authenticated 
  USING (auth.uid() = uploader_id);

-- Admins can see all
CREATE POLICY "uploads_select_admin" ON admin_uploads FOR SELECT TO authenticated 
  USING (auth.uid() IN (SELECT id FROM users WHERE is_admin = true));
```

### Deployment Steps

1. **Staging:**
   ```bash
   # Set staging environment
   flutter build apk --release --dart-define=ENV=staging
   
   # Deploy to Firebase App Distribution or TestFlight
   ```

2. **Production:**
   ```bash
   # Set production environment
   flutter build apk --release --dart-define=ENV=production
   flutter build ios --release --dart-define=ENV=production
   
   # Submit to Play Store and App Store
   ```

3. **Serverless Functions:**
   ```bash
   # Deploy to Supabase Edge Functions
   supabase functions deploy recommendation-engine
   supabase functions deploy daily-feed-generator
   ```

---

## Legal Considerations

### Content Licensing

**CRITICAL:** Read `LEGAL.md` for full details.

1. **Uploaded Content:**
   - Users must confirm they own rights
   - Implement DMCA takedown process
   - Store uploader information
   - Get Terms of Service reviewed by legal counsel

2. **Spotify Integration:**
   - **Metadata ONLY** - do not stream Spotify tracks
   - Display "Open in Spotify" links (deep linking)
   - Cannot cache or download Spotify content
   - Review Spotify Developer Terms: https://developer.spotify.com/terms

3. **Podcast Content:**
   - Public RSS feeds: Generally OK with attribution
   - Copyrighted sermons: Get explicit permission
   - Host's rights: Verify before uploading

4. **AI-Generated Content:**
   - OpenAI: Review usage policies
   - Ensure user data privacy
   - Don't train models on user content without consent

5. **User Data:**
   - GDPR/CCPA compliance if serving EU/CA users
   - Implement data deletion
   - Privacy policy required
   - Cookie consent (web version)

### Recommended Actions Before Launch

- [ ] Consult intellectual property lawyer
- [ ] Create Terms of Service
- [ ] Create Privacy Policy
- [ ] Implement DMCA agent registration
- [ ] Get content licenses in writing
- [ ] Insurance for media company (optional)

---

## Next Steps

1. **Immediate (This Week):**
   - Create SQL schema and seed
   - Build data models
   - Implement SupabaseService
   - Test database connections

2. **Short-term (Next 2 Weeks):**
   - Implement AudioService
   - Wire existing UI to services
   - Build Podcast section
   - Create upload flow

3. **Medium-term (Next Month):**
   - Add AI recommendations
   - Complete admin dashboard
   - Write comprehensive tests
   - Security audit

4. **Long-term (Before Launch):**
   - Legal review
   - Beta testing with Nigerian users
   - Performance optimization
   - App store submission

---

## Resources

- [Supabase Documentation](https://supabase.com/docs)
- [just_audio Package](https://pub.dev/packages/just_audio)
- [audio_session Package](https://pub.dev/packages/audio_session)
- [Flutter Best Practices](https://docs.flutter.dev/development/data-and-backend/state-mgmt/intro)
- [Spotify Web API](https://developer.spotify.com/documentation/web-api)
- [OpenAI API Documentation](https://platform.openai.com/docs)

---

**Author:** AI Assistant (GitHub Copilot)  
**Date:** October 27, 2025  
**Version:** 1.0  
**Status:** In Progress
