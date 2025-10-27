import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../models/podcast.dart';
import '../../services/supabase_service.dart';
import '../../services/audio_service.dart';
import 'podcast_detail_controller.dart';

class PodcastDetailWidget extends StatefulWidget {
  final String podcastId;
  final Podcast? podcast;

  const PodcastDetailWidget({
    super.key,
    required this.podcastId,
    this.podcast,
  });

  @override
  State<PodcastDetailWidget> createState() => _PodcastDetailWidgetState();
}

class _PodcastDetailWidgetState extends State<PodcastDetailWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'PodcastDetail'});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PodcastDetailController(
        supabaseService: SupabaseService(),
        audioService: AudioService(),
        podcastId: widget.podcastId,
      )..initialize(widget.podcast),
      child: Consumer<PodcastDetailController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return _buildLoadingState(context);
          }

          if (controller.error != null && controller.podcast == null) {
            return _buildErrorState(context, controller);
          }

          final podcast = controller.podcast!;

          return Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            body: CustomScrollView(
              slivers: [
                _buildAppBar(context, controller, podcast),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPodcastInfo(context, podcast),
                      _buildActionButtons(context, controller),
                      _buildDescription(context, podcast),
                      _buildDetails(context, podcast),
                      const SizedBox(height: 80.0), // Space for bottom player
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, PodcastDetailController controller, Podcast podcast) {
    return SliverAppBar(
      expandedHeight: 350.0,
      floating: false,
      pinned: true,
      backgroundColor: FlutterFlowTheme.of(context).primary,
      leading: FlutterFlowIconButton(
        borderColor: Colors.transparent,
        borderRadius: 30.0,
        buttonSize: 48.0,
        icon: const Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 24.0,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 48.0,
          icon: Icon(
            controller.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: controller.toggleFavorite,
        ),
        FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 48.0,
          icon: const Icon(
            Icons.share,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: controller.sharePodcast,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Podcast Image with gradient overlay
            podcast.imageUrl != null
                ? Image.network(
                    podcast.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(context),
                  )
                : _buildPlaceholderImage(context),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodcastInfo(BuildContext context, Podcast podcast) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            podcast.title,
            style: FlutterFlowTheme.of(context).headlineMedium.override(
                  fontFamily: 'Outfit',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8.0),
          Text(
            podcast.artistName ?? 'Unknown Host',
            style: FlutterFlowTheme.of(context).bodyLarge.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
          const SizedBox(height: 16.0),
          Row(
            children: [
              if (podcast.category != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    podcast.category!.toUpperCase(),
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          fontFamily: 'Readex Pro',
                          color: FlutterFlowTheme.of(context).primary,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                const SizedBox(width: 12.0),
              ],
              Icon(
                Icons.access_time,
                size: 20.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4.0),
              Text(
                _formatDuration(podcast.duration),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(width: 16.0),
              Icon(
                Icons.calendar_today,
                size: 20.0,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
              const SizedBox(width: 4.0),
              Text(
                _formatDate(podcast.releaseDate),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, PodcastDetailController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: controller.isPlaying ? controller.pausePodcast : controller.playPodcast,
              icon: Icon(
                controller.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              label: Text(
                controller.isPlaying ? 'Pause' : 'Play',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            flex: 2,
            child: OutlinedButton.icon(
              onPressed: controller.downloadPodcast,
              icon: Icon(
                Icons.download,
                color: FlutterFlowTheme.of(context).primary,
              ),
              label: Text(
                'Download',
                style: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).primary,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                side: BorderSide(
                  color: FlutterFlowTheme.of(context).primary,
                  width: 2.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context, Podcast podcast) {
    if (podcast.description == null || podcast.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About this podcast',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12.0),
          Text(
            podcast.description!,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context, Podcast podcast) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: FlutterFlowTheme.of(context).titleMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16.0),
          _buildDetailRow(
            context,
            icon: Icons.person,
            label: 'Host',
            value: podcast.artistName ?? 'Unknown',
          ),
          _buildDetailRow(
            context,
            icon: Icons.category,
            label: 'Category',
            value: podcast.category ?? 'General',
          ),
          _buildDetailRow(
            context,
            icon: Icons.access_time,
            label: 'Duration',
            value: _formatDuration(podcast.duration),
          ),
          _buildDetailRow(
            context,
            icon: Icons.calendar_today,
            label: 'Release Date',
            value: _formatDate(podcast.releaseDate),
          ),
          if (podcast.episodeNumber != null)
            _buildDetailRow(
              context,
              icon: Icons.numbers,
              label: 'Episode',
              value: podcast.episodeNumber.toString(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20.0,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
          Text(
            value,
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage(BuildContext context) {
    return Container(
      color: FlutterFlowTheme.of(context).alternate,
      child: Icon(
        Icons.podcasts,
        size: 120.0,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Loading podcast...',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PodcastDetailController controller) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 48.0,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24.0,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.0,
                color: FlutterFlowTheme.of(context).error,
              ),
              const SizedBox(height: 16.0),
              Text(
                controller.error!,
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      fontFamily: 'Readex Pro',
                      color: FlutterFlowTheme.of(context).secondaryText,
                      letterSpacing: 0.0,
                    ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => controller.initialize(widget.podcast),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Retry',
                  style: FlutterFlowTheme.of(context).titleSmall.override(
                        fontFamily: 'Readex Pro',
                        color: Colors.white,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${secs}s';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
