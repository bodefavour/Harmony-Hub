import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../flutter_flow/flutter_flow_theme.dart';

/// Controller for Home Page to manage data and state
class HomePageController extends ChangeNotifier {
  final RecommendationService _recommendationService = RecommendationService();
  final SupabaseService _supabaseService = SupabaseService();
  final AudioService _audioService = AudioService();

  // State
  bool _isLoading = true;
  DailyFeed? _dailyFeed;
  List<Song> _trendingSongs = [];
  List<Song> _newReleases = [];
  List<Album> _featuredAlbums = [];
  UserProfile? _userProfile;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  DailyFeed? get dailyFeed => _dailyFeed;
  List<Song> get trendingSongs => _trendingSongs;
  List<Song> get newReleases => _newReleases;
  List<Album> get featuredAlbums => _featuredAlbums;
  UserProfile? get userProfile => _userProfile;
  String? get error => _error;

  /// Get time-based greeting
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  /// Get user display name
  String get userName => _userProfile?.displayNameOrEmail ?? 'Friend';

  /// Initialize home page data
  Future<void> initialize(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load data in parallel
      final results = await Future.wait([
        _loadUserProfile(userId),
        _loadDailyFeed(userId),
        _loadTrendingSongs(),
        _loadNewReleases(),
        _loadFeaturedAlbums(),
      ]);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error initializing home page: $e');
      _error = 'Failed to load content. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user profile
  Future<void> _loadUserProfile(String userId) async {
    try {
      _userProfile = await _supabaseService.getUserProfile(userId);
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  /// Load daily worship feed
  Future<void> _loadDailyFeed(String userId) async {
    try {
      _dailyFeed = await _recommendationService.generateDailyFeed(userId);
    } catch (e) {
      print('Error loading daily feed: $e');
    }
  }

  /// Load trending songs
  Future<void> _loadTrendingSongs() async {
    try {
      _trendingSongs = await _recommendationService.getTrendingSongs(limit: 10);
    } catch (e) {
      print('Error loading trending songs: $e');
      _trendingSongs = [];
    }
  }

  /// Load new releases
  Future<void> _loadNewReleases() async {
    try {
      _newReleases = await _recommendationService.getNewReleases(limit: 10);
    } catch (e) {
      print('Error loading new releases: $e');
      _newReleases = [];
    }
  }

  /// Load featured albums
  Future<void> _loadFeaturedAlbums() async {
    try {
      _featuredAlbums = await _supabaseService.fetchAlbums(limit: 10);
    } catch (e) {
      print('Error loading featured albums: $e');
      _featuredAlbums = [];
    }
  }

  /// Play a song
  Future<void> playSong(Song song) async {
    try {
      await _audioService.playSong(song);
    } catch (e) {
      print('Error playing song: $e');
    }
  }

  /// Play daily feed
  Future<void> playDailyFeed() async {
    if (_dailyFeed == null || _dailyFeed!.songs == null || _dailyFeed!.songs!.isEmpty) {
      return;
    }
    
    try {
      // Play first song from daily feed
      await _audioService.playSong(_dailyFeed!.songs!.first);
    } catch (e) {
      print('Error playing daily feed: $e');
    }
  }

  /// Refresh all data
  Future<void> refresh(String userId) async {
    await initialize(userId);
  }

  /// Get songs by mood
  Future<List<Song>> getSongsByMood(String mood) async {
    return await _recommendationService.getSongsByMood(mood);
  }
}
