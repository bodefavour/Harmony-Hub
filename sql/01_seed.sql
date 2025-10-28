-- =====================================================
-- Harmony Hub - Seed Data
-- Nigerian Christian/Gospel Content
-- Version: 1.0
-- Created: October 27, 2025
-- =====================================================

-- NOTE: Run this AFTER 00_schema.sql

-- =====================================================
-- SEED: ARTISTS (Nigerian Gospel/Christian Artists)
-- =====================================================

INSERT INTO public.artists (id, name, bio, country, verified, profile_image) VALUES
    ('a1111111-1111-1111-1111-111111111111', 'Sinach', 'International gospel artist known for "Way Maker" and powerful worship anthems. Nigerian music minister with global impact.', 'NG', true, 'artists/sinach/profile.jpg'),
    ('a2222222-2222-2222-2222-222222222222', 'Nathaniel Bassey', 'Trumpet player and worship leader. Known for "Imela", "Olowogbogboro", and midnight praise sessions.', 'NG', true, 'artists/nathaniel-bassey/profile.jpg'),
    ('a3333333-3333-3333-3333-333333333333', 'Tim Godfrey', 'Contemporary gospel artist and leader of Xtreme Crew. Known for high-energy worship and "Nara" featuring Travis Greene.', 'NG', true, 'artists/tim-godfrey/profile.jpg'),
    ('a4444444-4444-4444-4444-444444444444', 'Mercy Chinwo', 'Powerful vocalist and songwriter. Known for "Excess Love", "Obinasom", and uplifting worship songs.', 'NG', true, 'artists/mercy-chinwo/profile.jpg'),
    ('a5555555-5555-5555-5555-555555555555', 'Frank Edwards', 'Producer, singer, and founder of Rocktown Records. Known for "Miye Ruwe", "Suddenly", and contemporary Christian music.', 'NG', true, 'artists/frank-edwards/profile.jpg'),
    ('a6666666-6666-6666-6666-666666666666', 'Tope Alabi', 'Gospel singer and actress. Known for Yoruba praise worship and songs like "Logan Ti O De" and "Emi Mimo".', 'NG', true, 'artists/tope-alabi/profile.jpg'),
    ('a7777777-7777-7777-7777-777777777777', 'Judikay', 'Contemporary worship leader signed to EeZee Conceptz. Known for "Omemma" and "More Than Gold".', 'NG', true, 'artists/judikay/profile.jpg'),
    ('a8888888-8888-8888-8888-888888888888', 'Eben', 'Spirit-filled worship leader and songwriter. Known for "Victory", "Nothing Is Impossible", and energetic praise.', 'NG', true, 'artists/eben/profile.jpg');

-- =====================================================
-- SEED: ALBUMS
-- =====================================================

