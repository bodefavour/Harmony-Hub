import 'package:flutter/foundation.dart';

/// Status of an admin upload
enum UploadStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case UploadStatus.pending:
        return 'Pending Review';
      case UploadStatus.approved:
        return 'Approved';
      case UploadStatus.rejected:
        return 'Rejected';
    }
  }

  static UploadStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return UploadStatus.pending;
      case 'approved':
        return UploadStatus.approved;
      case 'rejected':
        return UploadStatus.rejected;
      default:
        return UploadStatus.pending;
    }
  }
}

/// Represents an artist upload pending admin approval
class AdminUpload {
  final String id;
  final String uploaderId;
  final String artistName;
  final String songTitle;
  final String? albumTitle;
  final String? genre;
  final String language;
  final String storagePath;
  final String? coverImage;
  final UploadStatus status;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdminUpload({
    required this.id,
    required this.uploaderId,
    required this.artistName,
    required this.songTitle,
    this.albumTitle,
    this.genre,
    this.language = 'en',
    required this.storagePath,
    this.coverImage,
    this.status = UploadStatus.pending,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an AdminUpload from a JSON map (from Supabase)
  factory AdminUpload.fromJson(Map<String, dynamic> json) {
    return AdminUpload(
      id: json['id'] as String,
      uploaderId: json['uploader_id'] as String,
      artistName: json['artist_name'] as String,
      songTitle: json['song_title'] as String,
      albumTitle: json['album_title'] as String?,
      genre: json['genre'] as String?,
      language: json['language'] as String? ?? 'en',
      storagePath: json['storage_path'] as String,
      coverImage: json['cover_image'] as String?,
      status: UploadStatus.fromString(json['status'] as String? ?? 'pending'),
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert AdminUpload to JSON map (for Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uploader_id': uploaderId,
      'artist_name': artistName,
      'song_title': songTitle,
      'album_title': albumTitle,
      'genre': genre,
      'language': language,
      'storage_path': storagePath,
      'cover_image': coverImage,
      'status': status.name,
      'reviewed_by': reviewedBy,
      'reviewed_at': reviewedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if upload is pending review
  bool get isPending => status == UploadStatus.pending;

  /// Check if upload is approved
  bool get isApproved => status == UploadStatus.approved;

  /// Check if upload is rejected
  bool get isRejected => status == UploadStatus.rejected;

  /// Get formatted upload date
  String get formattedCreatedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  /// Create a copy of this AdminUpload with updated fields
  AdminUpload copyWith({
    String? id,
    String? uploaderId,
    String? artistName,
    String? songTitle,
    String? albumTitle,
    String? genre,
    String? language,
    String? storagePath,
    String? coverImage,
    UploadStatus? status,
    String? reviewedBy,
    DateTime? reviewedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUpload(
      id: id ?? this.id,
      uploaderId: uploaderId ?? this.uploaderId,
      artistName: artistName ?? this.artistName,
      songTitle: songTitle ?? this.songTitle,
      albumTitle: albumTitle ?? this.albumTitle,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      storagePath: storagePath ?? this.storagePath,
      coverImage: coverImage ?? this.coverImage,
      status: status ?? this.status,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminUpload && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AdminUpload(id: $id, artistName: $artistName, songTitle: $songTitle, status: ${status.name})';
  }
}
