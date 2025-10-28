import 'song.dart';

/// Represents a user playlist in the Harmony Hub platform
class Playlist {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final bool isPublic;
  final String? coverImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional populated songs
  final List<Song>? songs;

  Playlist({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.isPublic = false,
    this.coverImage,
    required this.createdAt,
    required this.updatedAt,
    this.songs,
  });

  /// Create a Playlist from a JSON map (from Supabase)
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      coverImage: json['cover_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      songs: json['songs'] != null
          ? (json['songs'] as List)
              .map((song) => Song.fromJson(song as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convert Playlist to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'cover_image': coverImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get song count
  int get songCount => songs?.length ?? 0;

  /// Get total duration of all songs in seconds
  int get totalDuration {
    if (songs == null || songs!.isEmpty) return 0;
    return songs!.fold(0, (sum, song) => sum + (song.duration ?? 0));
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours hr $minutes min';
    } else {
      return '$minutes min';
    }
  }

  /// Create a copy of this Playlist with updated fields
  Playlist copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isPublic,
    String? coverImage,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isPublic: isPublic ?? this.isPublic,
      coverImage: coverImage ?? this.coverImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, title: $title, songCount: $songCount)';
  }
}
