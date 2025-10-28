# Gospel Songs Seeder

This seeds gospel songs with direct URLs into your Supabase database.

## Quick Start (SQL Method) ⚡

1. **Open Supabase Dashboard**
   - Go to your project at https://supabase.com
   - Click on "SQL Editor" in the left sidebar

2. **Run the SQL Script**
   - Open `seed_gospel_songs.sql` in a text editor
   - Copy the entire contents
   - Paste into the Supabase SQL Editor
   - Click "Run" or press `Ctrl+Enter`

3. **Verify**
   - The script will show you:
     - All seeded gospel songs with artists and albums
     - A summary count of artists, albums, and songs

4. **Done!** 🎉
   - Hot restart your app (`R` in terminal)
   - Navigate to home/search
   - Find and play the gospel songs

## What Gets Created

- **8 Gospel Artists**: Sinach, Bethel Music, Hillsong United, Hillsong Worship, Cory Asbury, Michael W. Smith, Passion, Elevation Worship
- **10 Albums**: One per artist (some artists have multiple)
- **10 Gospel Songs**: Popular worship songs with direct URLs

## Important Notes

✅ **Uses Direct URLs** - No file storage needed in Supabase
✅ **Safe to Run Multiple Times** - Uses `ON CONFLICT DO NOTHING` to prevent duplicates
✅ **is_local = false** - Marks these as external URL songs
✅ **Placeholder URLs** - Currently uses SoundHelix test URLs

## Using Real Gospel Song URLs

The script uses placeholder URLs from SoundHelix. To use real gospel songs:

### Option 1: Replace URLs in SQL File
Edit `seed_gospel_songs.sql` and replace the `storage_path` URLs with real ones:

```sql
-- Before
'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'

-- After (example with a real URL)
'https://example.com/gospel-songs/way-maker.mp3'
```

### Option 2: Update After Seeding
Run this SQL in Supabase to update specific songs:

```sql
UPDATE songs 
SET storage_path = 'YOUR_REAL_URL_HERE'
WHERE id = 's1111111-1111-1111-1111-111111111111';
```

### Where to Find Free Gospel Song URLs

- **Free Music Archive**: https://freemusicarchive.org/ (search for gospel/worship)
- **Internet Archive**: https://archive.org/details/audio (public domain music)
- **ccMixter**: https://ccmixter.org/ (Creative Commons licensed)
- **Your Own CDN**: Upload to Cloudinary, AWS S3, or Google Cloud Storage

## Alternative: Dart Script Method

If you prefer running a Dart script instead of SQL:

1. Update Supabase credentials in `lib/scripts/seed_gospel_songs.dart`
2. Run: `dart run lib/scripts/seed_gospel_songs.dart`

(Note: Requires `uuid` package and Supabase credentials)

## Testing

After seeding:
1. Hot restart the app (`R` in terminal)
2. Navigate to home/search
3. Find the newly added gospel songs
4. Play them - they should work with the direct URLs!

## How It Works

The AudioService automatically detects URL-based songs:
- If `storage_path` starts with `http://` or `https://` → Uses direct URL
- Otherwise → Creates Supabase signed URL

This means:
✅ No storage space used
✅ Fast loading
✅ Can use any public audio URL
✅ Mix local files and URLs in the same app

---

## Troubleshooting

**Songs not appearing?**
- Check Supabase SQL Editor for any errors
- Verify the songs table has the new entries
- Make sure you hot restarted the app (not just hot reload)

**Songs not playing?**
- Check that the URLs are accessible (try opening in browser)
- Check the debug console for "Using direct URL" messages
- Verify `is_local = false` for URL-based songs
