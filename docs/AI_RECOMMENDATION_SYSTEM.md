# 🤖 AI Recommendation System Documentation

## Overview

The Harmony Hub AI Recommendation System provides personalized music recommendations to users based on their listening history, preferences, and contextual factors. The system is designed to be extensible and can integrate with machine learning APIs in the future.

---

## 📁 Core Files

### 1. **RecommendationService** (`lib/services/recommendation_service.dart`)
The main service that handles all recommendation logic.

### 2. **DailyFeed Model** (`lib/models/daily_feed.dart`)
Represents the AI-generated daily music feed.

### 3. **HomePageController** (`lib/pages/home_page/home_page_controller.dart`)
Manages the home page state and fetches recommendations.

---

## 🎯 How It Works

### Current Implementation (Rule-Based)

The system currently uses **rule-based algorithms** to generate recommendations. While labeled as "AI Generated" in the UI, it uses intelligent heuristics rather than machine learning (ML can be added later).

#### **Daily Feed Generation**

```dart
Future<DailyFeed?> generateDailyFeed(String userId) async {
  // 1. Fetch user's recent listening history
  final recentSongs = await getRecentSongs(userId, limit: 10);
  
  // 2. Analyze listening patterns
  final listeningHistory = await getUserListeningHistory(userId);
  final topGenres = _analyzeTopGenres(listeningHistory);
  final topArtists = _analyzeTopArtists(listeningHistory);
  
  // 3. Generate context-aware recommendations
  final recommendations = await _generateContextualRecommendations(
    userId: userId,
    topGenres: topGenres,
    topArtists: topArtists,
    limit: 20,
  );
  
  // 4. Create personalized feed
  return DailyFeed(
    title: _getTimeBasedTitle(), // e.g., "Good Morning Gospel Mix"
    description: _generateDescription(topGenres),
    songs: recommendations,
  );
}
```

---

## 🧠 Recommendation Algorithms

### 1. **Content-Based Filtering**

Recommends songs similar to what the user has listened to.

```dart
Future<List<Song>> getRecommendations(String userId, {int limit = 10}) async {
  // Get user's listening history
  final history = await getUserListeningHistory(userId);
  
  // Extract genres from listened songs
  final genres = history.map((s) => s.genre).toSet().toList();
  
  // Find similar songs in the same genres
  final recommendations = await _findSongsByGenres(genres, limit: limit);
  
  // Filter out already listened songs
  return recommendations.where((song) => 
    !history.any((h) => h.id == song.id)
  ).toList();
}
```

**How it works:**
- Analyzes user's listening history
- Identifies frequently played genres
- Recommends new songs in those genres
- Excludes already-played songs

---

### 2. **Collaborative Filtering** (Placeholder for future)

```dart
Future<List<Song>> getAIRecommendations(String userId, {int limit = 10}) async {
  // FUTURE: Call ML API here
  // For now, falls back to rule-based recommendations
  
  // Example future implementation:
  // final response = await http.post(
  //   'https://api.harmonyhub.com/ml/recommendations',
  //   body: json.encode({'userId': userId, 'limit': limit}),
  // );
  
  return await getRecommendations(userId, limit: limit);
}
```

**Future ML approach:**
- Find users with similar listening patterns
- Recommend songs those users enjoyed
- Use neural networks for pattern matching

---

### 3. **Trending Songs**

Recommends popular songs across all users.

```dart
Future<List<Song>> getTrendingSongs({int limit = 10}) async {
  // Query songs with highest play counts in last 7 days
  final response = await _supabase
      .from('songs')
      .select('*, play_count')
      .order('play_count', ascending: false)
      .limit(limit);
  
  return response.map((data) => Song.fromJson(data)).toList();
}
```

**How it works:**
- Tracks play counts across all users
- Ranks songs by popularity
- Refreshes periodically (daily/weekly)

---

### 4. **Genre-Based Recommendations**

