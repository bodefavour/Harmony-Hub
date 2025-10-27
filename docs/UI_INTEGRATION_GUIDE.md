# UI Integration Guide - Wire Controllers to Widgets

This guide shows how to integrate the controllers (LibraryController, SearchController, ArtistProfileController) into the existing UI widgets.

## 🎯 Integration Pattern

All three pages follow the same pattern:

```dart
1. Import controller and services
2. Wrap widget with ChangeNotifierProvider
3. Use Consumer to access controller state
4. Call controller methods on user actions
5. Display controller data in UI
```

---

## 📚 Library Widget Integration

### Step 1: Add Imports

Add to top of `lib/pages/library/library_widget.dart`:

```dart
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';
import 'library_controller.dart';
```

### Step 2: Wrap with Provider

Replace the existing `build()` method pattern:

```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => LibraryController(
      supabaseService: SupabaseService(),
      audioService: AudioService(),
    )..initialize(currentUser.uid), // Get from FFAppState or auth
    child: Consumer<LibraryController>(
      builder: (context, controller, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: _buildLibraryBody(context, controller),
          ),
        );
      },
    ),
  );
}
```

### Step 3: Create Body Builder

```dart
Widget _buildLibraryBody(BuildContext context, LibraryController controller) {
  // Show loading
  if (controller.isLoading) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFE74B08)),
    );
  }

  // Show error
  if (controller.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text('Error: ${controller.error}'),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.refresh(currentUser.uid),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Show library content
  return RefreshIndicator(
    onRefresh: () => controller.refresh(currentUser.uid),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Songs Section
          if (controller.hasRecentSongs) _buildRecentSection(controller),
          
          // Favorites Section
          if (controller.hasFavoriteSongs) _buildFavoritesSection(controller),
          
          // Albums Section
          if (controller.hasFavoriteAlbums) _buildAlbumsSection(controller),
          
          // Playlists Section
          if (controller.hasPlaylists) _buildPlaylistsSection(controller),
        ],
      ),
    ),
  );
}
```

### Step 4: Build Sections

```dart
Widget _buildRecentSection(LibraryController controller) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recently Played',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Outfit',
            color: Color(0xFFE74B08),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.recentSongs.length,
          itemBuilder: (context, index) {
            final song = controller.recentSongs[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(song.coverImage ?? ''),
                backgroundColor: Color(0xFFE74B08),
              ),
              title: Text(song.title),
              subtitle: Text(song.artistName),
              trailing: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => controller.playSong(song),
              ),
              onTap: () {
                context.pushNamed(
                  'musicOpen',
                  pathParameters: {'songId': song.id},
                  extra: {'song': song.toJson()},
                );
              },
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildFavoritesSection(LibraryController controller) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Favorite Songs',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
            fontFamily: 'Outfit',
            color: Color(0xFFE74B08),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.favoriteSongs.length,
          itemBuilder: (context, index) {
            final song = controller.favoriteSongs[index];
            return GestureDetector(
              onTap: () => controller.playSong(song),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(song.coverImage ?? ''),
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            song.artistName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildPlaylistsSection(LibraryController controller) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Your Playlists',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: Color(0xFFE74B08),
                fontWeight: FontWeight.bold,
              ),
            ),
            FFButtonWidget(
              onPressed: () => _showCreatePlaylistDialog(context, controller),
              text: 'Create',
              icon: Icon(Icons.add, size: 16),
              options: FFButtonOptions(
                height: 36,
                color: Color(0xFFE74B08),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.playlists.length,
          itemBuilder: (context, index) {
            final playlist = controller.playlists[index];
            return ListTile(
              leading: Icon(Icons.playlist_play, color: Color(0xFFE74B08)),
              title: Text(playlist.title),
              subtitle: Text(playlist.description ?? 'No description'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to playlist detail page
                context.pushNamed(
                  'PlaylistDetail',
                  pathParameters: {'playlistId': playlist.id},
                );
              },
            );
          },
        ),
      ],
    ),
  );
}
```

### Step 5: Create Playlist Dialog

```dart
void _showCreatePlaylistDialog(BuildContext context, LibraryController controller) {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Create Playlist'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Playlist Name',
              hintText: 'Enter playlist name',
            ),
          ),
          SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter description',
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isNotEmpty) {
              final success = await controller.createPlaylist(
                currentUser.uid,
                nameController.text.trim(),
                description: descController.text.trim().isEmpty 
                    ? null 
                    : descController.text.trim(),
              );
              
              Navigator.pop(dialogContext);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Playlist created!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to create playlist')),
                );
              }
            }
          },
          child: Text('Create'),
        ),
      ],
    ),
  );
}
```

---

## 🔍 Search Widget Integration

