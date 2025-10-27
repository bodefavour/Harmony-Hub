import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/services/supabase_service.dart';
import '/services/audio_service.dart';
import 'artist_profile_controller.dart';

class ArtistProfileWidgetNew extends StatefulWidget {
  final String? artistId;

  const ArtistProfileWidgetNew({
    super.key,
    this.artistId,
  });

  @override
  State<ArtistProfileWidgetNew> createState() => _ArtistProfileWidgetNewState();
}

class _ArtistProfileWidgetNewState extends State<ArtistProfileWidgetNew> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'ArtistProfile'});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artistId == null || widget.artistId!.isEmpty) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: const Center(
          child: Text('Artist ID is required'),
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ArtistProfileController(
        supabaseService: SupabaseService(),
        audioService: AudioService(),
      )..initialize(widget.artistId!, userId: currentUserUid),
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

  Widget _buildArtistBody(
      BuildContext context, ArtistProfileController controller) {
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE74B08)),
        ),
      );
    }

    if (controller.error != null || controller.artist == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                controller.error ?? 'Artist not found',
                style: FlutterFlowTheme.of(context).bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FFButtonWidget(
                onPressed: () => context.pop(),
                text: 'Go Back',
                options: FFButtonOptions(
                  height: 44,
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                  color: const Color(0xFFE74B08),
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                      ),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        // Artist Header with Cover Image
        SliverAppBar(
          expandedHeight: 350,
          pinned: true,
          backgroundColor: const Color(0xFFE74B08),
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () {
              logFirebaseEvent('ARTIST_PROFILE_BACK');
              context.pop();
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Background Image
                Image.network(
                  controller.artistImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE74B08),
                    child: const Icon(
                      Icons.person,
                      size: 120,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                // Artist Name and Actions at Bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.artistName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        controller.artist?.country ?? '',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          FFButtonWidget(
                            onPressed: () =>
                                controller.toggleFollow(currentUserUid),
                            text:
                                controller.isFollowing ? 'Following' : 'Follow',
                            icon: Icon(
                              controller.isFollowing ? Icons.check : Icons.add,
                              size: 20,
                            ),
                            options: FFButtonOptions(
                              height: 40,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  20, 0, 20, 0),
                              color: controller.isFollowing
                                  ? Colors.grey[800]
                                  : const Color(0xFFE74B08),
                              textStyle: FlutterFlowTheme.of(context)
                                  .titleSmall
                                  .override(
                                    fontFamily: 'Readex Pro',
                                    color: Colors.white,
                                  ),
                              elevation: 2,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FlutterFlowIconButton(
                            borderRadius: 20,
                            borderWidth: 1,
                            buttonSize: 40,
                            fillColor: Colors.grey[800],
                            icon: const Icon(
                              Icons.share,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              logFirebaseEvent('ARTIST_PROFILE_SHARE');
                              controller.shareArtist();
                            },
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

        // Artist Bio Section
        if (controller.artistBio.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          fontFamily: 'Outfit',
                          color: const Color(0xFFE74B08),
                          fontSize: 22.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.artistBio,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
            ),
          ),

        // Top Songs Section
        if (controller.hasTopSongs)
          SliverToBoxAdapter(
            child: _buildTopSongsSection(context, controller),
          ),

        // Albums Section
        if (controller.hasAlbums)
          SliverToBoxAdapter(
            child: _buildAlbumsSection(context, controller),
          ),

        // Bottom Padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  Widget _buildTopSongsSection(
      BuildContext context, ArtistProfileController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular',
                style: FlutterFlowTheme.of(context).headlineMedium.override(
                      fontFamily: 'Outfit',
                      color: const Color(0xFFE74B08),
                      fontSize: 22.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton.icon(
                onPressed: () => controller.playAllTopSongs(),
                icon: const Icon(Icons.play_arrow, color: Color(0xFFE74B08)),
                label: Text(
                  'Play All',
                  style: TextStyle(color: const Color(0xFFE74B08)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: controller.topSongs.length > 10
                ? 10
                : controller.topSongs.length,
            itemBuilder: (context, index) {
              final song = controller.topSongs[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    logFirebaseEvent('ARTIST_PROFILE_TOP_SONG_TAP');
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
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74B08).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE74B08),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        song.title,
                        style: FlutterFlowTheme.of(context).titleMedium,
                      ),
                      subtitle: Text(
                        '${song.playCount} plays',
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
                          logFirebaseEvent('ARTIST_PROFILE_PLAY_TOP_SONG');
                          controller.playSong(song);
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumsSection(
      BuildContext context, ArtistProfileController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Albums',
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  color: const Color(0xFFE74B08),
                  fontSize: 22.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: controller.albums.length,
              itemBuilder: (context, index) {
                final album = controller.albums[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () {
                      logFirebaseEvent('ARTIST_PROFILE_ALBUM_TAP');
                      context.pushNamed(
                        'album',
                        pathParameters: {'albumId': album.id},
                      );
                    },
                    child: Container(
                      width: 160,
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
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              album.coverImage ?? '',
                              width: 160,
                              height: 160,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 160,
                                height: 160,
                                color: const Color(0xFFE74B08),
                                child: const Icon(
                                  Icons.album,
                                  size: 48,
                                  color: Colors.white,
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
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  album.releaseDate?.year.toString() ??
                                      'Unknown',
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: 'Readex Pro',
                                        fontSize: 12,
                                        letterSpacing: 0.0,
                                        color: Colors.grey,
                                      ),
                                ),
                              ],
                            ),
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
}