```dart
Future<List<Song>> getSongsByGenre(String genre, {int limit = 10}) async {
  final response = await _supabase
      .from('songs')
      .select('*')
      .eq('genre', genre)
      .order('play_count', ascending: false)
      .limit(limit);
  
  return response.map((data) => Song.fromJson(data)).toList();
}
```

---

### 5. **Mood-Based Recommendations**

```dart
Future<List<Song>> getSongsByMood(String mood) async {
  // Map moods to genres
  final genreMapping = {
    'happy': ['Praise', 'Worship'],
    'peaceful': ['Worship', 'Instrumental'],
    'energetic': ['Praise', 'Contemporary Gospel'],
    'reflective': ['Hymns', 'Worship'],
  };
  
  final genres = genreMapping[mood] ?? ['Gospel'];
  return await _findSongsByGenres(genres);
}
```

---

## 📊 Data Analysis Functions

### Genre Analysis

```dart
Map<String, int> _analyzeTopGenres(List<Song> history) {
  final genreCounts = <String, int>{};
  
  for (final song in history) {
    if (song.genre != null) {
      genreCounts[song.genre!] = (genreCounts[song.genre!] ?? 0) + 1;
    }
  }
  
  // Sort by frequency
  final sortedGenres = genreCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  
  return Map.fromEntries(sortedGenres);
}
```

### Artist Analysis

```dart
Map<String, int> _analyzeTopArtists(List<Song> history) {
  final artistCounts = <String, int>{};
  
  for (final song in history) {
    final artist = song.artistName ?? 'Unknown';
    artistCounts[artist] = (artistCounts[artist] ?? 0) + 1;
  }
  
  return Map.fromEntries(
    artistCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
  );
}
```

---

## 🕐 Context-Aware Recommendations

### Time-Based Personalization

```dart
String _getTimeBasedTitle() {
  final hour = DateTime.now().hour;
  
  if (hour >= 5 && hour < 12) {
    return 'Good Morning Gospel Mix';
  } else if (hour >= 12 && hour < 17) {
    return 'Afternoon Praise Session';
  } else if (hour >= 17 && hour < 22) {
    return 'Evening Worship Time';
  } else {
    return 'Peaceful Night Worship';
  }
}
```

### Day-Based Recommendations

```dart
List<String> _getContextualGenres() {
  final now = DateTime.now();
  final dayOfWeek = now.weekday;
  
  // Sunday - More traditional worship
  if (dayOfWeek == DateTime.sunday) {
    return ['Hymns', 'Worship', 'Traditional Gospel'];
  }
  
  // Friday evening - Upbeat praise
  if (dayOfWeek == DateTime.friday && now.hour >= 17) {
    return ['Praise', 'Contemporary Gospel', 'Afrobeat Gospel'];
  }
  
  // Default mix
  return ['Worship', 'Praise', 'Gospel'];
}
```

---

## 🎨 UI Integration

### Daily Feed Card (Home Page)

Located in `lib/pages/home_page/home_page_widget_new.dart`:

```dart
FutureBuilder<DailyFeed?>(
  future: RecommendationService().generateDailyFeed(currentUserUid),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return ShimmerLoader();
    
    final dailyFeed = snapshot.data!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // AI Badge
          Container(
            child: Row(
              children: [
                Icon(Icons.auto_awesome),
                Text('AI Generated'),
              ],
            ),
          ),
          
          // Feed Title
          Text(dailyFeed.title), // "Good Morning Gospel Mix"
          
          // Description
          Text(dailyFeed.description),
          
          // Play Button
          ModernButton(
            text: 'Play Now',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              // Start playing the feed
            },
          ),
        ],
      ),
    );
  },
)
```

---

## 🔮 Future Enhancements

### 1. **Machine Learning Integration**

```dart
// Future ML-powered recommendations
Future<List<Song>> getMLRecommendations(String userId) async {
  final response = await http.post(
    'https://ml-api.harmonyhub.com/recommend',
    headers: {'Authorization': 'Bearer $apiKey'},
    body: json.encode({
      'user_id': userId,
      'limit': 20,
      'include_features': ['genre', 'tempo', 'mood', 'artist'],
    }),
  );
  
  final data = json.decode(response.body);
  return data['recommendations'].map((s) => Song.fromJson(s)).toList();
}
```

