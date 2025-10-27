-- =====================================================
-- Harmony Hub - Database Schema
-- Backend: Supabase PostgreSQL
-- Version: 1.0
-- Created: October 27, 2025
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- USERS & PROFILES
-- =====================================================

-- Extend Supabase auth.users with profile information
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    email TEXT,
    country TEXT DEFAULT 'NG',
    preferences JSONB DEFAULT '{
        "genres": ["Gospel", "Worship", "Praise"],
        "morning_preference": "06:00",
        "language": "en"
    }'::jsonb,
    is_admin BOOLEAN DEFAULT FALSE,
    is_premium BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- CONTENT: ARTISTS, ALBUMS, SONGS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.artists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    bio TEXT,
    country TEXT DEFAULT 'NG',
    verified BOOLEAN DEFAULT FALSE,
    profile_image TEXT, -- Supabase Storage path: artists/{id}/profile.jpg
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.albums (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    artist_id UUID REFERENCES public.artists(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    cover_image TEXT, -- Supabase Storage path: albums/{id}/cover.jpg
    release_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.songs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    album_id UUID REFERENCES public.albums(id) ON DELETE SET NULL,
    artist_id UUID REFERENCES public.artists(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    duration INTEGER, -- in seconds
    genre TEXT,
    language TEXT DEFAULT 'en',
    storage_path TEXT NOT NULL, -- Supabase Storage path: songs/{id}/audio.mp3
    spotify_uri TEXT, -- Optional: spotify:track:xxx (metadata only, no streaming)
    is_local BOOLEAN DEFAULT TRUE, -- True if hosted on Supabase, False if external
    explicit BOOLEAN DEFAULT FALSE,
    play_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- PODCASTS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.podcasts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    host TEXT,
    description TEXT,
    cover_image TEXT, -- Supabase Storage path: podcasts/{id}/cover.jpg
    storage_path TEXT, -- Supabase Storage path: podcasts/{id}/episodes/{episode_id}.mp3
    external_feed TEXT, -- RSS feed URL (if external podcast)
    category TEXT, -- Devotional, Sermon, Teaching, Music, etc.
    language TEXT DEFAULT 'en',
    duration INTEGER, -- in seconds
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- USER INTERACTIONS: PLAYLISTS, LIBRARY, HISTORY
-- =====================================================

CREATE TABLE IF NOT EXISTS public.playlists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    cover_image TEXT, -- Optional custom cover
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.playlist_items (
    playlist_id UUID REFERENCES public.playlists(id) ON DELETE CASCADE,
    song_id UUID REFERENCES public.songs(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (playlist_id, song_id)
);

-- User's favorites and downloaded songs
CREATE TABLE IF NOT EXISTS public.user_library (
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    song_id UUID REFERENCES public.songs(id) ON DELETE CASCADE,
    is_downloaded BOOLEAN DEFAULT FALSE,
    downloaded_at TIMESTAMPTZ,
    added_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (user_id, song_id)
);

-- Listening history for recommendations
CREATE TABLE IF NOT EXISTS public.play_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    song_id UUID REFERENCES public.songs(id) ON DELETE CASCADE,
    played_at TIMESTAMPTZ DEFAULT NOW(),
    completion_percentage INTEGER DEFAULT 0 -- 0-100
);

-- =====================================================
-- ADMIN: UPLOAD MODERATION
-- =====================================================

CREATE TABLE IF NOT EXISTS public.admin_uploads (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    uploader_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    artist_name TEXT NOT NULL,
    song_title TEXT NOT NULL,
    album_title TEXT,
    genre TEXT,
    language TEXT DEFAULT 'en',
    storage_path TEXT NOT NULL, -- Temp path: uploads/{uploader_id}/{timestamp}-{filename}
    cover_image TEXT, -- Temp path: uploads/{uploader_id}/covers/{timestamp}
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    reviewed_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMPTZ,
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- DAILY WORSHIP FEED (AI-Generated Playlists)
-- =====================================================

CREATE TABLE IF NOT EXISTS public.daily_feeds (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'Your Daily Worship',
    description TEXT,
    song_ids UUID[] NOT NULL, -- Array of song IDs
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    expires_at TIMESTAMPTZ DEFAULT NOW() + INTERVAL '24 hours',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- Songs
CREATE INDEX IF NOT EXISTS idx_songs_genre ON public.songs(genre);
CREATE INDEX IF NOT EXISTS idx_songs_artist ON public.songs(artist_id);
CREATE INDEX IF NOT EXISTS idx_songs_album ON public.songs(album_id);
CREATE INDEX IF NOT EXISTS idx_songs_local ON public.songs(is_local);
CREATE INDEX IF NOT EXISTS idx_songs_play_count ON public.songs(play_count DESC);

-- Podcasts
CREATE INDEX IF NOT EXISTS idx_podcasts_category ON public.podcasts(category);
CREATE INDEX IF NOT EXISTS idx_podcasts_published ON public.podcasts(published_at DESC);

-- Playlists
CREATE INDEX IF NOT EXISTS idx_playlists_user ON public.playlists(user_id);
CREATE INDEX IF NOT EXISTS idx_playlists_public ON public.playlists(is_public) WHERE is_public = TRUE;

-- User Library
CREATE INDEX IF NOT EXISTS idx_library_user ON public.user_library(user_id);
CREATE INDEX IF NOT EXISTS idx_library_downloaded ON public.user_library(user_id, is_downloaded) WHERE is_downloaded = TRUE;

-- Play History
CREATE INDEX IF NOT EXISTS idx_history_user ON public.play_history(user_id, played_at DESC);
CREATE INDEX IF NOT EXISTS idx_history_song ON public.play_history(song_id);

-- Admin Uploads
CREATE INDEX IF NOT EXISTS idx_admin_uploads_status ON public.admin_uploads(status);
CREATE INDEX IF NOT EXISTS idx_admin_uploads_uploader ON public.admin_uploads(uploader_id);

-- Daily Feeds
CREATE INDEX IF NOT EXISTS idx_daily_feeds_user ON public.daily_feeds(user_id, generated_at DESC);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.artists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.albums ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.podcasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.playlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.playlist_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_library ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.play_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_uploads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_feeds ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- RLS POLICIES: USERS
-- =====================================================

-- Users can read their own profile
CREATE POLICY "users_select_own" ON public.users
    FOR SELECT TO authenticated
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "users_update_own" ON public.users
    FOR UPDATE TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "users_insert_own" ON public.users
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() = id);

-- =====================================================
-- RLS POLICIES: CONTENT (PUBLIC READ)
-- =====================================================

-- Anyone can read artists, albums, songs, podcasts
CREATE POLICY "artists_select" ON public.artists FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "albums_select" ON public.albums FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "songs_select" ON public.songs FOR SELECT TO authenticated, anon USING (true);
CREATE POLICY "podcasts_select" ON public.podcasts FOR SELECT TO authenticated, anon USING (true);

-- Only admins can insert/update/delete content
CREATE POLICY "artists_admin_only" ON public.artists FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE))
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

CREATE POLICY "albums_admin_only" ON public.albums FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE))
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

