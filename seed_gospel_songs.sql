-- Gospel Songs Seeder SQL Script
-- Run this in your Supabase SQL Editor AFTER running add_missing_columns.sql
-- This will insert 10 popular gospel songs with direct URLs

-- Step 1: Insert Artists (with cover_image)
INSERT INTO artists (id, name, bio, cover_image, created_at, updated_at)
VALUES 
  ('a1111111-1111-1111-1111-111111111111', 'Sinach', 'Nigerian gospel singer and songwriter', 'https://i.scdn.co/image/ab67616d0000b27365e3d6414dd58e5e6c2e4f3a', NOW(), NOW()),
  ('a2222222-2222-2222-2222-222222222222', 'Bethel Music', 'American worship collective', 'https://i.scdn.co/image/ab67616d0000b273a1a1a1a1a1a1a1a1a1a1a1a1', NOW(), NOW()),
  ('a3333333-3333-3333-3333-333333333333', 'Hillsong United', 'Australian worship band', 'https://i.scdn.co/image/ab67616d0000b273b2b2b2b2b2b2b2b2b2b2b2b2', NOW(), NOW()),
  ('a4444444-4444-4444-4444-444444444444', 'Hillsong Worship', 'Worship ministry from Australia', 'https://i.scdn.co/image/ab67616d0000b273c3c3c3c3c3c3c3c3c3c3c3c3', NOW(), NOW()),
  ('a5555555-5555-5555-5555-555555555555', 'Cory Asbury', 'American Christian musician', 'https://i.scdn.co/image/ab67616d0000b273d4d4d4d4d4d4d4d4d4d4d4d4', NOW(), NOW()),
  ('a6666666-6666-6666-6666-666666666666', 'Michael W. Smith', 'American Christian musician', 'https://i.scdn.co/image/ab67616d0000b273e5e5e5e5e5e5e5e5e5e5e5e5', NOW(), NOW()),
  ('a7777777-7777-7777-7777-777777777777', 'Passion', 'Christian music movement', 'https://i.scdn.co/image/ab67616d0000b273f6f6f6f6f6f6f6f6f6f6f6f6', NOW(), NOW()),
  ('a8888888-8888-8888-8888-888888888888', 'Elevation Worship', 'Contemporary worship music', 'https://i.scdn.co/image/ab67616d0000b273e7e7e7e7e7e7e7e7e7e7e7e7', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Step 2: Insert Albums
INSERT INTO albums (id, artist_id, title, release_date, genre, cover_image, created_at, updated_at)
VALUES 
  ('b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 'Way Maker', '2016-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b27365e3d6414dd58e5e6c2e4f3a', NOW(), NOW()),
  ('b2222222-2222-2222-2222-222222222222', 'a1111111-1111-1111-1111-111111111111', 'I Know Who I Am', '2015-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273d8e8e5e8e8e8e8e8e8e8e8e8', NOW(), NOW()),
  ('b3333333-3333-3333-3333-333333333333', 'a1111111-1111-1111-1111-111111111111', 'There''s an Overflow', '2018-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273f8f8f8f8f8f8f8f8f8f8f8f8', NOW(), NOW()),
  ('b4444444-4444-4444-4444-444444444444', 'a2222222-2222-2222-2222-222222222222', 'Victory', '2019-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273a1a1a1a1a1a1a1a1a1a1a1a1', NOW(), NOW()),
  ('b5555555-5555-5555-5555-555555555555', 'a3333333-3333-3333-3333-333333333333', 'Zion', '2013-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273b2b2b2b2b2b2b2b2b2b2b2b2', NOW(), NOW()),
  ('b6666666-6666-6666-6666-666666666666', 'a4444444-4444-4444-4444-444444444444', 'Let There Be Light', '2016-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273c3c3c3c3c3c3c3c3c3c3c3c3', NOW(), NOW()),
  ('b7777777-7777-7777-7777-777777777777', 'a5555555-5555-5555-5555-555555555555', 'Reckless Love', '2018-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273d4d4d4d4d4d4d4d4d4d4d4d4', NOW(), NOW()),
  ('b8888888-8888-8888-8888-888888888888', 'a6666666-6666-6666-6666-666666666666', 'Surrounded', '2018-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273e5e5e5e5e5e5e5e5e5e5e5e5', NOW(), NOW()),
  ('b9999999-9999-9999-9999-999999999999', 'a7777777-7777-7777-7777-777777777777', 'Whole Heart', '2018-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273f6f6f6f6f6f6f6f6f6f6f6f6', NOW(), NOW()),
  ('b0000000-0000-0000-0000-000000000000', 'a8888888-8888-8888-8888-888888888888', 'Graves Into Gardens', '2020-01-01', 'Gospel', 'https://i.scdn.co/image/ab67616d0000b273e7e7e7e7e7e7e7e7e7e7e7e7', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Step 3: Insert Songs with Direct URLs
INSERT INTO songs (id, album_id, artist_id, title, duration, genre, language, storage_path, is_local, explicit, play_count, created_at, updated_at)
VALUES 
  -- Sinach Songs
  ('c1111111-1111-1111-1111-111111111111', 'b1111111-1111-1111-1111-111111111111', 'a1111111-1111-1111-1111-111111111111', 
   'Way Maker', 331, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 
   false, false, 0, NOW(), NOW()),
  
  ('c2222222-2222-2222-2222-222222222222', 'b2222222-2222-2222-2222-222222222222', 'a1111111-1111-1111-1111-111111111111', 
   'Awesome God', 298, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 
   false, false, 0, NOW(), NOW()),
  
  ('c3333333-3333-3333-3333-333333333333', 'b3333333-3333-3333-3333-333333333333', 'a1111111-1111-1111-1111-111111111111', 
   'There Is Power', 312, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Bethel Music
  ('c4444444-4444-4444-4444-444444444444', 'b4444444-4444-4444-4444-444444444444', 'a2222222-2222-2222-2222-222222222222', 
   'Goodness of God', 365, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Hillsong United
  ('c5555555-5555-5555-5555-555555555555', 'b5555555-5555-5555-5555-555555555555', 'a3333333-3333-3333-3333-333333333333', 
   'Oceans (Where Feet May Fail)', 528, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Hillsong Worship
  ('c6666666-6666-6666-6666-666666666666', 'b6666666-6666-6666-6666-666666666666', 'a4444444-4444-4444-4444-444444444444', 
   'What a Beautiful Name', 244, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Cory Asbury
  ('c7777777-7777-7777-7777-777777777777', 'b7777777-7777-7777-7777-777777777777', 'a5555555-5555-5555-5555-555555555555', 
   'Reckless Love', 312, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Michael W. Smith
  ('c8888888-8888-8888-8888-888888888888', 'b8888888-8888-8888-8888-888888888888', 'a6666666-6666-6666-6666-666666666666', 
   'Surrounded (Fight My Battles)', 355, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Passion
  ('c9999999-9999-9999-9999-999999999999', 'b9999999-9999-9999-9999-999999999999', 'a7777777-7777-7777-7777-777777777777', 
   'Build My Life', 279, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-9.mp3', 
   false, false, 0, NOW(), NOW()),
  
  -- Elevation Worship
  ('c0a0a0a0-0a0a-0a0a-0a0a-0a0a0a0a0a0a', 'b0000000-0000-0000-0000-000000000000', 'a8888888-8888-8888-8888-888888888888', 
   'The Blessing', 775, 'Gospel', 'en', 
   'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3', 
   false, false, 0, NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Verification Query
SELECT 
  s.title as song_title,
  ar.name as artist_name,
  al.title as album_title,
  s.duration,
  s.storage_path,
  s.is_local
FROM songs s
JOIN artists ar ON s.artist_id = ar.id
JOIN albums al ON s.album_id = al.id
WHERE s.genre = 'Gospel'
ORDER BY ar.name, s.title;

-- Summary
SELECT 
  'Artists' as table_name, 
  COUNT(*) as count 
FROM artists 
WHERE id IN (
  SELECT DISTINCT artist_id FROM songs WHERE genre = 'Gospel'
)
UNION ALL
SELECT 
  'Albums', 
  COUNT(*) 
FROM albums 
WHERE genre = 'Gospel'
UNION ALL
SELECT 
  'Songs', 
  COUNT(*) 
FROM songs 
WHERE genre = 'Gospel';
