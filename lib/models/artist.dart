/// Represents a music artist in the Harmony Hub platform
class Artist {
  final String id;
  final String name;
  final String? bio;
  final String country;
  final bool verified;
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;

  Artist({
    required this.id,
    required this.name,
    this.bio,
    this.country = 'NG',
    this.verified = false,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an Artist from a JSON map (from Supabase)
  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      country: json['country'] as String? ?? 'NG',
      verified: json['verified'] as bool? ?? false,
      profileImage: json['profile_image'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert Artist to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'country': country,
      'verified': verified,
      'profile_image': profileImage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy of this Artist with updated fields
  Artist copyWith({
    String? id,
    String? name,
    String? bio,
    String? country,
    bool? verified,
    String? profileImage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      country: country ?? this.country,
      verified: verified ?? this.verified,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Artist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Artist(id: $id, name: $name, verified: $verified)';
  }
}