**ML Model Features:**
- User listening history (last 90 days)
- Song features (genre, tempo, energy, acousticness)
- Time of day / day of week patterns
- Skip rate / completion rate
- Collaborative filtering (similar users)

### 2. **Real-Time Personalization**

- Adjust recommendations based on current listening session
- Learn from skip behavior
- Adapt to mood changes

### 3. **Advanced Analytics**

```dart
class ListeningProfile {
  List<String> topGenres;
  List<String> topArtists;
  Map<String, double> genreDistribution;
  TimeOfDay preferredListeningTime;
  double averageSessionDuration;
  int totalPlays;
  Set<String> favoriteArtists;
}
```

### 4. **Social Recommendations**

- "Friends are listening to..."
- "Popular in your area"
- "Trending in Nigerian Gospel"

---

## 📈 Performance Optimization

### Caching Strategy

```dart
class RecommendationCache {
  final Map<String, CachedRecommendations> _cache = {};
  final Duration _cacheExpiry = Duration(hours: 1);
  
  List<Song>? get(String userId) {
    final cached = _cache[userId];
    if (cached == null) return null;
    
    if (DateTime.now().difference(cached.timestamp) > _cacheExpiry) {
      _cache.remove(userId);
      return null;
    }
    
    return cached.songs;
  }
  
  void set(String userId, List<Song> songs) {
    _cache[userId] = CachedRecommendations(
      songs: songs,
      timestamp: DateTime.now(),
    );
  }
}
```

### Database Optimization

```sql
-- Index for faster genre lookups
CREATE INDEX idx_songs_genre ON songs(genre);

-- Index for trending songs
CREATE INDEX idx_songs_play_count ON songs(play_count DESC);

-- Materialized view for daily recommendations
CREATE MATERIALIZED VIEW daily_recommendations AS
SELECT 
  s.*,
  COUNT(lh.id) as popularity_score
FROM songs s
LEFT JOIN listening_history lh ON s.id = lh.song_id
WHERE lh.played_at > NOW() - INTERVAL '7 days'
GROUP BY s.id
ORDER BY popularity_score DESC;
```

---

## 🧪 Testing Recommendations

### Test User Scenarios

```dart
void main() {
  group('Recommendation Service', () {
    test('Returns diverse genres for new users', () async {
      final recommendations = await recommendationService
          .getRecommendations('new_user_id');
      
      final genres = recommendations.map((s) => s.genre).toSet();
      expect(genres.length, greaterThan(2)); // Diverse mix
    });
    
    test('Respects user genre preferences', () async {
      // User who only listens to Worship
      final recommendations = await recommendationService
          .getRecommendations('worship_lover_id');
      
      final worshipCount = recommendations
          .where((s) => s.genre == 'Worship')
          .length;
      
      expect(worshipCount / recommendations.length, greaterThan(0.7));
    });
  });
}
```

---

## 🎯 Summary

### Current Features
✅ Rule-based content filtering  
✅ Genre-based recommendations  
✅ Trending songs discovery  
✅ Time-aware daily feeds  
✅ Mood-based suggestions  
✅ New releases tracking  

### Coming Soon
🔲 ML-powered personalization  
🔲 Collaborative filtering  
🔲 Real-time adaptation  
🔲 Social recommendations  
🔲 Advanced analytics dashboard  

---

## 💡 Key Takeaways

1. **It's "Smart" Not "AI"**: Currently uses intelligent rules, not machine learning
2. **Context Matters**: Time of day, day of week, and user history all influence recommendations
3. **User-Centric**: Analyzes individual listening patterns for personalization
4. **Scalable Design**: Easy to swap in ML APIs when ready
5. **Gospel-Focused**: Tailored specifically for Christian/Gospel music discovery

The "AI Generated" badge in the UI is forward-looking - the architecture supports easy integration with actual ML models in the future! 🚀
