import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/supabase_auth/auth_util.dart';
import '../../models/models.dart';
import 'home_page_controller.dart';

class HomePageNewWidget extends StatefulWidget {
  const HomePageNewWidget({super.key});

  @override
  State<HomePageNewWidget> createState() => _HomePageNewWidgetState();
}

class _HomePageNewWidgetState extends State<HomePageNewWidget> {
  late HomePageController _controller;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _controller = HomePageController();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = currentUserUid;
    if (userId.isNotEmpty) {
      await _controller.initialize(userId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<HomePageController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              body: SafeArea(
                top: true,
                child: controller.isLoading
                    ? _buildLoadingState()
                    : controller.error != null
                        ? _buildErrorState(controller.error!)
                        : _buildContent(controller),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: FlutterFlowTheme.of(context).primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading your worship feed...',
            style: FlutterFlowTheme.of(context).bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: FlutterFlowTheme.of(context).error,
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: FlutterFlowTheme.of(context).bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FFButtonWidget(
              onPressed: () => _loadData(),
              text: 'Retry',
              options: FFButtonOptions(
                width: 200,
                height: 48,
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                    ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(HomePageController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.refresh(currentUserUid),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with greeting
            _buildHeader(controller),
            const SizedBox(height: 24),

            // Daily Worship Feed Card
            if (controller.dailyFeed != null) ...[
              _buildDailyFeedCard(controller.dailyFeed!),
              const SizedBox(height: 32),
            ],

            // Mood Selector
            _buildMoodSelector(),
            const SizedBox(height: 32),

            // Trending Songs
            if (controller.trendingSongs.isNotEmpty) ...[
              _buildSectionHeader('Trending Worship', onViewAll: () {
                // TODO: Navigate to trending page
              }),
              const SizedBox(height: 16),
              _buildSongsList(controller.trendingSongs),
              const SizedBox(height: 32),
            ],

            // Featured Albums
            if (controller.featuredAlbums.isNotEmpty) ...[
              _buildSectionHeader('Featured Albums', onViewAll: () {
                // TODO: Navigate to albums page
              }),
              const SizedBox(height: 16),
              _buildAlbumsList(controller.featuredAlbums),
              const SizedBox(height: 32),
            ],

            // New Releases
            if (controller.newReleases.isNotEmpty) ...[
              _buildSectionHeader('New Releases', onViewAll: () {
                // TODO: Navigate to new releases page
              }),
              const SizedBox(height: 16),
              _buildSongsList(controller.newReleases),
              const SizedBox(height: 32),
            ],

            const SizedBox(height: 80), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomePageController controller) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 32.0, 32.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${controller.greeting},',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                Text(
                  controller.userName,
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'What Do You Want To Listen To Today?',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).primaryText,
                      ),
                ),
              ],
            ),
          ),
          FlutterFlowIconButton(
            borderRadius: 20.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.notifications_outlined,
              color: FlutterFlowTheme.of(context).primaryText,
              size: 24.0,
            ),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFeedCard(DailyFeed feed) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
      child: InkWell(
        onTap: () => _controller.playDailyFeed(),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlutterFlowTheme.of(context).primary,
                FlutterFlowTheme.of(context).tertiary,
              ],
              stops: const [0.0, 1.0],
              begin: const AlignmentDirectional(-1.0, -1.0),
              end: const AlignmentDirectional(1.0, 1.0),
            ),
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 8.0,
                color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                offset: const Offset(0.0, 4.0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            feed.title,
                            style: FlutterFlowTheme.of(context)
                                .headlineSmall
                                .override(
                                  fontFamily: 'Readex Pro',
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            feed.description ??
                                '${feed.songCount} songs curated for you',
                            style:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ],
                ),
                if (feed.songs != null && feed.songs!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...feed.songs!.take(3).map((song) => Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.music_note,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${song.title} • ${song.artistName ?? 'Unknown'}',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: 'Readex Pro',
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 12,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    final moods = [
      {'icon': Icons.favorite, 'label': 'Worship', 'value': 'worship'},
      {'icon': Icons.celebration, 'label': 'Praise', 'value': 'praise'},
      {'icon': Icons.spa, 'label': 'Reflection', 'value': 'reflection'},
      {'icon': Icons.stars, 'label': 'Celebration', 'value': 'celebration'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
          child: Text(
            'Choose Your Mood',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
            scrollDirection: Axis.horizontal,
            itemCount: moods.length,
            itemBuilder: (context, index) {
              final mood = moods[index];
              return Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                child: InkWell(
                  onTap: () async {
                    // TODO: Navigate to mood-based playlist
                    final songs = await _controller
                        .getSongsByMood(mood['value'] as String);
                    // Show songs or navigate
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).alternate,
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          mood['icon'] as IconData,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mood['label'] as String,
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Readex Pro',
                                    fontSize: 11,
                                  ),
                          textAlign: TextAlign.center,
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
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: Text(
                'View All',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSongsList(List<Song> songs) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _buildSongCard(song);
        },
      ),
    );
  }

  Widget _buildSongCard(Song song) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
      child: InkWell(
        onTap: () {
          _controller.playSong(song);
          context.pushNamed('musicOpen'); // Navigate to now playing
        },
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: 140,
                  height: 140,
                  color: FlutterFlowTheme.of(context).alternate,
                  child: song.album?.coverImage != null
                      ? Image.network(
                          song.album!.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                song.artistName ?? 'Unknown Artist',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      fontSize: 11,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumsList(List<Album> albums) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsetsDirectional.fromSTEB(32.0, 0.0, 32.0, 0.0),
        scrollDirection: Axis.horizontal,
        itemCount: albums.length,
        itemBuilder: (context, index) {
          final album = albums[index];
          return _buildAlbumCard(album);
        },
      ),
    );
  }

  Widget _buildAlbumCard(Album album) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 16.0, 0.0),
      child: InkWell(
        onTap: () {
          context.pushNamed('album'); // Navigate to album detail
        },
        child: Container(
          width: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Container(
                  width: 140,
                  height: 140,
                  color: FlutterFlowTheme.of(context).alternate,
                  child: album.coverImage != null
                      ? Image.network(
                          album.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                        )
                      : _buildPlaceholderImage(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                album.title,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (album.releaseDate != null)
                Text(
                  '${album.releaseDate!.year}',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                        fontFamily: 'Readex Pro',
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 11,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      child: Icon(
        Icons.music_note,
        size: 48,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }
}
