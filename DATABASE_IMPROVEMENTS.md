# Database Schema Improvements

## Overview
We're adding missing columns to improve the app's ability to display rich media content.

## Changes Made

### 1. Albums Table - Added `genre` Column
**Why:** Albums should have their own genre classification for better organization and filtering.

```sql
ALTER TABLE albums 
ADD COLUMN IF NOT EXISTS genre TEXT;
```

**Benefits:**
- Filter albums by genre
- Display genre-specific album collections
- Better search and recommendation algorithms

### 2. Artists Table - Added `cover_image` Column
**Why:** Artists need both a profile image (for small avatars) and a cover image (for banner displays).

```sql
ALTER TABLE artists 
ADD COLUMN IF NOT EXISTS cover_image TEXT;
```

**Benefits:**
- `profile_image` - Used for small circular avatars in lists
- `cover_image` - Used for large banner images on artist profile pages
- Better visual hierarchy and UX

## How to Apply

### Step 1: Run the Migration Script
In your Supabase SQL Editor, run:
```bash
add_missing_columns.sql
```

This will add the new columns to your database.

### Step 2: Run the Seeder Script
After the migration, run:
```bash
seed_gospel_songs.sql
```

This will populate your database with 10 gospel songs that use the new columns.

### Step 3: Hot Restart Your App
In your Flutter terminal, press `R` to hot restart (or `Shift + R` for full restart).

## App Improvements Enabled

### Artist Profiles
- **Before:** Only small profile images
- **After:** Beautiful cover banners + profile avatars

### Album Display
- **Before:** No genre information on albums
- **After:** Genre tags visible on album cards and pages

### Search & Filtering
- **Before:** Can only filter songs by genre
- **After:** Can filter both songs AND albums by genre

### Recommendations
- **Before:** Limited to song-based recommendations
- **After:** Can recommend similar albums based on genre

## Next Steps (Optional)

### Update Existing Data
If you already have artists/albums in your database, you can update them:

```sql
-- Add cover images to existing artists
UPDATE artists 
SET cover_image = 'https://your-cdn.com/artist-covers/' || id || '.jpg'
WHERE cover_image IS NULL;

-- Add genres to existing albums based on their songs
UPDATE albums a
SET genre = (
  SELECT s.genre 
  FROM songs s 
  WHERE s.album_id = a.id 
  LIMIT 1
)
WHERE a.genre IS NULL;
```

### Update Your UI Components
Consider updating these files to display the new fields:

1. **Artist Profile Widget** (`lib/pages/artist_profile/`)
   - Show `cover_image` as a banner at the top
   - Show `profile_image` as the circular avatar

2. **Album Card Widget** (`lib/components/`)
   - Display genre tag on album cards
   - Use genre for color-coding or icons

3. **Search Results** (`lib/pages/search/`)
   - Filter by album genre
   - Show album genres in results

## Database Schema (Updated)

### Artists Table
```sql
CREATE TABLE artists (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL,
    bio TEXT,
    country TEXT DEFAULT 'NG',
    verified BOOLEAN DEFAULT FALSE,
    profile_image TEXT,  -- Small avatar (e.g., 200x200)
    cover_image TEXT,    -- Large banner (e.g., 1200x400) ✨ NEW
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Albums Table
```sql
CREATE TABLE albums (
    id UUID PRIMARY KEY,
    artist_id UUID REFERENCES artists(id),
    title TEXT NOT NULL,
    cover_image TEXT,
    release_date DATE,
    genre TEXT,  -- ✨ NEW
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Testing

After applying the changes:

1. ✅ Run migration script
2. ✅ Run seeder script
3. ✅ Hot restart app
4. ✅ Navigate to home page
5. ✅ Search for "gospel" or browse albums
6. ✅ Click on an album - verify genre is displayed
7. ✅ Click on an artist - verify cover image shows (if UI updated)

## Support

If you encounter any issues:
1. Check Supabase logs for SQL errors
2. Verify columns exist: `\d artists` and `\d albums` in SQL Editor
3. Check that seeder script ran successfully
4. Ensure app is hot restarted, not just hot reloaded