INSERT INTO public.albums (id, artist_id, title, cover_image, release_date) VALUES
    ('b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Way Maker', 'albums/sinach-way-maker/cover.jpg', '2016-01-01'),
    ('b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 'Imela', 'albums/nathaniel-bassey-imela/cover.jpg', '2017-05-15'),
    ('b3333333-3333-3333-3333-333333333333', 'a3333333-3333-3333-3333-333333333333', 'Greater', 'albums/tim-godfrey-greater/cover.jpg', '2018-11-10'),
    ('b4444444-4444-4444-4444-444444444444', 'a4444444-4444-4444-4444-444444444444', 'The Cross My Gaze', 'albums/mercy-chinwo-the-cross/cover.jpg', '2018-03-20'),
    ('b5555555-5555-5555-5555-555555555555', 'a5555555-5555-5555-5555-555555555555', 'Unlimited', 'albums/frank-edwards-unlimited/cover.jpg', '2020-08-01'),
    ('b6666666-6666-6666-6666-666666666666', 'a7777777-7777-7777-7777-777777777777', 'From This Heart', 'albums/judikay-from-this-heart/cover.jpg', '2021-06-18');

-- =====================================================
-- SEED: SONGS (20+ Nigerian Gospel Songs)
-- =====================================================

INSERT INTO public.songs (id, album_id, artist_id, title, duration, genre, language, storage_path, is_local) VALUES
    -- Sinach
    ('11111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Way Maker', 360, 'Worship', 'en', 'songs/sinach/way-maker.mp3', true),
    ('11111112-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'I Know Who I Am', 285, 'Worship', 'en', 'songs/sinach/i-know-who-i-am.mp3', true),
    ('11111113-1111-1111-1111-111111111111', null, 'a1111111-1111-1111-1111-111111111111', 'There Is An Overflow', 340, 'Worship', 'en', 'songs/sinach/there-is-an-overflow.mp3', true),
    ('11111114-1111-1111-1111-111111111111', null, 'a1111111-1111-1111-1111-111111111111', 'Great Are You Lord', 300, 'Worship', 'en', 'songs/sinach/great-are-you-lord.mp3', true),
    
    -- Nathaniel Bassey
    ('22222221-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 'Imela', 420, 'Praise', 'en', 'songs/nathaniel-bassey/imela.mp3', true),
    ('22222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'a2222222-2222-2222-2222-222222222222', 'Olowogbogboro', 390, 'Praise', 'en', 'songs/nathaniel-bassey/olowogbogboro.mp3', true),
    ('22222223-2222-2222-2222-222222222222', null, 'a2222222-2222-2222-2222-222222222222', 'Alagbada Ina', 310, 'Praise', 'yo', 'songs/nathaniel-bassey/alagbada-ina.mp3', true),
    ('22222224-2222-2222-2222-222222222222', null, 'a2222222-2222-2222-2222-222222222222', 'Onise Iyanu', 365, 'Praise', 'yo', 'songs/nathaniel-bassey/onise-iyanu.mp3', true),
    
    -- Tim Godfrey
    ('33333331-3333-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', 'a3333333-3333-3333-3333-333333333333', 'Nara', 380, 'Afro-Gospel', 'en', 'songs/tim-godfrey/nara.mp3', true),
    ('33333332-3333-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', 'a3333333-3333-3333-3333-333333333333', 'Na You Be God', 350, 'Afro-Gospel', 'en', 'songs/tim-godfrey/na-you-be-god.mp3', true),
    ('33333333-3333-3333-3333-333333333333', null, 'a3333333-3333-3333-3333-333333333333', 'Greater', 410, 'Afro-Gospel', 'en', 'songs/tim-godfrey/greater.mp3', true),
    
    -- Mercy Chinwo
    ('44444441-4444-4444-4444-444444444444', 'b4444444-4444-4444-4444-444444444444', 'a4444444-4444-4444-4444-444444444444', 'Excess Love', 325, 'Gospel', 'en', 'songs/mercy-chinwo/excess-love.mp3', true),
    ('44444442-4444-4444-4444-444444444444', 'b4444444-4444-4444-4444-444444444444', 'a4444444-4444-4444-4444-444444444444', 'Obinasom', 290, 'Gospel', 'ig', 'songs/mercy-chinwo/obinasom.mp3', true),
    ('44444443-4444-4444-4444-444444444444', null, 'a4444444-4444-4444-4444-444444444444', 'Chinedum', 340, 'Gospel', 'ig', 'songs/mercy-chinwo/chinedum.mp3', true),
    ('44444444-4444-4444-4444-444444444444', null, 'a4444444-4444-4444-4444-444444444444', 'On a Regular', 315, 'Gospel', 'en', 'songs/mercy-chinwo/on-a-regular.mp3', true),
    
    -- Frank Edwards
    ('55555551-5555-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'a5555555-5555-5555-5555-555555555555', 'Miye Ruwe', 370, 'Contemporary Christian', 'en', 'songs/frank-edwards/miye-ruwe.mp3', true),
    ('55555552-5555-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'a5555555-5555-5555-5555-555555555555', 'Suddenly', 400, 'Contemporary Christian', 'en', 'songs/frank-edwards/suddenly.mp3', true),
    ('55555553-5555-5555-5555-555555555555', null, 'a5555555-5555-5555-5555-555555555555', 'Oghene Doh', 330, 'Contemporary Christian', 'en', 'songs/frank-edwards/oghene-doh.mp3', true),
    
    -- Tope Alabi
    ('66666661-6666-6666-6666-666666666666', null, 'a6666666-6666-6666-6666-666666666666', 'Logan Ti O De', 380, 'Praise', 'yo', 'songs/tope-alabi/logan-ti-o-de.mp3', true),
    ('66666662-6666-6666-6666-666666666666', null, 'a6666666-6666-6666-6666-666666666666', 'Emi Mimo', 345, 'Worship', 'yo', 'songs/tope-alabi/emi-mimo.mp3', true),
    ('66666663-6666-6666-6666-666666666666', null, 'a6666666-6666-6666-6666-666666666666', 'Ore Ti O Common', 360, 'Praise', 'yo', 'songs/tope-alabi/ore-ti-o-common.mp3', true),
    
    -- Judikay
    ('77777771-7777-7777-7777-777777777777', 'b6666666-6666-6666-6666-666666666666', 'a7777777-7777-7777-7777-777777777777', 'Omemma', 405, 'Worship', 'en', 'songs/judikay/omemma.mp3', true),
    ('77777772-7777-7777-7777-777777777777', 'b6666666-6666-6666-6666-666666666666', 'a7777777-7777-7777-7777-777777777777', 'More Than Gold', 355, 'Worship', 'en', 'songs/judikay/more-than-gold.mp3', true),
    ('77777773-7777-7777-7777-777777777777', null, 'a7777777-7777-7777-7777-777777777777', 'Capable God', 320, 'Worship', 'en', 'songs/judikay/capable-god.mp3', true),
    
    -- Eben
    ('88888881-8888-8888-8888-888888888888', null, 'a8888888-8888-8888-8888-888888888888', 'Victory', 410, 'Praise', 'en', 'songs/eben/victory.mp3', true),
    ('88888882-8888-8888-8888-888888888888', null, 'a8888888-8888-8888-8888-888888888888', 'Nothing Is Impossible', 385, 'Worship', 'en', 'songs/eben/nothing-is-impossible.mp3', true),
    ('88888883-8888-8888-8888-888888888888', null, 'a8888888-8888-8888-8888-888888888888', 'God All By Yourself', 370, 'Worship', 'en', 'songs/eben/god-all-by-yourself.mp3', true);

-- =====================================================
-- SEED: PODCASTS (Christian Content)
-- =====================================================

INSERT INTO public.podcasts (id, title, host, description, cover_image, storage_path, category, language, duration, published_at) VALUES
    ('91111111-1111-1111-1111-111111111111', 'Morning Devotional with Pastor Chris', 'Pastor Chris Oyakhilome', 'Daily morning devotional messages to start your day with faith and inspiration.', 'podcasts/rhapsody/cover.jpg', 'podcasts/rhapsody/ep001.mp3', 'Devotional', 'en', 900, '2024-01-01 06:00:00+00'),
    ('92222222-2222-2222-2222-222222222222', 'The Elevation Church Podcast', 'Pastor Godman Akinlabi', 'Weekly sermons and teachings from The Elevation Church, empowering believers to live purposeful lives.', 'podcasts/elevation/cover.jpg', 'podcasts/elevation/ep012.mp3', 'Sermon', 'en', 2700, '2024-01-07 10:00:00+00'),
    ('93333333-3333-3333-3333-333333333333', 'Worship Wednesday', 'Sinach', 'Weekly worship sessions and teachings on the power of worship in the life of a believer.', 'podcasts/worship-wednesday/cover.jpg', 'podcasts/worship-wednesday/ep005.mp3', 'Music', 'en', 1800, '2024-01-10 18:00:00+00'),
    ('94444444-4444-4444-4444-444444444444', 'Faith Foundations', 'Dr. Tony Rapu', 'Biblical teaching series on foundational Christian doctrines and practical living.', 'podcasts/faith-foundations/cover.jpg', 'podcasts/faith-foundations/ep020.mp3', 'Teaching', 'en', 2400, '2024-01-05 14:00:00+00'),
    ('95555555-5555-5555-5555-555555555555', 'Midnight Praise Sessions', 'Nathaniel Bassey', 'Live midnight praise and worship sessions with powerful testimonies and breakthroughs.', 'podcasts/midnight-praise/cover.jpg', 'podcasts/midnight-praise/ep008.mp3', 'Music', 'en', 3600, '2024-01-12 00:00:00+00'),
    ('96666666-6666-6666-6666-666666666666', 'Youth Alive Conversations', 'Pastor Bolaji Idowu', 'Real talk for young believers navigating faith, relationships, career, and purpose.', 'podcasts/youth-alive/cover.jpg', 'podcasts/youth-alive/ep015.mp3', 'Teaching', 'en', 2100, '2024-01-08 19:00:00+00');

-- =====================================================
-- SEED: ADMIN USER (For Testing)
-- =====================================================

-- NOTE: This assumes you have an auth.users record with this ID
-- Replace with your actual Supabase user ID
INSERT INTO public.users (id, display_name, email, country, is_admin, is_premium, preferences) VALUES
    ('3e3748a7-5afd-4e28-85be-2472897993b1', 'Admin User', 'admin@harmonyhub.ng', 'NG', true, true, '{
        "genres": ["Gospel", "Worship", "Praise", "Afro-Gospel"],
        "morning_preference": "06:00",
        "language": "en"
    }')
ON CONFLICT (id) DO UPDATE SET is_admin = true, is_premium = true;

-- =====================================================
-- SEED: SAMPLE PLAYLISTS
-- =====================================================

-- Create test user (replace with actual user ID from Supabase Auth)
INSERT INTO public.users (id, display_name, email, country, preferences) VALUES
    ('3e3748a7-5afd-4e28-85be-2472897993b1', 'Test User', 'bodefavour@gmail.com', 'NG', '{
        "genres": ["Worship", "Praise"],
        "morning_preference": "07:00",
        "language": "en"
    }')
ON CONFLICT (id) DO NOTHING;

-- Sample public playlist
INSERT INTO public.playlists (id, user_id, title, description, is_public) VALUES
    ('c1111111-1111-1111-1111-111111111111', '3e3748a7-5afd-4e28-85be-2472897993b1', 'Nigerian Gospel Favorites', 'Top Nigerian gospel songs for worship and praise', true);

INSERT INTO public.playlist_items (playlist_id, song_id, position) VALUES
    ('c1111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 1), -- Way Maker
    ('c1111111-1111-1111-1111-111111111111', '22222221-2222-2222-2222-222222222222', 2), -- Imela
    ('c1111111-1111-1111-1111-111111111111', '44444441-4444-4444-4444-444444444444', 3), -- Excess Love
    ('c1111111-1111-1111-1111-111111111111', '77777771-7777-7777-7777-777777777777', 4), -- Omemma
    ('c1111111-1111-1111-1111-111111111111', '33333331-3333-3333-3333-333333333333', 5); -- Nara

-- =====================================================
-- SEED: SAMPLE DAILY FEED
-- =====================================================

INSERT INTO public.daily_feeds (id, user_id, title, description, song_ids, generated_at, expires_at) VALUES
    ('d1111111-1111-1111-1111-111111111111', '3e3748a7-5afd-4e28-85be-2472897993b1', 'Your Morning Worship', 'Start your day with these powerful worship songs', 
    ARRAY[
        '11111111-1111-1111-1111-111111111111'::uuid,
        '11111114-1111-1111-1111-111111111111'::uuid,
        '77777771-7777-7777-7777-777777777777'::uuid,
        '77777772-7777-7777-7777-777777777777'::uuid,
        '88888882-8888-8888-8888-888888888888'::uuid,
        '44444441-4444-4444-4444-444444444444'::uuid,
        '22222221-2222-2222-2222-222222222222'::uuid,
        '55555551-5555-5555-5555-555555555555'::uuid
    ],
    NOW(), NOW() + INTERVAL '24 hours');

-- =====================================================
-- SEED: SAMPLE USER LIBRARY (Favorites)
-- =====================================================

INSERT INTO public.user_library (user_id, song_id, is_downloaded) VALUES
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '11111111-1111-1111-1111-111111111111', false), -- Way Maker
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '44444441-4444-4444-4444-444444444444', true),  -- Excess Love (downloaded)
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '77777771-7777-7777-7777-777777777777', false); -- Omemma

-- =====================================================
-- SEED: SAMPLE PLAY HISTORY
-- =====================================================

INSERT INTO public.play_history (user_id, song_id, played_at, completion_percentage) VALUES
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '1 hour', 100),
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '44444441-4444-4444-4444-444444444444', NOW() - INTERVAL '2 hours', 95),
    ('3e3748a7-5afd-4e28-85be-2472897993b1', '22222221-2222-2222-2222-222222222222', NOW() - INTERVAL '3 hours', 80);

-- Update play counts based on history
UPDATE public.songs SET play_count = 150 WHERE id = '11111111-1111-1111-1111-111111111111'; -- Way Maker
UPDATE public.songs SET play_count = 120 WHERE id = '44444441-4444-4444-4444-444444444444'; -- Excess Love
UPDATE public.songs SET play_count = 100 WHERE id = '77777771-7777-7777-7777-777777777777'; -- Omemma
UPDATE public.songs SET play_count = 95 WHERE id = '22222221-2222-2222-2222-222222222222';  -- Imela
UPDATE public.songs SET play_count = 85 WHERE id = '33333331-3333-3333-3333-333333333333';  -- Nara

-- =====================================================
-- SEED COMPLETE!
-- =====================================================

-- Verify seeded data
SELECT 'Artists:' as category, COUNT(*) as count FROM public.artists
UNION ALL
SELECT 'Albums:', COUNT(*) FROM public.albums
UNION ALL
SELECT 'Songs:', COUNT(*) FROM public.songs
UNION ALL
SELECT 'Podcasts:', COUNT(*) FROM public.podcasts
UNION ALL
SELECT 'Playlists:', COUNT(*) FROM public.playlists
UNION ALL
SELECT 'Users:', COUNT(*) FROM public.users;

-- Sample queries to test
/*
-- Get all songs by Sinach
SELECT s.title, a.name as artist, al.title as album, s.duration, s.genre
FROM public.songs s
LEFT JOIN public.artists a ON s.artist_id = a.id
LEFT JOIN public.albums al ON s.album_id = al.id
WHERE a.name = 'Sinach';

-- Get top played songs
SELECT s.title, a.name as artist, s.play_count
FROM public.songs s
LEFT JOIN public.artists a ON s.artist_id = a.id
ORDER BY s.play_count DESC
LIMIT 10;

-- Get all podcasts in Devotional category
SELECT title, host, duration, published_at
FROM public.podcasts
WHERE category = 'Devotional'
ORDER BY published_at DESC;
*/
