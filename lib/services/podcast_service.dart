import '../models/podcast.dart';
import 'supabase_service.dart';

/// Service to manage podcast content
class PodcastService {
  static final PodcastService _instance = PodcastService._internal();
  factory PodcastService() => _instance;
  PodcastService._internal();

  final SupabaseService _supabaseService = SupabaseService();

  // ============================================
  // PODCAST OPERATIONS
  // ============================================

  /// Fetch all podcasts
  Future<List<Podcast>> fetchPodcasts(
      {String? category, int limit = 50}) async {
    try {
      return await _supabaseService.fetchPodcasts(
        category: category,
        limit: limit,
      );
    } catch (e) {
      print('Error fetching podcasts: $e');
      return [];
    }
  }

  /// Get podcast by ID
  Future<Podcast?> getPodcastById(String podcastId) async {
    try {
      return await _supabaseService.getPodcastById(podcastId);
    } catch (e) {
      print('Error getting podcast: $e');
      return null;
    }
  }

  /// Get all podcast categories
  Future<List<String>> getCategories() async {
    try {
      final categories = await _supabaseService.getPodcastCategories();

      // Add "All" category at the beginning
      return ['All', ...categories];
    } catch (e) {
      print('Error getting categories: $e');
      return ['All', 'Devotional', 'Sermon', 'Teaching', 'Music'];
    }
  }

  /// Get latest podcasts
  Future<List<Podcast>> getLatestPodcasts({int limit = 10}) async {
    try {
      return await _supabaseService.fetchPodcasts(limit: limit);
    } catch (e) {
      print('Error getting latest podcasts: $e');
      return [];
    }
  }

  /// Get podcasts by category
  Future<List<Podcast>> getPodcastsByCategory(
    String category, {
    int limit = 50,
  }) async {
    try {
      if (category == 'All') {
        return await fetchPodcasts(limit: limit);
      }
      return await _supabaseService.fetchPodcasts(
        category: category,
        limit: limit,
      );
    } catch (e) {
      print('Error getting podcasts by category: $e');
      return [];
    }
  }

  // ============================================
  // FUTURE: RSS FEED INTEGRATION
  // ============================================

  /// Parse RSS feed from external URL (placeholder for future implementation)
  /// This would fetch and parse RSS feeds for external podcasts
  Future<List<Podcast>> fetchExternalPodcastFeed(String feedUrl) async {
    // TODO: Implement RSS feed parsing
    // 1. Fetch RSS feed from URL
    // 2. Parse XML
    // 3. Convert to Podcast objects
    // 4. Cache episodes

    print('RSS feed parsing not yet implemented');
    return [];
  }

  /// Sync external podcast feeds (for scheduled updates)
  Future<void> syncExternalFeeds() async {
    // TODO: Implement feed sync
    // 1. Get all podcasts with external_feed URL
    // 2. Fetch and parse each feed
    // 3. Update database with new episodes

    print('Feed sync not yet implemented');
  }

  // ============================================
  // PODCAST LIBRARY (User-specific)
  // ============================================

  /// Check if user follows a podcast
  Future<bool> isFollowingPodcast(String userId, String podcastId) async {
    // TODO: Implement podcast following/favoriting
    // Similar to song favorites in user_library

    print('Podcast following not yet implemented');
    return false;
  }

  /// Follow a podcast
  Future<void> followPodcast(String userId, String podcastId) async {
    // TODO: Implement podcast following
    // Add to user's followed podcasts

    print('Follow podcast not yet implemented');
  }

  /// Unfollow a podcast
  Future<void> unfollowPodcast(String userId, String podcastId) async {
    // TODO: Implement podcast unfollowing

    print('Unfollow podcast not yet implemented');
  }

  /// Get user's followed podcasts
  Future<List<Podcast>> getFollowedPodcasts(String userId) async {
    // TODO: Implement get followed podcasts

    print('Get followed podcasts not yet implemented');
    return [];
  }
}
