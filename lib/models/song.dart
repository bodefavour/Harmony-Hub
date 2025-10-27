import 'package:flutter/foundation.dart';
import 'artist.dart';
import 'album.dart';

/// Represents a song in the Harmony Hub platform
class Song {
  final String id;
  final String? albumId;
  final String? artistId;
  final String title;
  final int? duration; // in seconds
  final String? genre;
  final String language;
  final String storagePath;
  final String? spotifyUri;
  final bool isLocal;
  final bool explicit;
  final int playCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional populated relationships
  final Artist? artist;
  final Album? album;

  Song({
    required this.id,
    this.albumId,
    this.artistId,
    required this.title,
    this.duration,
    this.genre,
    this.language = 'en',
    required this.storagePath,
    this.spotifyUri,
    this.isLocal = true,
    this.explicit = false,
    this.playCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.artist,
    this.album,
  });

  /// Create a Song from a JSON map (from Supabase)
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      albumId: json['album_id'] as String?,
      artistId: json['artist_id'] as String?,
      title: json['title'] as String,
      duration: json['duration'] as int?,
      genre: json['genre'] as String?,
      language: json['language'] as String? ?? 'en',
      storagePath: json['storage_path'] as String,
      spotifyUri: json['spotify_uri'] as String?,
      isLocal: json['is_local'] as bool? ?? true,
      explicit: json['explicit'] as bool? ?? false,
      playCount: json['play_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      artist: json['artist'] != null
          ? Artist.fromJson(json['artist'] as Map<String, dynamic>)
          : null,
      album: json['album'] != null
          ? Album.fromJson(json['album'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert Song to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'album_id': albumId,
      'artist_id': artistId,
      'title': title,
      'duration': duration,
      'genre': genre,
      'language': language,
      'storage_path': storagePath,
      'spotify_uri': spotifyUri,
      'is_local': isLocal,
      'explicit': explicit,
      'play_count': playCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted duration (e.g., "3:45")
  String get formattedDuration {
    if (duration == null) return '--:--';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get artist name (from populated artist or null)
  String? get artistName => artist?.name;

  /// Get album title (from populated album or null)
  String? get albumTitle => album?.title;

  /// Create a copy of this Song with updated fields
  Song copyWith({
    String? id,
    String? albumId,
    String? artistId,
    String? title,
    int? duration,
    String? genre,
    String? language,
    String? storagePath,
    String? spotifyUri,
    bool? isLocal,
    bool? explicit,
    int? playCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Artist? artist,
    Album? album,
  }) {
    return Song(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      title: title ?? this.title,
      duration: duration ?? this.duration,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      storagePath: storagePath ?? this.storagePath,
      spotifyUri: spotifyUri ?? this.spotifyUri,
      isLocal: isLocal ?? this.isLocal,
      explicit: explicit ?? this.explicit,
      playCount: playCount ?? this.playCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      artist: artist ?? this.artist,
      album: album ?? this.album,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artistName: $artistName)';
  }
}
