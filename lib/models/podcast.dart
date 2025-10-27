/// Represents a podcast episode in the Harmony Hub platform
class Podcast {
  final String id;
  final String title;
  final String? host;
  final String? description;
  final String? coverImage;
  final String? storagePath;
  final String? externalFeed;
  final String? category;
  final String language;
  final int? duration; // in seconds
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Podcast({
    required this.id,
    required this.title,
    this.host,
    this.description,
    this.coverImage,
    this.storagePath,
    this.externalFeed,
    this.category,
    this.language = 'en',
    this.duration,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a Podcast from a JSON map (from Supabase)
  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(
      id: json['id'] as String,
      title: json['title'] as String,
      host: json['host'] as String?,
      description: json['description'] as String?,
      coverImage: json['cover_image'] as String?,
      storagePath: json['storage_path'] as String?,
      externalFeed: json['external_feed'] as String?,
      category: json['category'] as String?,
      language: json['language'] as String? ?? 'en',
      duration: json['duration'] as int?,
      publishedAt: json['published_at'] != null
          ? DateTime.parse(json['published_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Podcast to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'host': host,
      'description': description,
      'cover_image': coverImage,
      'storage_path': storagePath,
      'external_feed': externalFeed,
      'category': category,
      'language': language,
      'duration': duration,
      'published_at': publishedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get formatted duration (e.g., "45:30" or "1:15:20")
  String get formattedDuration {
    if (duration == null) return '--:--';
    final hours = duration! ~/ 3600;
    final minutes = (duration! % 3600) ~/ 60;
    final seconds = duration! % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Check if this is an external podcast (RSS feed)
  bool get isExternal => externalFeed != null && externalFeed!.isNotEmpty;

  /// Get formatted published date
  String get formattedPublishedDate {
    if (publishedAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(publishedAt!);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays ~/ 7} weeks ago';
    } else {
      return '${publishedAt!.day}/${publishedAt!.month}/${publishedAt!.year}';
    }
  }

  /// Create a copy of this Podcast with updated fields
  Podcast copyWith({
    String? id,
    String? title,
    String? host,
    String? description,
    String? coverImage,
    String? storagePath,
    String? externalFeed,
    String? category,
    String? language,
    int? duration,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Podcast(
      id: id ?? this.id,
      title: title ?? this.title,
      host: host ?? this.host,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
      storagePath: storagePath ?? this.storagePath,
      externalFeed: externalFeed ?? this.externalFeed,
      category: category ?? this.category,
      language: language ?? this.language,
      duration: duration ?? this.duration,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Podcast && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Podcast(id: $id, title: $title, host: $host)';
  }
}
