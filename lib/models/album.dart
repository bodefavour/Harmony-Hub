/// Represents a music album in the Harmony Hub platform
class Album {
  final String id;
  final String? artistId;
  final String title;
  final String? coverImage;
  final DateTime? releaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  Album({
    required this.id,
    this.artistId,
    required this.title,
    this.coverImage,
    this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an Album from a JSON map (from Supabase)
  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      artistId: json['artist_id'] as String?,
      title: json['title'] as String,
      coverImage: json['cover_image'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Album to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artist_id': artistId,
      'title': title,
      'cover_image': coverImage,
      'release_date': releaseDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this Album with updated fields
  Album copyWith({
    String? id,
    String? artistId,
    String? title,
    String? coverImage,
    DateTime? releaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Album(
      id: id ?? this.id,
      artistId: artistId ?? this.artistId,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      releaseDate: releaseDate ?? this.releaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Album && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Album(id: $id, title: $title, artistId: $artistId)';
  }
}
