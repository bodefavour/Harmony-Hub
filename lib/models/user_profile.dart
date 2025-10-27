import 'package:flutter/foundation.dart';

/// Represents user preferences for music recommendations
class UserPreferences {
  final List<String> genres;
  final String morningPreference; // Time in HH:mm format
  final String language;

  UserPreferences({
    this.genres = const ['Gospel', 'Worship', 'Praise'],
    this.morningPreference = '06:00',
    this.language = 'en',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      genres: (json['genres'] as List?)?.map((e) => e.toString()).toList() ??
          ['Gospel', 'Worship', 'Praise'],
      morningPreference: json['morning_preference'] as String? ?? '06:00',
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'genres': genres,
      'morning_preference': morningPreference,
      'language': language,
    };
  }

  UserPreferences copyWith({
    List<String>? genres,
    String? morningPreference,
    String? language,
  }) {
    return UserPreferences(
      genres: genres ?? this.genres,
      morningPreference: morningPreference ?? this.morningPreference,
      language: language ?? this.language,
    );
  }
}

/// Represents a user profile in the Harmony Hub platform
class UserProfile {
  final String id;
  final String? displayName;
  final String? email;
  final String country;
  final UserPreferences preferences;
  final bool isAdmin;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    this.displayName,
    this.email,
    this.country = 'NG',
    UserPreferences? preferences,
    this.isAdmin = false,
    this.isPremium = false,
    required this.createdAt,
    required this.updatedAt,
  }) : preferences = preferences ?? UserPreferences();

  /// Create a UserProfile from a JSON map (from Supabase)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      country: json['country'] as String? ?? 'NG',
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(json['preferences'] as Map<String, dynamic>)
          : UserPreferences(),
      isAdmin: json['is_admin'] as bool? ?? false,
      isPremium: json['is_premium'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert UserProfile to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'email': email,
      'country': country,
      'preferences': preferences.toJson(),
      'is_admin': isAdmin,
      'is_premium': isPremium,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get initials for avatar (e.g., "JD" from "John Doe")
  String get initials {
    if (displayName == null || displayName!.isEmpty) {
      return email?.substring(0, 1).toUpperCase() ?? 'U';
    }
    final parts = displayName!.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName!.substring(0, 1).toUpperCase();
  }

  /// Get display name or fallback to email
  String get displayNameOrEmail {
    if (displayName != null && displayName!.isNotEmpty) {
      return displayName!;
    }
    return email ?? 'User';
  }

  /// Create a copy of this UserProfile with updated fields
  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? country,
    UserPreferences? preferences,
    bool? isAdmin,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      country: country ?? this.country,
      preferences: preferences ?? this.preferences,
      isAdmin: isAdmin ?? this.isAdmin,
      isPremium: isPremium ?? this.isPremium,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProfile(id: $id, displayName: $displayName, isAdmin: $isAdmin, isPremium: $isPremium)';
  }
}
