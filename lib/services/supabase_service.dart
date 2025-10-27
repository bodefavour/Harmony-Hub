import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../backend/supabase/supabase_config.dart';
import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';
import '../models/podcast.dart';
import '../models/playlist.dart';
import '../models/user_profile.dart';
import '../models/admin_upload.dart';
import '../models/daily_feed.dart';

/// Centralized service for all Supabase database and storage operations
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get _client => supabase;

  // ============================================
  // USER PROFILE OPERATIONS
  // ============================================

  /// Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response =
          await _client.from('users').select().eq('id', userId).single();

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Create or update user profile
  Future<void> upsertUserProfile(UserProfile profile) async {
    try {
      await _client.from('users').upsert(profile.toJson());
    } catch (e) {
      print('Error upserting user profile: $e');
      rethrow;
    }
  }

  // ============================================
  // SONG OPERATIONS
  // ============================================

  /// Fetch songs with optional filters
  Future<List<Song>> fetchSongs({
    String? genre,
    String? artistId,
    String? albumId,
    String? searchQuery,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      var queryBuilder =
          _client.from('songs').select('*, artist:artists(*), album:albums(*)');

      if (genre != null) {
        queryBuilder = queryBuilder.eq('genre', genre);
      }
      if (artistId != null) {
        queryBuilder = queryBuilder.eq('artist_id', artistId);
      }
      if (albumId != null) {
        queryBuilder = queryBuilder.eq('album_id', albumId);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryBuilder = queryBuilder.ilike('title', '%$searchQuery%');
      }

      final response = await queryBuilder
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching songs: $e');
      return [];
    }
  }

  /// Get a single song by ID
  Future<Song?> getSongById(String songId) async {
    try {
      final response = await _client
          .from('songs')
          .select('*, artist:artists(*), album:albums(*)')
          .eq('id', songId)
          .single();

      return Song.fromJson(response);
    } catch (e) {
      print('Error fetching song: $e');
      return null;
    }
  }

  /// Get trending songs (by play count)
  Future<List<Song>> getTrendingSongs({String? genre, int limit = 20}) async {
    try {
      var queryBuilder =
          _client.from('songs').select('*, artist:artists(*), album:albums(*)');

      if (genre != null) {
        queryBuilder = queryBuilder.eq('genre', genre);
      }

      final response =
          await queryBuilder.order('play_count', ascending: false).limit(limit);

      return (response as List).map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching trending songs: $e');
      return [];
    }
  }

  /// Get new releases
  Future<List<Song>> getNewReleases({String? genre, int limit = 20}) async {
    try {
      var queryBuilder =
          _client.from('songs').select('*, artist:artists(*), album:albums(*)');

      if (genre != null) {
        queryBuilder = queryBuilder.eq('genre', genre);
      }

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(limit);

      return (response as List).map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching new releases: $e');
      return [];
    }
  }

  /// Increment play count for a song
  Future<void> incrementPlayCount(String songId) async {
    try {
      await _client.rpc('increment_play_count', params: {'song_uuid': songId});
    } catch (e) {
      print('Error incrementing play count: $e');
    }
  }

  // ============================================
  // ARTIST OPERATIONS
  // ============================================

  /// Fetch all artists
  Future<List<Artist>> fetchArtists({int limit = 50, int offset = 0}) async {
    try {
      final response = await _client
          .from('artists')
          .select()
          .order('name')
          .range(offset, offset + limit - 1);

      return (response as List).map((json) => Artist.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching artists: $e');
      return [];
    }
  }

  /// Get artist by ID
  Future<Artist?> getArtistById(String artistId) async {
    try {
      final response =
          await _client.from('artists').select().eq('id', artistId).single();

      return Artist.fromJson(response);
    } catch (e) {
      print('Error fetching artist: $e');
      return null;
    }
  }

  // ============================================
  // ALBUM OPERATIONS
  // ============================================

  /// Fetch albums with optional artist filter
  Future<List<Album>> fetchAlbums({String? artistId, int limit = 50}) async {
    try {
      var queryBuilder = _client.from('albums').select();

      if (artistId != null) {
        queryBuilder = queryBuilder.eq('artist_id', artistId);
      }

      final response = await queryBuilder
          .order('release_date', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Album.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching albums: $e');
      return [];
    }
  }

  // ============================================
  // PODCAST OPERATIONS
  // ============================================

  /// Fetch podcasts with optional category filter
  Future<List<Podcast>> fetchPodcasts(
      {String? category, int limit = 50}) async {
    try {
      var queryBuilder = _client.from('podcasts').select();

      if (category != null) {
        queryBuilder = queryBuilder.eq('category', category);
      }

      final response = await queryBuilder
          .order('published_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Podcast.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  /// Get podcast by ID
  Future<Podcast?> getPodcastById(String podcastId) async {
    try {
      final response =
          await _client.from('podcasts').select().eq('id', podcastId).single();

      return Podcast.fromJson(response);
    } catch (e) {
      print('Error fetching podcast: $e');
      return null;
    }
  }

  /// Get all podcast categories
  Future<List<String>> getPodcastCategories() async {
    try {
      final response = await _client
          .from('podcasts')
          .select('category')
          .not('category', 'is', null);

      final categories = (response as List)
          .map((json) => json['category'] as String)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      print('Error fetching podcast categories: $e');
      return [];
    }
  }

  // ============================================
  // PLAYLIST OPERATIONS
  // ============================================

  /// Get user's playlists
  Future<List<Playlist>> getUserPlaylists(String userId) async {
    try {
      final response = await _client
          .from('playlists')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      return (response as List).map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching playlists: $e');
      return [];
    }
  }

  /// Get public playlists
  Future<List<Playlist>> getPublicPlaylists({int limit = 20}) async {
    try {
      final response = await _client
          .from('playlists')
          .select()
          .eq('is_public', true)
          .order('updated_at', ascending: false)
          .limit(limit);

      return (response as List).map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching public playlists: $e');
      return [];
    }
  }

  /// Get playlist with songs
  Future<Playlist?> getPlaylistWithSongs(String playlistId) async {
    try {
      final playlistResponse = await _client
          .from('playlists')
          .select()
          .eq('id', playlistId)
          .single();

      final songsResponse = await _client
          .from('playlist_items')
          .select('song_id, songs(*, artist:artists(*), album:albums(*))')
          .eq('playlist_id', playlistId)
          .order('position');

      final songs = (songsResponse as List)
          .map((item) => Song.fromJson(item['songs']))
          .toList();

      final playlist = Playlist.fromJson(playlistResponse);
      return playlist.copyWith(songs: songs);
    } catch (e) {
      print('Error fetching playlist with songs: $e');
      return null;
    }
  }

  /// Create a new playlist
  Future<Playlist?> createPlaylist(Playlist playlist) async {
    try {
      final response = await _client
          .from('playlists')
          .insert(playlist.toJson())
          .select()
          .single();

      return Playlist.fromJson(response);
    } catch (e) {
      print('Error creating playlist: $e');
      return null;
    }
  }

  /// Add song to playlist
  Future<void> addSongToPlaylist(
      String playlistId, String songId, int position) async {
    try {
      await _client.from('playlist_items').insert({
        'playlist_id': playlistId,
        'song_id': songId,
        'position': position,
      });
    } catch (e) {
      print('Error adding song to playlist: $e');
      rethrow;
    }
  }

  /// Remove song from playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _client
          .from('playlist_items')
          .delete()
          .eq('playlist_id', playlistId)
          .eq('song_id', songId);
    } catch (e) {
      print('Error removing song from playlist: $e');
      rethrow;
    }
  }

  // ============================================
  // USER LIBRARY (FAVORITES & DOWNLOADS)
  // ============================================

  /// Get user's favorite songs
  Future<List<Song>> getUserFavorites(String userId) async {
    try {
      final response = await _client
          .from('user_library')
          .select('song_id, songs(*, artist:artists(*), album:albums(*))')
          .eq('user_id', userId)
          .order('added_at', ascending: false);

      return (response as List)
          .map((item) => Song.fromJson(item['songs']))
          .toList();
    } catch (e) {
      print('Error fetching favorites: $e');
      return [];
    }
  }

  /// Add song to favorites
  Future<void> addToFavorites(String userId, String songId) async {
    try {
      await _client.from('user_library').upsert({
        'user_id': userId,
        'song_id': songId,
        'is_downloaded': false,
      });
    } catch (e) {
      print('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove song from favorites
  Future<void> removeFromFavorites(String userId, String songId) async {
    try {
      await _client
          .from('user_library')
          .delete()
          .eq('user_id', userId)
          .eq('song_id', songId);
    } catch (e) {
      print('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Check if song is in favorites
  Future<bool> isSongFavorited(String userId, String songId) async {
    try {
      final response = await _client
          .from('user_library')
          .select('song_id')
          .eq('user_id', userId)
          .eq('song_id', songId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking favorite status: $e');
      return false;
    }
  }

  /// Mark song as downloaded
  Future<void> markAsDownloaded(String userId, String songId) async {
    try {
      await _client.from('user_library').upsert({
        'user_id': userId,
        'song_id': songId,
        'is_downloaded': true,
        'downloaded_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error marking as downloaded: $e');
      rethrow;
    }
  }

  /// Get downloaded songs
  Future<List<Song>> getDownloadedSongs(String userId) async {
    try {
      final response = await _client
          .from('user_library')
          .select('song_id, songs(*, artist:artists(*), album:albums(*))')
          .eq('user_id', userId)
          .eq('is_downloaded', true)
          .order('downloaded_at', ascending: false);

      return (response as List)
          .map((item) => Song.fromJson(item['songs']))
          .toList();
    } catch (e) {
      print('Error fetching downloaded songs: $e');
      return [];
    }
  }

  // ============================================
  // SEARCH OPERATIONS
  // ============================================

  /// Search for songs
  Future<List<Song>> searchSongs(String query) async {
    try {
      final response = await _client
          .from('songs')
          .select('*, artist:artists(*), album:albums(*)')
          .or('title.ilike.%$query%,artist_name.ilike.%$query%')
          .limit(50);

      return (response as List).map((item) => Song.fromJson(item)).toList();
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  /// Search for artists
  Future<List<Artist>> searchArtists(String query) async {
    try {
      final response = await _client
          .from('artists')
          .select()
          .ilike('name', '%$query%')
          .limit(50);

      return (response as List).map((item) => Artist.fromJson(item)).toList();
    } catch (e) {
      print('Error searching artists: $e');
      return [];
    }
  }

  /// Search for albums
  Future<List<Album>> searchAlbums(String query) async {
    try {
      final response = await _client
          .from('albums')
          .select('*, artist:artists(*)')
          .or('title.ilike.%$query%,artist_name.ilike.%$query%')
          .limit(50);

      return (response as List).map((item) => Album.fromJson(item)).toList();
    } catch (e) {
      print('Error searching albums: $e');
      return [];
    }
  }

  /// Search for podcasts
  Future<List<Podcast>> searchPodcasts(String query) async {
    try {
      final response = await _client
          .from('podcasts')
          .select()
          .or('title.ilike.%$query%,host.ilike.%$query%,description.ilike.%$query%')
          .limit(50);

      return (response as List).map((item) => Podcast.fromJson(item)).toList();
    } catch (e) {
      print('Error searching podcasts: $e');
      return [];
    }
  }

  // ============================================
  // ARTIST OPERATIONS (EXTENDED)
  // ============================================

  /// Get artist's top songs
  Future<List<Song>> getArtistTopSongs(String artistId,
      {int limit = 10}) async {
    try {
      final response = await _client
          .from('songs')
          .select('*, artist:artists(*), album:albums(*)')
          .eq('artist_id', artistId)
          .order('play_count', ascending: false)
          .limit(limit);

      return (response as List).map((item) => Song.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching artist top songs: $e');
      return [];
    }
  }

  /// Get artist's albums
  Future<List<Album>> getArtistAlbums(String artistId) async {
    try {
      final response = await _client
          .from('albums')
          .select('*, artist:artists(*)')
          .eq('artist_id', artistId)
          .order('release_date', ascending: false);

      return (response as List).map((item) => Album.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching artist albums: $e');
      return [];
    }
  }

  /// Get all artist's songs
  Future<List<Song>> getArtistSongs(String artistId) async {
    try {
      final response = await _client
          .from('songs')
          .select('*, artist:artists(*), album:albums(*)')
          .eq('artist_id', artistId)
          .order('created_at', ascending: false);

      return (response as List).map((item) => Song.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching artist songs: $e');
      return [];
    }
  }

  /// Check if user is following an artist
  Future<bool> isFollowingArtist(String userId, String artistId) async {
    try {
      final response = await _client
          .from('user_follows')
          .select('artist_id')
          .eq('user_id', userId)
          .eq('artist_id', artistId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Follow an artist
  Future<void> followArtist(String userId, String artistId) async {
    try {
      await _client.from('user_follows').insert({
        'user_id': userId,
        'artist_id': artistId,
        'followed_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error following artist: $e');
      rethrow;
    }
  }

  /// Unfollow an artist
  Future<void> unfollowArtist(String userId, String artistId) async {
    try {
      await _client
          .from('user_follows')
          .delete()
          .eq('user_id', userId)
          .eq('artist_id', artistId);
    } catch (e) {
      print('Error unfollowing artist: $e');
      rethrow;
    }
  }

  // ============================================
  // USER LIBRARY OPERATIONS (EXTENDED)
  // ============================================

  /// Get user's recent songs
  Future<List<Song>> getRecentSongs(String userId, {int limit = 20}) async {
    try {
      final response = await _client
          .from('listening_history')
          .select('song_id, songs(*, artist:artists(*), album:albums(*))')
          .eq('user_id', userId)
          .order('played_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((item) => Song.fromJson(item['songs']))
          .toList();
    } catch (e) {
      print('Error fetching recent songs: $e');
      return [];
    }
  }

  /// Get user's favorite albums
  Future<List<Album>> getFavoriteAlbums(String userId) async {
    try {
      final response = await _client
          .from('user_favorites')
          .select('album_id, albums(*, artist:artists(*))')
          .eq('user_id', userId)
          .eq('item_type', 'album')
          .order('created_at', ascending: false);

      return (response as List)
          .where((item) => item['albums'] != null)
          .map((item) => Album.fromJson(item['albums']))
          .toList();
    } catch (e) {
      print('Error fetching favorite albums: $e');
      return [];
    }
  }

  // ============================================
  // DAILY FEED OPERATIONS
  // ============================================

  /// Get user's daily feed
  Future<DailyFeed?> getUserDailyFeed(String userId) async {
    try {
      final response = await _client
          .from('daily_feeds')
          .select()
          .eq('user_id', userId)
          .order('generated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;

      final feed = DailyFeed.fromJson(response);

      // Check if expired
      if (feed.isExpired) return null;

      return feed;
    } catch (e) {
      print('Error fetching daily feed: $e');
      return null;
    }
  }

  /// Create a new daily feed
  Future<DailyFeed?> createDailyFeed(DailyFeed feed) async {
    try {
      final response = await _client
          .from('daily_feeds')
          .insert(feed.toJson())
          .select()
          .single();

      return DailyFeed.fromJson(response);
    } catch (e) {
      print('Error creating daily feed: $e');
      return null;
    }
  }

  // ============================================
  // ADMIN UPLOAD OPERATIONS
  // ============================================

  /// Get pending uploads (admin only)
  Future<List<AdminUpload>> getPendingUploads() async {
    try {
      final response = await _client
          .from('admin_uploads')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdminUpload.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching pending uploads: $e');
      return [];
    }
  }

  /// Get user's uploads
  Future<List<AdminUpload>> getUserUploads(String userId) async {
    try {
      final response = await _client
          .from('admin_uploads')
          .select()
          .eq('uploader_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AdminUpload.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching user uploads: $e');
      return [];
    }
  }

  /// Create a new upload submission
  Future<AdminUpload?> createUpload(AdminUpload upload) async {
    try {
      final response = await _client
          .from('admin_uploads')
          .insert(upload.toJson())
          .select()
          .single();

      return AdminUpload.fromJson(response);
    } catch (e) {
      print('Error creating upload: $e');
      return null;
    }
  }

  /// Update upload status
  Future<void> updateUploadStatus(
    String uploadId,
    UploadStatus status, {
    String? reviewerId,
    String? rejectionReason,
  }) async {
    try {
      await _client.from('admin_uploads').update({
        'status': status.name,
        'reviewed_by': reviewerId,
        'reviewed_at': DateTime.now().toIso8601String(),
        'rejection_reason': rejectionReason,
      }).eq('id', uploadId);
    } catch (e) {
      print('Error updating upload status: $e');
      rethrow;
    }
  }

  // ============================================
  // STORAGE OPERATIONS
  // ============================================

  /// Upload file to Supabase Storage
  Future<String> uploadFile(File file, String path) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = path.split('/').last;

      await _client.storage.from('songs').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: _getContentType(fileName),
            ),
          );

      return path;
    } catch (e) {
      print('Error uploading file: $e');
      rethrow;
    }
  }

  /// Get signed URL for private storage file
  Future<String> createSignedUrl(String path, Duration expiry) async {
    try {
      final bucket = path.split('/').first;
      final filePath = path.substring(bucket.length + 1);

      final url = await _client.storage
          .from(bucket)
          .createSignedUrl(filePath, expiry.inSeconds);

      return url;
    } catch (e) {
      print('Error creating signed URL: $e');
      rethrow;
    }
  }

  /// Get public URL for public storage file
  String getPublicUrl(String path) {
    final bucket = path.split('/').first;
    final filePath = path.substring(bucket.length + 1);
    return _client.storage.from(bucket).getPublicUrl(filePath);
  }

  /// Delete file from storage
  Future<void> deleteFile(String path) async {
    try {
      final bucket = path.split('/').first;
      final filePath = path.substring(bucket.length + 1);

      await _client.storage.from(bucket).remove([filePath]);
    } catch (e) {
      print('Error deleting file: $e');
      rethrow;
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  String _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'mp3':
        return 'audio/mpeg';
      case 'wav':
        return 'audio/wav';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
