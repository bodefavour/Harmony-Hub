# Gospel Songs Seeder

This script seeds gospel songs with direct URLs into your Supabase database.

## Setup

1. **Update Supabase credentials** in `lib/scripts/seed_gospel_songs.dart`:
   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_URL',  // Replace with your Supabase URL
     anonKey: 'YOUR_SUPABASE_ANON_KEY',  // Replace with your anon key
   );
   ```

2. **Install required packages** (if not already installed):
   ```bash
   flutter pub add uuid
   ```

## Using Real Gospel Song URLs

The current `gospel_songs_seed.json` uses placeholder URLs from SoundHelix. To use real gospel songs:

### Option 1: Free Music Archives
Update the `audioUrl` fields with links from:
- **Free Music Archive**: https://freemusicarchive.org/
- **Internet Archive**: https://archive.org/details/audio
- **ccMixter**: https://ccmixter.org/

### Option 2: YouTube to MP3 (for legal/licensed content)
If you have permission or the songs are public domain:
1. Find gospel songs on YouTube
2. Use a YouTube to MP3 converter
3. Host on a CDN or use direct links

### Option 3: Use Your Own Hosted Files
Upload gospel song files to:
- Cloudinary
- AWS S3
- Google Cloud Storage
- Or any CDN

Then update the `audioUrl` fields with those URLs.

## Running the Seeder

```bash
cd "c:\Users\user\Harmony Hub\Harmony-Hub"
dart run lib/scripts/seed_gospel_songs.dart
```

## What It Does

1. ✅ Reads songs from `gospel_songs_seed.json`
2. ✅ Creates artists if they don't exist
3. ✅ Creates albums if they don't exist
4. ✅ Creates songs with **direct URLs** (no file upload needed!)
5. ✅ Sets `is_local = false` so the app knows these are external URLs
6. ✅ Skips duplicates automatically

## Testing

After seeding:
1. Hot restart the app (`R` in terminal)
2. Navigate to home/search
3. Find the newly added gospel songs
4. Play them - they should work with the direct URLs!

## Notes

- The AudioService has been updated to handle both:
  - **Direct URLs** (`http://` or `https://`) - used as-is
  - **Supabase storage paths** - converted to signed URLs
- Songs with `is_local = false` use direct URLs
- No storage space used in Supabase for these songs! 🎉
