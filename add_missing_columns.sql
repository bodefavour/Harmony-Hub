-- Add missing columns to improve the database schema
-- Run this FIRST before running the gospel songs seeder

-- Add genre column to albums table
ALTER TABLE albums 
ADD COLUMN IF NOT EXISTS genre TEXT;

-- Add cover_image column to artists table (in addition to profile_image)
-- This allows artists to have both a profile image and a cover image
ALTER TABLE artists 
ADD COLUMN IF NOT EXISTS cover_image TEXT;

-- Verify the changes
SELECT 
  column_name, 
  data_type 
FROM information_schema.columns 
WHERE table_name = 'albums' AND column_name = 'genre';

SELECT 
  column_name, 
  data_type 
FROM information_schema.columns 
WHERE table_name = 'artists' AND column_name IN ('profile_image', 'cover_image');
