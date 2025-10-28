import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Script to seed gospel songs into the database
/// Run this with: dart run lib/scripts/seed_gospel_songs.dart
void main() async {
  print('🎵 Gospel Songs Seeder');
  print('======================\n');

  // Initialize Supabase
  print('Initializing Supabase...');
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final supabase = Supabase.instance.client;
  final uuid = const Uuid();

  // Read the JSON file
  print('Reading gospel_songs_seed.json...');
  final file = File('gospel_songs_seed.json');
  final jsonString = await file.readAsString();
  final List<dynamic> songsData = jsonDecode(jsonString);

  print('Found ${songsData.length} songs to seed\n');

  int successCount = 0;
  int errorCount = 0;

  for (var i = 0; i < songsData.length; i++) {
    final songData = songsData[i] as Map<String, dynamic>;
    final artistName = songData['artist'] as String;
    final albumName = songData['album'] as String;

    print('${i + 1}. Processing: ${songData['title']} by $artistName');

    try {
      // 1. Check if artist exists, if not create
      var artistResponse = await supabase
          .from('artists')
          .select()
          .eq('name', artistName)
          .maybeSingle();

      String artistId;
      if (artistResponse == null) {
        print('   Creating artist: $artistName');
        final newArtist = await supabase.from('artists').insert({
          'id': uuid.v4(),
          'name': artistName,
          'bio': 'Gospel artist',
          'genre': 'Gospel',
          'cover_image': songData['coverUrl'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select().single();
        artistId = newArtist['id'] as String;
      } else {
        artistId = artistResponse['id'] as String;
        print('   Artist exists: $artistName');
      }

      // 2. Check if album exists, if not create
      var albumResponse = await supabase
          .from('albums')
          .select()
          .eq('title', albumName)
          .eq('artist_id', artistId)
          .maybeSingle();

      String albumId;
      if (albumResponse == null) {
        print('   Creating album: $albumName');
        final newAlbum = await supabase.from('albums').insert({
          'id': uuid.v4(),
          'artist_id': artistId,
          'title': albumName,
          'release_date': DateTime.now().toIso8601String(),
          'genre': 'Gospel',
          'cover_image': songData['coverUrl'],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }).select().single();
        albumId = newAlbum['id'] as String;
      } else {
        albumId = albumResponse['id'] as String;
        print('   Album exists: $albumName');
      }

      // 3. Check if song exists
      var songResponse = await supabase
          .from('songs')
          .select()
          .eq('title', songData['title'])
          .eq('artist_id', artistId)
          .maybeSingle();

      if (songResponse == null) {
        print('   Creating song: ${songData['title']}');
        await supabase.from('songs').insert({
          'id': uuid.v4(),
          'album_id': albumId,
          'artist_id': artistId,
          'title': songData['title'],
          'duration': songData['duration'],
          'genre': songData['genre'],
          'language': 'en',
          'storage_path': songData['audioUrl'], // URL instead of file path!
          'is_local': false, // Mark as external URL
          'explicit': false,
          'play_count': 0,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
        successCount++;
        print('   ✅ Song created successfully!\n');
      } else {
        print('   ⚠️  Song already exists, skipping\n');
      }
    } catch (e) {
      errorCount++;
      print('   ❌ Error: $e\n');
    }
  }

  print('\n======================');
  print('Seeding complete!');
  print('✅ Success: $successCount');
  print('❌ Errors: $errorCount');
  print('⏭️  Skipped: ${songsData.length - successCount - errorCount}');
  print('======================\n');

  exit(0);
}