CREATE POLICY "songs_admin_only" ON public.songs FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE))
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

CREATE POLICY "podcasts_admin_only" ON public.podcasts FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE))
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

-- =====================================================
-- RLS POLICIES: PLAYLISTS
-- =====================================================

-- Users can read public playlists or their own
CREATE POLICY "playlists_select" ON public.playlists
    FOR SELECT TO authenticated
    USING (is_public = TRUE OR user_id = auth.uid());

-- Users can only manage their own playlists
CREATE POLICY "playlists_insert" ON public.playlists
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "playlists_update" ON public.playlists
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "playlists_delete" ON public.playlists
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

-- Playlist items follow playlist permissions
CREATE POLICY "playlist_items_select" ON public.playlist_items
    FOR SELECT TO authenticated
    USING (
        playlist_id IN (
            SELECT id FROM public.playlists 
            WHERE is_public = TRUE OR user_id = auth.uid()
        )
    );

CREATE POLICY "playlist_items_manage" ON public.playlist_items
    FOR ALL TO authenticated
    USING (
        playlist_id IN (SELECT id FROM public.playlists WHERE user_id = auth.uid())
    )
    WITH CHECK (
        playlist_id IN (SELECT id FROM public.playlists WHERE user_id = auth.uid())
    );

-- =====================================================
-- RLS POLICIES: USER LIBRARY
-- =====================================================

