import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/services/supabase_service.dart';
import '/services/audio_service.dart';
import '/services/recommendation_service.dart';
import 'search_controller.dart' as search;

class SearchWidgetNew extends StatefulWidget {
  const SearchWidgetNew({super.key});

  @override
  State<SearchWidgetNew> createState() => _SearchWidgetNewState();
}

class _SearchWidgetNewState extends State<SearchWidgetNew>
    with SingleTickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'Search'});
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => search.SearchController(
        supabaseService: SupabaseService(),
        audioService: AudioService(),
        recommendationService: RecommendationService(),
      )..initialize(),
      child: Consumer<search.SearchController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: const Color(0xFFE74B08),
                automaticallyImplyLeading: false,
                title: Text(
                  'Search',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 28.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                centerTitle: false,
                elevation: 2.0,
              ),
              body: _buildSearchBody(context, controller),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBody(BuildContext context, search.SearchController controller) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search songs, artists, albums, podcasts...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFE74B08)),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        controller.clearSearch();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: FlutterFlowTheme.of(context).secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE74B08), width: 2),
              ),
            ),
            onChanged: (query) {
              setState(() {});
              // Debounce search
              Future.delayed(const Duration(milliseconds: 500), () {
                if (query == _searchController.text && query.isNotEmpty) {
                  controller.search(query);
                }
              });
            },
          ),
        ),

        // Content
        Expanded(
          child: controller.isSearching
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74B08)),
                  ),
                )
              : _searchController.text.isEmpty
                  ? _buildTrendingSection(context, controller)
                  : _buildSearchResults(context, controller),
        ),
      ],
    );
  }

  Widget _buildTrendingSection(BuildContext context, search.SearchController controller) {
    if (controller.isLoadingTrending) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74B08)),
        ),
      );
    }

    if (!controller.hasTrendingSongs) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No trending songs available',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Trending Now 🔥',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                fontFamily: 'Outfit',
                color: const Color(0xFFE74B08),
                fontSize: 22.0,
                letterSpacing: 0.0,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        ...controller.trendingSongs.map((song) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  logFirebaseEvent('SEARCH_TRENDING_SONG_TAP');
                  context.pushNamed(
                    'musicOpen',
                    pathParameters: {'songId': song.id},
                    extra: <String, dynamic>{
                      'song': song.toJson(),
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        song.album?.coverImage ?? '',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: const Color(0xFFE74B08),
                          child: const Icon(Icons.music_note, color: Colors.white),
                        ),
                      ),
                    ),
                    title: Text(
                      song.title,
                      style: FlutterFlowTheme.of(context).titleMedium,
                    ),
                    subtitle: Text(
                      song.artistName ?? 'Unknown Artist',
                      style: FlutterFlowTheme.of(context).bodySmall,
                    ),
                    trailing: FlutterFlowIconButton(
                      borderRadius: 20,
                      borderWidth: 1,
                      buttonSize: 40,
                      fillColor: const Color(0xFFE74B08),
                      icon: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () {
                        logFirebaseEvent('SEARCH_PLAY_TRENDING_SONG');
                        controller.playSong(song);
                      },
                    ),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, search.SearchController controller) {
    if (!controller.hasSearchResults) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: FlutterFlowTheme.of(context).headlineSmall.override(
                    fontFamily: 'Outfit',
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: Colors.grey,
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFE74B08),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFE74B08),
          tabs: [
            Tab(text: 'Songs (${controller.searchResultsSongs.length})'),
            Tab(text: 'Artists (${controller.searchResultsArtists.length})'),
            Tab(text: 'Albums (${controller.searchResultsAlbums.length})'),
            Tab(text: 'Podcasts (${controller.searchResultsPodcasts.length})'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSongsList(context, controller),
              _buildArtistsList(context, controller),
              _buildAlbumsList(context, controller),
              _buildPodcastsList(context, controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSongsList(BuildContext context, search.SearchController controller) {
    if (controller.searchResultsSongs.isEmpty) {
      return _buildEmptyTabState('No songs found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResultsSongs.length,
      itemBuilder: (context, index) {
        final song = controller.searchResultsSongs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              logFirebaseEvent('SEARCH_SONG_RESULT_TAP');
              context.pushNamed(
                'musicOpen',
                pathParameters: {'songId': song.id},
                extra: <String, dynamic>{
                  'song': song.toJson(),
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    song.album?.coverImage ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFE74B08),
                      child: const Icon(Icons.music_note, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                subtitle: Text(
                  song.artistName ?? 'Unknown Artist',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                trailing: FlutterFlowIconButton(
                  borderRadius: 20,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFFE74B08),
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    logFirebaseEvent('SEARCH_PLAY_SONG_RESULT');
                    controller.playSong(song);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildArtistsList(BuildContext context, search.SearchController controller) {
    if (controller.searchResultsArtists.isEmpty) {
      return _buildEmptyTabState('No artists found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResultsArtists.length,
      itemBuilder: (context, index) {
        final artist = controller.searchResultsArtists[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              logFirebaseEvent('SEARCH_ARTIST_RESULT_TAP');
              context.pushNamed(
                'artistProfile',
                pathParameters: {'artistId': artist.id},
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: artist.profileImage != null
                      ? NetworkImage(artist.profileImage!)
                      : null,
                  backgroundColor: const Color(0xFFE74B08),
                  child: artist.profileImage == null
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                title: Text(
                  artist.name,
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                subtitle: Text(
                  artist.country,
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlbumsList(BuildContext context, search.SearchController controller) {
    if (controller.searchResultsAlbums.isEmpty) {
      return _buildEmptyTabState('No albums found');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: controller.searchResultsAlbums.length,
      itemBuilder: (context, index) {
        final album = controller.searchResultsAlbums[index];
        return InkWell(
          onTap: () {
            logFirebaseEvent('SEARCH_ALBUM_RESULT_TAP');
            context.pushNamed(
              'album',
              pathParameters: {'albumId': album.id},
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.network(
                      album.coverImage ?? '',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xFFE74B08),
                        child: const Icon(
                          Icons.album,
                          size: 48,
                          color: Colors.white,
                        ),
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
                        album.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context)
                            .bodyMedium
                            .override(
                              fontFamily: 'Readex Pro',
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        album.releaseDate?.year.toString() ?? 'Unknown',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodcastsList(BuildContext context, search.SearchController controller) {
    if (controller.searchResultsPodcasts.isEmpty) {
      return _buildEmptyTabState('No podcasts found');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.searchResultsPodcasts.length,
      itemBuilder: (context, index) {
        final podcast = controller.searchResultsPodcasts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              logFirebaseEvent('SEARCH_PODCAST_RESULT_TAP');
              context.pushNamed(
                'PodcastDetail',
                pathParameters: {'podcastId': podcast.id},
                extra: <String, dynamic>{
                  'podcast': podcast.toJson(),
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    podcast.coverImage ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: const Color(0xFFE74B08),
                      child: const Icon(Icons.podcasts, color: Colors.white),
                    ),
                  ),
                ),
                title: Text(
                  podcast.title,
                  style: FlutterFlowTheme.of(context).titleMedium,
                ),
                subtitle: Text(
                  podcast.host ?? 'Unknown Host',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
                trailing: FlutterFlowIconButton(
                  borderRadius: 20,
                  borderWidth: 1,
                  buttonSize: 40,
                  fillColor: const Color(0xFFE74B08),
                  icon: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    logFirebaseEvent('SEARCH_PLAY_PODCAST_RESULT');
                    controller.playPodcast(podcast);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyTabState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Readex Pro',
                color: Colors.grey,
              ),
        ),
      ),
    );
  }
}
