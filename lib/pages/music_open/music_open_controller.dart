import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../services/audio_service.dart';
import '../../services/favorites_service.dart';
import '../../services/supabase_service.dart';

class MusicOpenController extends ChangeNotifier {
  final AudioService _audioService;
  final FavoritesService _favoritesService;
  final SupabaseService _supabaseService;

  Song? _currentSong;
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isLoading = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _error;

  MusicOpenController({
    required AudioService audioService,
    required FavoritesService favoritesService,
    required SupabaseService supabaseService,
  })  : _audioService = audioService,
        _favoritesService = favoritesService,
        _supabaseService = supabaseService;

  // Getters
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isFavorite => _isFavorite;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get error => _error;

  String get formattedPosition => _formatDuration(_position);
  String get formattedDuration => _formatDuration(_duration);

  /// Initialize with a song
  Future<void> initialize(Song song, {String? userId}) async {
    _currentSong = song;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Check if song is favorited
      if (userId != null) {
        _isFavorite = await _favoritesService.isFavorite(userId, song.id);
      }

      // Play the song
      await _audioService.playSong(song);
      _isPlaying = true;

      // Listen to player state
      _audioService.player.playerStateStream.listen((state) {
        _isPlaying = state.playing;
        notifyListeners();
      });

      // Listen to position updates
      _audioService.player.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      // Listen to duration updates
      _audioService.player.durationStream.listen((dur) {
        if (dur != null) {
          _duration = dur;
          notifyListeners();
        }
      });

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load song: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioService.pause();
      } else {
        await _audioService.play();
      }
    } catch (e) {
      _error = 'Playback error: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _audioService.seek(position);
    } catch (e) {
      _error = 'Seek error: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Toggle favorite
  Future<void> toggleFavorite(String userId) async {
    if (_currentSong == null) return;

    try {
      if (_isFavorite) {
        await _favoritesService.removeFavorite(userId, _currentSong!.id);
        _isFavorite = false;
      } else {
        await _favoritesService.addFavorite(
          userId,
          _currentSong!.id,
          'song',
        );
        _isFavorite = true;
      }
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update favorite: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Download song
  Future<void> downloadSong() async {
    if (_currentSong == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      // Get download URL from Supabase Storage
      final url = await _supabaseService.getFileUrl(_currentSong!.audioUrl);
      
      // TODO: Implement actual file download
      // For now, just show success message
      print('Download URL: $url');
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Download failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Skip to next (placeholder - needs queue implementation)
  Future<void> skipNext() async {
    // TODO: Implement queue navigation
    print('Skip to next track');
  }

  /// Skip to previous (placeholder - needs queue implementation)
  Future<void> skipPrevious() async {
    // TODO: Implement queue navigation
    print('Skip to previous track');
  }

  /// Toggle shuffle
  void toggleShuffle() {
    // TODO: Implement shuffle
    print('Toggle shuffle');
  }

  /// Toggle repeat
  void toggleRepeat() {
    // TODO: Implement repeat
    print('Toggle repeat');
  }

  /// Share song
  Future<void> shareSong() async {
    if (_currentSong == null) return;

    // TODO: Implement share functionality
    print('Sharing: ${_currentSong!.title} by ${_currentSong!.artistName}');
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    // Don't stop playback when disposing - let it continue in background
    super.dispose();
  }
}