-- Users can only access their own library
CREATE POLICY "library_select" ON public.user_library
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "library_insert" ON public.user_library
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "library_update" ON public.user_library
    FOR UPDATE TO authenticated
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "library_delete" ON public.user_library
    FOR DELETE TO authenticated
    USING (user_id = auth.uid());

-- =====================================================
-- RLS POLICIES: PLAY HISTORY
-- =====================================================

-- Users can only read/write their own history
CREATE POLICY "history_select" ON public.play_history
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "history_insert" ON public.play_history
    FOR INSERT TO authenticated
    WITH CHECK (user_id = auth.uid());

-- Admins can read all history (for analytics)
CREATE POLICY "history_admin" ON public.play_history
    FOR SELECT TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

-- =====================================================
-- RLS POLICIES: ADMIN UPLOADS
-- =====================================================

-- Users can see their own uploads
CREATE POLICY "uploads_select_own" ON public.admin_uploads
    FOR SELECT TO authenticated
    USING (uploader_id = auth.uid());

-- Users can insert their own uploads
CREATE POLICY "uploads_insert" ON public.admin_uploads
    FOR INSERT TO authenticated
    WITH CHECK (uploader_id = auth.uid());

-- Admins can see all uploads
CREATE POLICY "uploads_select_admin" ON public.admin_uploads
    FOR SELECT TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

-- Admins can update/delete uploads
CREATE POLICY "uploads_manage_admin" ON public.admin_uploads
    FOR ALL TO authenticated
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE))
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

-- =====================================================
-- RLS POLICIES: DAILY FEEDS
-- =====================================================

-- Users can only read their own feeds
CREATE POLICY "feeds_select" ON public.daily_feeds
    FOR SELECT TO authenticated
    USING (user_id = auth.uid());

-- Only system/admin can create feeds
CREATE POLICY "feeds_insert" ON public.daily_feeds
    FOR INSERT TO authenticated
    WITH CHECK (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables with updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_artists_updated_at BEFORE UPDATE ON public.artists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_albums_updated_at BEFORE UPDATE ON public.albums
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_songs_updated_at BEFORE UPDATE ON public.songs
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_podcasts_updated_at BEFORE UPDATE ON public.podcasts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_playlists_updated_at BEFORE UPDATE ON public.playlists
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_admin_uploads_updated_at BEFORE UPDATE ON public.admin_uploads
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to increment play count
CREATE OR REPLACE FUNCTION increment_play_count(song_uuid UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.songs
    SET play_count = play_count + 1
    WHERE id = song_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- STORAGE BUCKETS (Run via Supabase Dashboard or CLI)
-- =====================================================

-- Run these commands in Supabase SQL Editor or via CLI:
/*
INSERT INTO storage.buckets (id, name, public) VALUES 
    ('artists', 'artists', true),
    ('albums', 'albums', true),
    ('songs', 'songs', false), -- Private: use signed URLs
    ('podcasts', 'podcasts', false),
    ('uploads', 'uploads', false); -- For pending admin review

-- Storage policies (adjust as needed)
CREATE POLICY "Public read access" ON storage.objects FOR SELECT
    USING (bucket_id IN ('artists', 'albums'));

CREATE POLICY "Authenticated users can upload" ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'uploads' AND auth.role() = 'authenticated');

CREATE POLICY "Admins can manage all" ON storage.objects FOR ALL
    USING (auth.uid() IN (SELECT id FROM public.users WHERE is_admin = TRUE));
*/

-- =====================================================
-- SCHEMA COMPLETE
-- =====================================================

-- Grant permissions (if using service role)
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- Refresh schema cache
NOTIFY pgrst, 'reload schema';
