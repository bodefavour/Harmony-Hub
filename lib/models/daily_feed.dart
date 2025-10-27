import 'package:flutter/foundation.dart';
import 'song.dart';

/// Represents a daily personalized worship feed
class DailyFeed {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String> songIds;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  // Optional populated songs
  final List<Song>? songs;

  DailyFeed({
    required this.id,
    required this.userId,
    this.title = 'Your Daily Worship',
    this.description,
    required this.songIds,
    required this.generatedAt,
    required this.expiresAt,
    required this.createdAt,
    this.songs,
  });

  /// Create a DailyFeed from a JSON map (from Supabase)
  factory DailyFeed.fromJson(Map<String, dynamic> json) {
    return DailyFeed(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String? ?? 'Your Daily Worship',
      description: json['description'] as String?,
      songIds: (json['song_ids'] as List).map((e) => e.toString()).toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      songs: json['songs'] != null
          ? (json['songs'] as List)
              .map((song) => Song.fromJson(song as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  /// Convert DailyFeed to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'song_ids': songIds,
      'generated_at': generatedAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Check if feed has expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Check if feed is still valid
  bool get isValid => !isExpired;

  /// Get song count
  int get songCount => songIds.length;

  /// Get total duration of all songs in seconds
  int get totalDuration {
    if (songs == null || songs!.isEmpty) return 0;
    return songs!.fold(0, (sum, song) => sum + (song.duration ?? 0));
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    final minutes = totalDuration ~/ 60;
    return '$minutes min';
  }

  /// Get time of day greeting based on generated time
  String get timeOfDayGreeting {
    final hour = generatedAt.hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  /// Create a copy of this DailyFeed with updated fields
  DailyFeed copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? songIds,
    DateTime? generatedAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    List<Song>? songs,
  }) {
    return DailyFeed(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      songIds: songIds ?? this.songIds,
      generatedAt: generatedAt ?? this.generatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyFeed && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DailyFeed(id: $id, title: $title, songCount: $songCount, isExpired: $isExpired)';
  }
}
