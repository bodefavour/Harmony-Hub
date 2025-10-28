import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/podcast.dart';
import 'supabase_service.dart';

/// Enum for player state
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Service to manage audio playback using just_audio
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SupabaseService _supabaseService = SupabaseService();

  Song? _currentSong;
  Podcast? _currentPodcast;
  List<Song> _playlist = [];
  int _currentIndex = 0;
  bool _isShuffleEnabled = false;
  bool _isRepeatEnabled = false;

  final StreamController<PlayerState> _stateController =
      StreamController<PlayerState>.broadcast();

  bool _initialized = false;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize audio session for background playback
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Listen to audio session interruptions
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          _player.pause();
        } else {
          if (event.type == AudioInterruptionType.duck) {
            _player.setVolume(0.5);
          }
        }
      });

      // Listen to becoming noisy (headphones unplugged)
      session.becomingNoisyEventStream.listen((_) {
        _player.pause();
      });

      _initialized = true;
      print('AudioService initialized');
    } catch (e) {
      print('Error initializing AudioService: $e');
    }
  }

  // ============================================
  // PLAYBACK CONTROLS
  // ============================================

  /// Play a song
  Future<void> playSong(Song song) async {
    try {
      await initialize();
      _stateController.add(PlayerState.loading);
      _currentSong = song;
      _currentPodcast = null;

      // Get signed URL for the audio file
      final url = await _supabaseService.createSignedUrl(
        song.storagePath,
        const Duration(hours: 1),
      );

      await _player.setUrl(url);
      await _player.play();

      // Increment play count
      _supabaseService.incrementPlayCount(song.id);

      _stateController.add(PlayerState.playing);
    } catch (e) {
      print('Error playing song: $e');
      _stateController.add(PlayerState.error);
    }
  }

  /// Play a podcast
  Future<void> playPodcast(Podcast podcast) async {
    try {
      await initialize();
      _stateController.add(PlayerState.loading);
      _currentPodcast = podcast;
      _currentSong = null;

      if (podcast.storagePath == null) {
        throw Exception('Podcast has no storage path');
      }

      // Get signed URL for the audio file
      final url = await _supabaseService.createSignedUrl(
        podcast.storagePath!,
        const Duration(hours: 2),
      );

      await _player.setUrl(url);
      await _player.play();

      _stateController.add(PlayerState.playing);
    } catch (e) {
      print('Error playing podcast: $e');
      _stateController.add(PlayerState.error);
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      _stateController.add(PlayerState.paused);
    } catch (e) {
      print('Error pausing: $e');
    }
  }

  /// Resume playback
  Future<void> resume() async {
    try {
      await _player.play();
      _stateController.add(PlayerState.playing);
    } catch (e) {
      print('Error resuming: $e');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _player.stop();
      _stateController.add(PlayerState.idle);
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  /// Set playback speed
  Future<void> setSpeed(double speed) async {
    try {
      await _player.setSpeed(speed.clamp(0.5, 2.0));
    } catch (e) {
      print('Error setting speed: $e');
    }
  }

  /// Skip forward by duration
  Future<void> skipForward(Duration duration) async {
    try {
      final currentPosition = _player.position;
      final newPosition = currentPosition + duration;
      await seek(newPosition);
    } catch (e) {
      print('Error skipping forward: $e');
    }
  }

  /// Skip backward by duration
  Future<void> skipBackward(Duration duration) async {
    try {
      final currentPosition = _player.position;
      final newPosition = currentPosition - duration;
      await seek(newPosition > Duration.zero ? newPosition : Duration.zero);
    } catch (e) {
      print('Error skipping backward: $e');
    }
  }

  // ============================================
  // DOWNLOAD FUNCTIONALITY
  // ============================================

  /// Download a song for offline playback
  Future<bool> downloadSong(Song song, String userId) async {
    try {
      // Get signed URL
      final signedUrl = await _supabaseService.createSignedUrl(
        song.storagePath,
        const Duration(hours: 1),
      );

      // Download file
      final response = await http.get(Uri.parse(signedUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download: ${response.statusCode}');
      }

      // Save to app's document directory
      final appDir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${appDir.path}/downloads');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final file = File('${downloadsDir.path}/${song.id}.mp3');
      await file.writeAsBytes(response.bodyBytes);

      // Mark as downloaded in database
      await _supabaseService.markAsDownloaded(userId, song.id);

      print('Song downloaded: ${song.title}');
      return true;
    } catch (e) {
      print('Error downloading song: $e');
      return false;
    }
  }

  /// Check if a song is downloaded
  Future<bool> isSongDownloaded(String songId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/downloads/$songId.mp3');
      return await file.exists();
    } catch (e) {
      print('Error checking download status: $e');
      return false;
    }
  }

  /// Get local file path for downloaded song
  Future<String?> getLocalPath(String songId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/downloads/$songId.mp3');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      print('Error getting local path: $e');
      return null;
    }
  }

  /// Play downloaded song from local storage
  Future<void> playDownloadedSong(Song song) async {
    try {
      await initialize();
      _stateController.add(PlayerState.loading);
      _currentSong = song;
      _currentPodcast = null;

      final localPath = await getLocalPath(song.id);
      if (localPath == null) {
        throw Exception('Song not downloaded');
      }

      await _player.setFilePath(localPath);
      await _player.play();

      _stateController.add(PlayerState.playing);
    } catch (e) {
      print('Error playing downloaded song: $e');
      _stateController.add(PlayerState.error);
    }
  }

  /// Delete downloaded song
  Future<bool> deleteDownload(String songId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/downloads/$songId.mp3');
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting download: $e');
      return false;
    }
  }

  // ============================================
  // GETTERS & STREAMS
  // ============================================

  /// Get current player state
  Stream<PlayerState> get playerStateStream => _stateController.stream;

  /// Get playback position stream
  Stream<Duration> get positionStream => _player.positionStream;

  /// Get duration stream
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Get current position
  Duration get position => _player.position;

  /// Get duration
  Duration? get duration => _player.duration;

  /// Get current volume
  double get volume => _player.volume;

  /// Get current speed
  double get speed => _player.speed;

  /// Check if playing
  bool get isPlaying => _player.playing;

  /// Get currently playing song
  Song? get currentSong => _currentSong;

  /// Get currently playing podcast
  Podcast? get currentPodcast => _currentPodcast;

  /// Get player processing state
  Stream<ProcessingState> get processingStateStream =>
      _player.processingStateStream;

  /// Get current playing state
  Stream<bool> get playingStream => _player.playingStream;

  /// Check if shuffle is enabled
  bool get isShuffleEnabled => _isShuffleEnabled;

  /// Check if repeat is enabled
  bool get isRepeatEnabled => _isRepeatEnabled;

  /// Get current playlist
  List<Song> get playlist => _playlist;

  // ============================================
  // PLAYLIST & QUEUE MANAGEMENT
  // ============================================

  /// Set playlist
  void setPlaylist(List<Song> songs, {int startIndex = 0}) {
    _playlist = songs;
    _currentIndex = startIndex;
    if (_isShuffleEnabled) {
      _shufflePlaylist();
    }
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _isShuffleEnabled = !_isShuffleEnabled;
    if (_isShuffleEnabled && _playlist.isNotEmpty) {
      _shufflePlaylist();
    }
  }

  /// Toggle repeat mode
  void toggleRepeat() {
    _isRepeatEnabled = !_isRepeatEnabled;
  }

  /// Shuffle the playlist
  void _shufflePlaylist() {
    if (_playlist.isEmpty) return;

    // Keep current song at current position
    final currentSong =
        _currentIndex < _playlist.length ? _playlist[_currentIndex] : null;

    // Shuffle the list
    _playlist.shuffle();

    // Move current song to the front if it exists
    if (currentSong != null) {
      _playlist.remove(currentSong);
      _playlist.insert(0, currentSong);
      _currentIndex = 0;
    }
  }

  /// Skip to next song
  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;

    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      await playSong(_playlist[_currentIndex]);
    } else if (_isRepeatEnabled) {
      // If repeat is on, go back to first song
      _currentIndex = 0;
      await playSong(_playlist[_currentIndex]);
    }
  }

  /// Skip to previous song
  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;

    // If we're more than 3 seconds into the song, restart it
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    // Otherwise go to previous song
    if (_currentIndex > 0) {
      _currentIndex--;
      await playSong(_playlist[_currentIndex]);
    } else if (_isRepeatEnabled) {
      // If repeat is on, go to last song
      _currentIndex = _playlist.length - 1;
      await playSong(_playlist[_currentIndex]);
    }
  }

  /// Play song at specific index in playlist
  Future<void> playAtIndex(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    await playSong(_playlist[_currentIndex]);
  }

  /// Add song to queue
  void addToQueue(Song song) {
    _playlist.add(song);
  }

  /// Clear playlist
  void clearPlaylist() {
    _playlist.clear();
    _currentIndex = 0;
  }

  // ============================================
  // CLEANUP
  // ============================================

  /// Dispose resources
  void dispose() {
    _player.dispose();
    _stateController.close();
  }
}
