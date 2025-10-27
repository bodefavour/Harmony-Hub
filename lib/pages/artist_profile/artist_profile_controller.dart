import 'package:flutter/material.dart';
import '../../models/artist.dart';
import '../../models/song.dart';
import '../../models/album.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';

class ArtistProfileController extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final AudioService _audioService;

  Artist? _artist;
  List<Song> _topSongs = [];
  List<Album> _albums = [];
  List<Song> _allSongs = [];
  
  bool _isLoading = false;
  bool _isFollowing = false;
  String? _error;

  ArtistProfileController({
    required SupabaseService supabaseService,
    required AudioService audioService,
  })  : _supabaseService = supabaseService,
        _audioService = audioService;

  // Getters
  Artist? get artist => _artist;
  List<Song> get topSongs => _topSongs;
  List<Album> get albums => _albums;
  List<Song> get allSongs => _allSongs;
  bool get isLoading => _isLoading;
  bool get isFollowing => _isFollowing;
  String? get error => _error;

  bool get hasTopSongs => _topSongs.isNotEmpty;
  bool get hasAlbums => _albums.isNotEmpty;
  bool get hasAllSongs => _allSongs.isNotEmpty;

  String get artistName => _artist?.name ?? 'Unknown Artist';
  String get artistBio => _artist?.bio ?? '';
  String get artistImage => _artist?.profileImage ?? '';
  int get monthlyListeners => 0; // TODO: Add to Artist model

  /// Initialize with artist ID
  Future<void> initialize(String artistId, {String? userId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load artist data in parallel
      final results = await Future.wait([
        _supabaseService.getArtistById(artistId),
        _supabaseService.getArtistTopSongs(artistId, limit: 5),
        _supabaseService.getArtistAlbums(artistId),
        _supabaseService.getArtistSongs(artistId),
      ]);

      _artist = results[0] as Artist?;
      _topSongs = results[1] as List<Song>;
      _albums = results[2] as List<Album>;
      _allSongs = results[3] as List<Song>;

      // Check if user is following (if userId provided)
      if (userId != null && _artist != null) {
        _isFollowing = await _supabaseService.isFollowingArtist(userId, artistId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load artist profile: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Play a song
  Future<void> playSong(Song song) async {
    try {
      await _audioService.playSong(song);
    } catch (e) {
      _error = 'Failed to play song: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Play all top songs as a queue
  Future<void> playAllTopSongs() async {
    if (_topSongs.isEmpty) return;

    try {
      // Play first song
      await _audioService.playSong(_topSongs.first);
      
      // TODO: Add remaining songs to queue
      // This requires queue implementation in AudioService
    } catch (e) {
      _error = 'Failed to play songs: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Toggle follow/unfollow artist
  Future<void> toggleFollow(String userId) async {
    if (_artist == null) return;

    try {
      if (_isFollowing) {
        await _supabaseService.unfollowArtist(userId, _artist!.id);
        _isFollowing = false;
      } else {
        await _supabaseService.followArtist(userId, _artist!.id);
        _isFollowing = true;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update follow status: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Share artist profile
  Future<void> shareArtist() async {
    if (_artist == null) return;

    // TODO: Implement share functionality
    print('Sharing artist: ${_artist!.name}');
  }

  /// Refresh artist data
  Future<void> refresh(String artistId, {String? userId}) async {
    await initialize(artistId, userId: userId);
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
