import 'package:flutter/material.dart';
import '../../models/podcast.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';

class PodcastDetailController extends ChangeNotifier {
  final SupabaseService _supabaseService;
  final AudioService _audioService;
  final String podcastId;

  bool _isLoading = false;
  String? _error;
  Podcast? _podcast;
  bool _isFavorite = false;

  PodcastDetailController({
    required SupabaseService supabaseService,
    required AudioService audioService,
    required this.podcastId,
  })  : _supabaseService = supabaseService,
        _audioService = audioService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Podcast? get podcast => _podcast;
  bool get isFavorite => _isFavorite;
  bool get isPlaying => _audioService.isPlaying && _audioService.currentTitle == _podcast?.title;

  Future<void> initialize(Podcast? initialPodcast) async {
    if (initialPodcast != null) {
      _podcast = initialPodcast;
      notifyListeners();
      _checkFavoriteStatus();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _podcast = await _supabaseService.getPodcast(podcastId);
      await _checkFavoriteStatus();
      _error = null;
    } catch (e) {
      _error = 'Failed to load podcast: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkFavoriteStatus() async {
    // TODO: Implement favorite checking from user profile
    _isFavorite = false;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_podcast == null) return;

    try {
      _isFavorite = !_isFavorite;
      notifyListeners();
      // TODO: Save favorite status to backend
    } catch (e) {
      _isFavorite = !_isFavorite; // Revert on error
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> playPodcast() async {
    if (_podcast == null) return;

    try {
      final audioUrl = await _supabaseService.getAudioSignedUrl(_podcast!.audioUrl);
      await _audioService.play(
        url: audioUrl,
        title: _podcast!.title,
        artist: _podcast!.artistName ?? 'Unknown Host',
        artworkUrl: _podcast!.imageUrl,
      );
      notifyListeners();
    } catch (e) {
      _error = 'Failed to play podcast: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pausePodcast() async {
    await _audioService.pause();
    notifyListeners();
  }

  Future<void> downloadPodcast() async {
    if (_podcast == null) return;

    try {
      final audioUrl = await _supabaseService.getAudioSignedUrl(_podcast!.audioUrl);
      await _audioService.download(
        url: audioUrl,
        filename: '${_podcast!.title}.mp3',
      );
      // TODO: Show success message
    } catch (e) {
      _error = 'Failed to download podcast: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> sharePodcast() async {
    // TODO: Implement share functionality
    print('Share podcast: ${_podcast?.title}');
  }
}