### Step 1: Add Imports

Add to `lib/pages/search/search_widget.dart`:

```dart
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';
import '../../services/recommendation_service.dart';
import 'search_controller.dart';
```

### Step 2: Wrap with Provider

```dart
@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => SearchController(
      supabaseService: SupabaseService(),
      audioService: AudioService(),
      recommendationService: RecommendationService(),
    )..initialize(),
    child: Consumer<SearchController>(
      builder: (context, controller, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: _buildSearchBody(context, controller),
          ),
        );
      },
    ),
  );
}
```

### Step 3: Build Search Body

```dart
Widget _buildSearchBody(BuildContext context, SearchController controller) {
  return SafeArea(
    child: Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: controller.searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () => controller.clearSearch(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (query) {
              // Debounce search
              Future.delayed(Duration(milliseconds: 500), () {
                if (query == controller.searchQuery) {
                  controller.search(query);
                }
              });
            },
          ),
        ),

        // Content
        Expanded(
          child: controller.isSearching
              ? Center(child: CircularProgressIndicator(color: Color(0xFFE74B08)))
              : controller.searchQuery.isEmpty
                  ? _buildTrendingSection(controller)
                  : _buildSearchResults(controller),
        ),
      ],
    ),
  );
}

Widget _buildTrendingSection(SearchController controller) {
  if (controller.isLoadingTrending) {
    return Center(child: CircularProgressIndicator(color: Color(0xFFE74B08)));
  }

  if (!controller.hasTrendingSongs) {
    return Center(child: Text('No trending songs'));
  }

  return ListView(
    padding: EdgeInsets.all(16),
    children: [
      Text(
        'Trending Now',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
          fontFamily: 'Outfit',
          color: Color(0xFFE74B08),
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      ...controller.trendingSongs.map((song) => ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(song.coverImage ?? ''),
        ),
        title: Text(song.title),
        subtitle: Text(song.artistName),
        trailing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () => controller.playSong(song),
        ),
      )),
    ],
  );
}

Widget _buildSearchResults(SearchController controller) {
  if (!controller.hasSearchResults) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('No results found'),
        ],
      ),
    );
  }

  return DefaultTabController(
    length: 4,
    child: Column(
      children: [
        TabBar(
          labelColor: Color(0xFFE74B08),
          tabs: [
            Tab(text: 'Songs (${controller.searchResultsSongs.length})'),
            Tab(text: 'Artists (${controller.searchResultsArtists.length})'),
            Tab(text: 'Albums (${controller.searchResultsAlbums.length})'),
            Tab(text: 'Podcasts (${controller.searchResultsPodcasts.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            children: [
              _buildSongsList(controller.searchResultsSongs, controller),
              _buildArtistsList(controller.searchResultsArtists),
              _buildAlbumsList(controller.searchResultsAlbums),
              _buildPodcastsList(controller.searchResultsPodcasts, controller),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSongsList(List<Song> songs, SearchController controller) {
  return ListView.builder(
    itemCount: songs.length,
    itemBuilder: (context, index) {
      final song = songs[index];
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(song.coverImage ?? ''),
        ),
        title: Text(song.title),
        subtitle: Text(song.artistName),
        trailing: IconButton(
          icon: Icon(Icons.play_arrow),
          onPressed: () => controller.playSong(song),
        ),
        onTap: () {
          context.pushNamed(
            'musicOpen',
            pathParameters: {'songId': song.id},
            extra: {'song': song.toJson()},
          );
        },
      );
    },
  );
}

Widget _buildArtistsList(List<Artist> artists) {
  return ListView.builder(
    itemCount: artists.length,
    itemBuilder: (context, index) {
      final artist = artists[index];
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(artist.profileImage ?? ''),
        ),
        title: Text(artist.name),
        subtitle: Text(artist.country),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          context.pushNamed(
            'artistProfile',
            pathParameters: {'artistId': artist.id},
          );
        },
      );
    },
  );
}
```

---

## 👤 Artist Profile Widget Integration

### Step 1: Update Widget Parameters

Modify `lib/pages/artist_profile/artist_profile_widget.dart`:

```dart
class ArtistProfileWidget extends StatefulWidget {
  final String? artistId;
  
  const ArtistProfileWidget({
    super.key,
    this.artistId,
  });

  @override
  State<ArtistProfileWidget> createState() => _ArtistProfileWidgetState();
}
```

### Step 2: Add Imports and Provider

