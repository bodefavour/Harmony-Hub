import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../models/artist.dart';
import '../../models/album.dart';
import '../../models/podcast.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';
import '../../services/recommendation_service.dart';

class SearchController extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final AudioService _audioService;
  final RecommendationService _recommendationService;

  List<Song> _searchResultsSongs = [];
  List<Artist> _searchResultsArtists = [];
  List<Album> _searchResultsAlbums = [];
  List<Podcast> _searchResultsPodcasts = [];

  List<Song> _trendingSongs = [];
  List<String> _recentSearches = [];

  bool _isSearching = false;
  bool _isLoadingTrending = false;
  String _searchQuery = '';
  String? _error;

  SearchController({
    required SupabaseService supabaseService,
    required AudioService audioService,
    required RecommendationService recommendationService,
  })  : _supabaseService = supabaseService,
        _audioService = audioService,
        _recommendationService = recommendationService;

  // Getters
  List<Song> get searchResultsSongs => _searchResultsSongs;
  List<Artist> get searchResultsArtists => _searchResultsArtists;
  List<Album> get searchResultsAlbums => _searchResultsAlbums;
  List<Podcast> get searchResultsPodcasts => _searchResultsPodcasts;
  List<Song> get trendingSongs => _trendingSongs;
  List<String> get recentSearches => _recentSearches;

  bool get isSearching => _isSearching;
  bool get isLoadingTrending => _isLoadingTrending;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  bool get hasSearchResults =>
      _searchResultsSongs.isNotEmpty ||
      _searchResultsArtists.isNotEmpty ||
      _searchResultsAlbums.isNotEmpty ||
      _searchResultsPodcasts.isNotEmpty;

  bool get hasTrendingSongs => _trendingSongs.isNotEmpty;

  /// Initialize and load trending songs
  Future<void> initialize() async {
    _isLoadingTrending = true;
    _error = null;
    notifyListeners();

    try {
      _trendingSongs = await _recommendationService.getTrendingSongs(limit: 20);
      _isLoadingTrending = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load trending songs: ${e.toString()}';
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  /// Search for content
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _clearSearchResults();
      return;
    }

    _searchQuery = query;
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      // Add to recent searches
      if (!_recentSearches.contains(query)) {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 10) {
          _recentSearches.removeLast();
        }
      }

      // Search all content types in parallel
      final results = await Future.wait([
        _supabaseService.searchSongs(query),
        _supabaseService.searchArtists(query),
        _supabaseService.searchAlbums(query),
        _supabaseService.searchPodcasts(query),
      ]);

      _searchResultsSongs = results[0] as List<Song>;
      _searchResultsArtists = results[1] as List<Artist>;
      _searchResultsAlbums = results[2] as List<Album>;
      _searchResultsPodcasts = results[3] as List<Podcast>;

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Clear search results
  void _clearSearchResults() {
    _searchQuery = '';
    _searchResultsSongs = [];
    _searchResultsArtists = [];
    _searchResultsAlbums = [];
    _searchResultsPodcasts = [];
    notifyListeners();
  }

  /// Clear all search data
  void clearSearch() {
    _clearSearchResults();
    _error = null;
  }

  /// Play a song from search results
  Future<void> playSong(Song song) async {
    try {
      await _audioService.playSong(song);
    } catch (e) {
      _error = 'Failed to play song: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Play a podcast from search results
  Future<void> playPodcast(Podcast podcast) async {
    try {
      await _audioService.playPodcast(podcast);
    } catch (e) {
      _error = 'Failed to play podcast: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Search by genre
  Future<void> searchByGenre(String genre) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResultsSongs =
          await _recommendationService.getSongsByGenre(genre, limit: 50);
      _searchResultsArtists = [];
      _searchResultsAlbums = [];
      _searchResultsPodcasts = [];

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Genre search failed: ${e.toString()}';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Get recommendations for user
  Future<void> getRecommendations(String userId) async {
    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResultsSongs =
          await _recommendationService.getRecommendedSongs(userId);
      _searchResultsArtists = [];
      _searchResultsAlbums = [];
      _searchResultsPodcasts = [];

      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load recommendations: ${e.toString()}';
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Remove from recent searches
  void removeRecentSearch(String query) {
    _recentSearches.remove(query);
    notifyListeners();
  }

  /// Clear recent searches
  void clearRecentSearches() {
    _recentSearches.clear();
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
