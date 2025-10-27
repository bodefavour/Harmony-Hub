import 'package:flutter/material.dart';
import '../../models/podcast.dart';
import '../../services/podcast_service.dart';
import '../../services/audio_service.dart';

class PodcastsController extends ChangeNotifier {
  final PodcastService _podcastService;
  final AudioService _audioService;

  bool _isLoading = false;
  String? _error;

  List<Podcast> _allPodcasts = [];
  List<Podcast> _sermonsPodcasts = [];
  List<Podcast> _teachingsPodcasts = [];
  List<Podcast> _testimoniesPodcasts = [];
  List<Podcast> _interviewsPodcasts = [];
  List<Podcast> _recentlyPlayed = [];

  PodcastsController({
    required PodcastService podcastService,
    required AudioService audioService,
  })  : _podcastService = podcastService,
        _audioService = audioService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Podcast> get allPodcasts => _allPodcasts;
  List<Podcast> get sermonsPodcasts => _sermonsPodcasts;
  List<Podcast> get teachingsPodcasts => _teachingsPodcasts;
  List<Podcast> get testimoniesPodcasts => _testimoniesPodcasts;
  List<Podcast> get interviewsPodcasts => _interviewsPodcasts;
  List<Podcast> get recentlyPlayed => _recentlyPlayed;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadAllPodcasts(),
        _loadPodcastsByCategory('sermons'),
        _loadPodcastsByCategory('teachings'),
        _loadPodcastsByCategory('testimonies'),
        _loadPodcastsByCategory('interviews'),
        _loadRecentlyPlayed(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load podcasts: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllPodcasts() async {
    try {
      _allPodcasts = await _podcastService.fetchPodcasts(limit: 20);
    } catch (e) {
      print('Error loading all podcasts: $e');
    }
  }

  Future<void> _loadPodcastsByCategory(String category) async {
    try {
      final podcasts =
          await _podcastService.getPodcastsByCategory(category, limit: 10);
      switch (category) {
        case 'sermons':
          _sermonsPodcasts = podcasts;
          break;
        case 'teachings':
          _teachingsPodcasts = podcasts;
          break;
        case 'testimonies':
          _testimoniesPodcasts = podcasts;
          break;
        case 'interviews':
          _interviewsPodcasts = podcasts;
          break;
      }
    } catch (e) {
      print('Error loading $category podcasts: $e');
    }
  }

  Future<void> _loadRecentlyPlayed() async {
    // TODO: Implement history tracking
    // For now, just show random podcasts
    try {
      _recentlyPlayed = await _podcastService.fetchPodcasts(limit: 5);
    } catch (e) {
      print('Error loading recently played: $e');
    }
  }

  Future<void> playPodcast(Podcast podcast) async {
    try {
      await _audioService.playPodcast(podcast);
    } catch (e) {
      _error = 'Failed to play podcast: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> searchPodcasts(String query) async {
    if (query.isEmpty) {
      await _loadAllPodcasts();
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Use fetchPodcasts as a basic search - in production would use full-text search
      _allPodcasts = await _podcastService.fetchPodcasts(limit: 50);
      // Filter locally by title or host
      _allPodcasts = _allPodcasts
          .where((p) =>
              p.title.toLowerCase().contains(query.toLowerCase()) ||
              (p.host?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
      _error = null;
    } catch (e) {
      _error = 'Search failed: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await initialize();
  }
}