```dart
import 'package:provider/provider.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';
import 'artist_profile_controller.dart';

@override
Widget build(BuildContext context) {
  return ChangeNotifierProvider(
    create: (_) => ArtistProfileController(
      supabaseService: SupabaseService(),
      audioService: AudioService(),
    )..initialize(
      widget.artistId ?? '',
      userId: currentUser.uid,
    ),
    child: Consumer<ArtistProfileController>(
      builder: (context, controller, _) {
        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: _buildArtistBody(context, controller),
          ),
        );
      },
    ),
  );
}
```

### Step 3: Build Artist Body

```dart
Widget _buildArtistBody(BuildContext context, ArtistProfileController controller) {
  if (controller.isLoading) {
    return Center(child: CircularProgressIndicator(color: Color(0xFFE74B08)));
  }

  if (controller.error != null || controller.artist == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(controller.error ?? 'Artist not found'),
        ],
      ),
    );
  }

  return CustomScrollView(
    slivers: [
      // Artist Header
      SliverAppBar(
        expandedHeight: 300,
        pinned: true,
        flexibleSpace: FlexibleSpaceBar(
          background: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                controller.artistImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: Colors.grey),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.artistName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => controller.toggleFollow(currentUser.uid),
                          icon: Icon(controller.isFollowing ? Icons.check : Icons.add),
                          label: Text(controller.isFollowing ? 'Following' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE74B08),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.share, color: Colors.white),
                          onPressed: () => controller.shareArtist(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Top Songs
      if (controller.hasTopSongs)
        SliverToBoxAdapter(
          child: _buildTopSongsSection(controller),
        ),

      // Albums
      if (controller.hasAlbums)
        SliverToBoxAdapter(
          child: _buildAlbumsSection(controller),
        ),
    ],
  );
}

Widget _buildTopSongsSection(ArtistProfileController controller) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE74B08),
              ),
            ),
            TextButton(
              onPressed: () => controller.playAllTopSongs(),
              child: Text('Play All'),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: controller.topSongs.length,
          itemBuilder: (context, index) {
            final song = controller.topSongs[index];
            return ListTile(
              leading: Text(
                '${index + 1}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE74B08),
                ),
              ),
              title: Text(song.title),
              subtitle: Text('${song.playCount ?? 0} plays'),
              trailing: IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () => controller.playSong(song),
              ),
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildAlbumsSection(ArtistProfileController controller) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Albums',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE74B08),
          ),
        ),
        SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.albums.length,
            itemBuilder: (context, index) {
              final album = controller.albums[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      'album',
                      pathParameters: {'albumId': album.id},
                    );
                  },
                  child: Container(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(album.coverImage ?? ''),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          album.releaseDate.year.toString(),
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}
```

---

## 🔑 Key Points

### Getting User ID
```dart
// From FFAppState
final userId = FFAppState().userId;

// Or from auth
final userId = currentUser?.uid ?? '';

// Or from Supabase Auth
final userId = SupabaseAuth.instance.currentUser?.id ?? '';
```

### Error Handling
All controllers have error states:
```dart
if (controller.error != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: ${controller.error}')),
  );
  controller.clearError();
}
```

### Loading States
All controllers have loading indicators:
```dart
if (controller.isLoading) {
  return CircularProgressIndicator(color: Color(0xFFE74B08));
}
```

### Navigation with Data
Pass song data to music player:
```dart
context.pushNamed(
  'musicOpen',
  pathParameters: {'songId': song.id},
  extra: {'song': song.toJson()},
);
```

---

## ✅ Checklist

### Library Widget
- [ ] Add imports
- [ ] Wrap with ChangeNotifierProvider
- [ ] Replace hardcoded recent songs with controller.recentSongs
- [ ] Replace hardcoded favorites with controller.favoriteSongs
- [ ] Replace hardcoded playlists with controller.playlists
- [ ] Wire create playlist button
- [ ] Add pull-to-refresh

### Search Widget
- [ ] Add imports
- [ ] Wrap with ChangeNotifierProvider
- [ ] Wire search TextField to controller.search()
- [ ] Show trending when no search
- [ ] Show search results in tabs
- [ ] Wire play buttons

### Artist Profile Widget
- [ ] Add artistId parameter
- [ ] Add imports
- [ ] Wrap with ChangeNotifierProvider
- [ ] Display artist info from controller
- [ ] Wire follow button
- [ ] Show top songs from controller
- [ ] Show albums from controller

---

## 🚀 Testing After Integration

1. **Library Page:**
   - Check recent songs load
   - Check favorites load
   - Check playlists load
   - Test create playlist
   - Test play song

2. **Search Page:**
   - Check trending loads
   - Test search functionality
   - Check all result tabs
   - Test navigation to details

3. **Artist Profile:**
   - Check artist loads with ID
   - Test follow/unfollow
   - Check top songs display
   - Check albums display
   - Test play songs

---

**Next:** Implement these patterns in the actual widget files and test!
