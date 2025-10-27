import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../models/admin_upload.dart';
import '../../services/admin_service.dart';
import 'admin_dashboard_controller.dart';

class AdminDashboardWidget extends StatefulWidget {
  const AdminDashboardWidget({super.key});

  @override
  State<AdminDashboardWidget> createState() => _AdminDashboardWidgetState();
}

class _AdminDashboardWidgetState extends State<AdminDashboardWidget> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final String adminId = 'admin-user-id'; // TODO: Get from auth

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'AdminDashboard'});
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminDashboardController(
        adminService: AdminService(),
      )..initialize(),
      child: Consumer<AdminDashboardController>(
        builder: (context, controller, _) {
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              key: scaffoldKey,
              backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
              appBar: AppBar(
                backgroundColor: FlutterFlowTheme.of(context).primary,
                automaticallyImplyLeading: false,
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
                title: Text(
                  'Admin Dashboard',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                centerTitle: true,
                actions: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    buttonSize: 48.0,
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    onPressed: controller.refresh,
                  ),
                ],
                bottom: _buildTabBar(context, controller),
              ),
              body: SafeArea(
                top: true,
                child: controller.isLoading
                    ? _buildLoadingState(context)
                    : controller.error != null
                        ? _buildErrorState(context, controller)
                        : _buildContent(context, controller),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(BuildContext context, AdminDashboardController controller) {
    return TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withOpacity(0.6),
      labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: 'Readex Pro',
            color: Colors.white,
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
          ),
      unselectedLabelStyle: FlutterFlowTheme.of(context).titleMedium.override(
            fontFamily: 'Readex Pro',
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.0,
          ),
      indicatorColor: Colors.white,
      tabs: [
        Tab(
          text: 'Pending (${controller.pendingCount})',
        ),
        Tab(
          text: 'Approved (${controller.approvedCount})',
        ),
        Tab(
          text: 'Rejected (${controller.rejectedCount})',
        ),
      ],
      onTap: (index) {
        final tabs = ['pending', 'approved', 'rejected'];
        controller.selectTab(tabs[index]);
      },
    );
  }

  Widget _buildContent(BuildContext context, AdminDashboardController controller) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUploadList(context, controller, controller.pendingUploads, true),
        _buildUploadList(context, controller, controller.approvedUploads, false),
        _buildUploadList(context, controller, controller.rejectedUploads, false),
      ],
    );
  }

  Widget _buildUploadList(
    BuildContext context,
    AdminDashboardController controller,
    List<AdminUpload> uploads,
    bool showActions,
  ) {
    if (uploads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64.0,
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16.0),
            Text(
              'No uploads found',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: uploads.length,
        itemBuilder: (context, index) {
          final upload = uploads[index];
          return _buildUploadCard(context, controller, upload, showActions);
        },
      ),
    );
  }

  Widget _buildUploadCard(
    BuildContext context,
    AdminDashboardController controller,
    AdminUpload upload,
    bool showActions,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (upload.coverImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      upload.coverImage!,
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                    ),
                  )
                else
                  _buildPlaceholderImage(),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upload.songTitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              fontFamily: 'Readex Pro',
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'by ${upload.artistName}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                            ),
                      ),
                      if (upload.albumTitle != null) ...[
                        const SizedBox(height: 4.0),
                        Text(
                          'Album: ${upload.albumTitle}',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                fontFamily: 'Readex Pro',
                                color: FlutterFlowTheme.of(context).secondaryText,
                                letterSpacing: 0.0,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(context, upload.status),
              ],
            ),
            const SizedBox(height: 12.0),
            Divider(color: FlutterFlowTheme.of(context).alternate),
            const SizedBox(height: 12.0),
            Row(
              children: [
                if (upload.genre != null) ...[
                  _buildInfoChip(context, Icons.music_note, upload.genre!),
                  const SizedBox(width: 8.0),
                ],
                _buildInfoChip(
                  context,
                  Icons.access_time,
                  _formatDate(upload.createdAt),
                ),
              ],
            ),
            if (upload.rejectionReason != null) ...[
              const SizedBox(height: 12.0),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.0,
                      color: FlutterFlowTheme.of(context).error,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        'Rejection Reason: ${upload.rejectionReason}',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              fontFamily: 'Readex Pro',
                              color: FlutterFlowTheme.of(context).error,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showActions) ...[
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () => _showApproveDialog(context, controller, upload.id),
                      text: 'Approve',
                      icon: const Icon(Icons.check_circle, size: 20.0),
                      options: FFButtonOptions(
                        height: 44.0,
                        color: Colors.green,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: FFButtonWidget(
                      onPressed: () => _showRejectDialog(context, controller, upload.id),
                      text: 'Reject',
                      icon: const Icon(Icons.cancel, size: 20.0),
                      options: FFButtonOptions(
                        height: 44.0,
                        color: FlutterFlowTheme.of(context).error,
                        textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              fontFamily: 'Readex Pro',
                              color: Colors.white,
                              letterSpacing: 0.0,
                            ),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, UploadStatus status) {
    Color color;
    IconData icon;
    switch (status) {
      case UploadStatus.approved:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case UploadStatus.rejected:
        color = FlutterFlowTheme.of(context).error;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.orange;
        icon = Icons.pending;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.0, color: color),
          const SizedBox(width: 4.0),
          Text(
            status.displayName,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Readex Pro',
                  color: color,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14.0,
            color: FlutterFlowTheme.of(context).secondaryText,
          ),
          const SizedBox(width: 4.0),
          Text(
            text,
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 60.0,
      height: 60.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).alternate,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        Icons.music_note,
        size: 30.0,
        color: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
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
            'Loading uploads...',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Readex Pro',
                  color: FlutterFlowTheme.of(context).secondaryText,
                  letterSpacing: 0.0,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AdminDashboardController controller) {
    return Center(
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
            FFButtonWidget(
              onPressed: controller.refresh,
              text: 'Retry',
              options: FFButtonOptions(
                height: 44.0,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Readex Pro',
                      color: Colors.white,
                      letterSpacing: 0.0,
                    ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showApproveDialog(BuildContext context, AdminDashboardController controller, String uploadId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve Upload'),
        content: const Text('Are you sure you want to approve this upload? It will be published to the platform.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final success = await controller.approveUpload(uploadId, adminId);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Upload approved successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, AdminDashboardController controller, String uploadId) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Upload'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16.0),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter rejection reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              
              Navigator.of(dialogContext).pop();
              final success = await controller.rejectUpload(
                uploadId,
                adminId,
                reason: reasonController.text,
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Upload rejected'),
                    backgroundColor: FlutterFlowTheme.of(context).error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
