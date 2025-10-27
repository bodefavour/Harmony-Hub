import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';
import '../../flutter_flow/flutter_flow_icon_button.dart';
import '../../flutter_flow/flutter_flow_widgets.dart';
import '../../services/admin_service.dart';
import '../../services/supabase_service.dart';
import 'artist_upload_controller.dart';

class ArtistUploadWidget extends StatefulWidget {
  const ArtistUploadWidget({super.key});

  @override
  State<ArtistUploadWidget> createState() => _ArtistUploadWidgetState();
}

class _ArtistUploadWidgetState extends State<ArtistUploadWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view',
        parameters: {'screen_name': 'ArtistUpload'});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ArtistUploadController(
        adminService: AdminService(),
        supabaseService: SupabaseService(),
      ),
      child: Consumer<ArtistUploadController>(
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
                  'Upload Content',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.white,
                        fontSize: 22.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                top: true,
                child: controller.isUploading
                    ? _buildUploadingState(context, controller)
                    : SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildUploadTypeSelector(context, controller),
                                const SizedBox(height: 24.0),
                                _buildTitleField(context, controller),
                                const SizedBox(height: 16.0),
                                _buildArtistNameField(context, controller),
                                const SizedBox(height: 16.0),
                                if (controller.uploadType == 'song') ...[
                                  _buildAlbumNameField(context, controller),
                                  const SizedBox(height: 16.0),
                                  _buildGenreField(context, controller),
                                  const SizedBox(height: 16.0),
                                ],
                                if (controller.uploadType == 'podcast') ...[
                                  _buildCategoryField(context, controller),
                                  const SizedBox(height: 16.0),
                                ],
                                _buildDescriptionField(context, controller),
                                const SizedBox(height: 24.0),
                                _buildAudioFilePicker(context, controller),
                                const SizedBox(height: 16.0),
                                _buildImageFilePicker(context, controller),
                                const SizedBox(height: 32.0),
                                if (controller.error != null)
                                  _buildErrorMessage(context, controller),
                                _buildSubmitButton(context, controller),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadTypeSelector(
      BuildContext context, ArtistUploadController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Content Type',
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Readex Pro',
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            Expanded(
              child: _buildTypeChip(
                context,
                controller,
                'song',
                'Song',
                Icons.music_note,
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: _buildTypeChip(
                context,
                controller,
                'podcast',
                'Podcast',
                Icons.podcasts,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context,
    ArtistUploadController controller,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.uploadType == value;
    return InkWell(
      onTap: () => controller.setUploadType(value),
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? FlutterFlowTheme.of(context).primary
              : FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate,
            width: 2.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : FlutterFlowTheme.of(context).secondaryText,
              size: 32.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              label,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Readex Pro',
                    color: isSelected
                        ? Colors.white
                        : FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(
      BuildContext context, ArtistUploadController controller) {
    return TextFormField(
      initialValue: controller.title,
      onChanged: controller.setTitle,
      decoration: InputDecoration(
        labelText: 'Title *',
        hintText: 'Enter ${controller.uploadType} title',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Title is required';
        }
        return null;
      },
    );
  }

  Widget _buildArtistNameField(
      BuildContext context, ArtistUploadController controller) {
    return TextFormField(
      initialValue: controller.artistName,
      onChanged: controller.setArtistName,
      decoration: InputDecoration(
        labelText: controller.uploadType == 'podcast'
            ? 'Host Name *'
            : 'Artist Name *',
        hintText: 'Enter artist/host name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Artist/Host name is required';
        }
        return null;
      },
    );
  }

  Widget _buildAlbumNameField(
      BuildContext context, ArtistUploadController controller) {
    return TextFormField(
      initialValue: controller.albumName,
      onChanged: controller.setAlbumName,
      decoration: InputDecoration(
        labelText: 'Album Name (Optional)',
        hintText: 'Enter album name',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.album),
      ),
    );
  }

  Widget _buildGenreField(
      BuildContext context, ArtistUploadController controller) {
    return DropdownButtonFormField<String>(
      value: controller.genre,
      decoration: InputDecoration(
        labelText: 'Genre',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'gospel', child: Text('Gospel')),
        DropdownMenuItem(value: 'worship', child: Text('Worship')),
        DropdownMenuItem(value: 'praise', child: Text('Praise')),
        DropdownMenuItem(value: 'contemporary', child: Text('Contemporary')),
        DropdownMenuItem(value: 'traditional', child: Text('Traditional')),
      ],
      onChanged: (value) {
        if (value != null) controller.setGenre(value);
      },
    );
  }

  Widget _buildCategoryField(
      BuildContext context, ArtistUploadController controller) {
    return DropdownButtonFormField<String>(
      value: controller.category,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        prefixIcon: const Icon(Icons.category),
      ),
      items: const [
        DropdownMenuItem(value: 'sermons', child: Text('Sermons')),
        DropdownMenuItem(value: 'teachings', child: Text('Teachings')),
        DropdownMenuItem(value: 'testimonies', child: Text('Testimonies')),
        DropdownMenuItem(value: 'interviews', child: Text('Interviews')),
      ],
      onChanged: (value) {
        if (value != null) controller.setCategory(value);
      },
    );
  }

  Widget _buildDescriptionField(
      BuildContext context, ArtistUploadController controller) {
    return TextFormField(
      initialValue: controller.description,
      onChanged: controller.setDescription,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Enter description',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildAudioFilePicker(
      BuildContext context, ArtistUploadController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Audio File *',
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Readex Pro',
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12.0),
        if (controller.audioFile != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.audiotrack,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    controller.audioFileName ?? 'Audio file',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0.0,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.removeAudioFile,
                ),
              ],
            ),
          )
        else
          FFButtonWidget(
            onPressed: controller.pickAudioFile,
            text: 'Choose Audio File',
            icon: const Icon(Icons.upload_file),
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
      ],
    );
  }

  Widget _buildImageFilePicker(
      BuildContext context, ArtistUploadController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cover Image (Optional)',
          style: FlutterFlowTheme.of(context).bodyLarge.override(
                fontFamily: 'Readex Pro',
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12.0),
        if (controller.imageFile != null)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: FlutterFlowTheme.of(context).primary,
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Image.file(
                    controller.imageFile!,
                    width: 60.0,
                    height: 60.0,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Text(
                    controller.imageFileName ?? 'Image file',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Readex Pro',
                          letterSpacing: 0.0,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: controller.removeImageFile,
                ),
              ],
            ),
          )
        else
          FFButtonWidget(
            onPressed: controller.pickImageFile,
            text: 'Choose Cover Image',
            icon: const Icon(Icons.image),
            options: FFButtonOptions(
              width: double.infinity,
              height: 56.0,
              color: FlutterFlowTheme.of(context).secondaryBackground,
              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).primaryText,
                    letterSpacing: 0.0,
                  ),
              borderSide: BorderSide(
                color: FlutterFlowTheme.of(context).alternate,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, ArtistUploadController controller) {
    return FFButtonWidget(
      onPressed: controller.canSubmit
          ? () async {
              if (_formKey.currentState!.validate()) {
                final success = await controller.submitUpload();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Upload submitted successfully! It will be reviewed by our team.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  context.pop();
                }
              }
            }
          : null,
      text: 'Submit for Review',
      icon: const Icon(Icons.check_circle),
      options: FFButtonOptions(
        width: double.infinity,
        height: 56.0,
        color: FlutterFlowTheme.of(context).primary,
        textStyle: FlutterFlowTheme.of(context).titleMedium.override(
              fontFamily: 'Readex Pro',
              color: Colors.white,
              letterSpacing: 0.0,
              fontWeight: FontWeight.w600,
            ),
        elevation: 3.0,
        borderRadius: BorderRadius.circular(12.0),
        disabledColor:
            FlutterFlowTheme.of(context).secondaryText.withOpacity(0.3),
        disabledTextColor: FlutterFlowTheme.of(context).secondaryText,
      ),
    );
  }

  Widget _buildErrorMessage(
      BuildContext context, ArtistUploadController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).error,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: FlutterFlowTheme.of(context).error,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                controller.error!,
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
    );
  }

  Widget _buildUploadingState(
      BuildContext context, ArtistUploadController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: controller.uploadProgress,
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
              strokeWidth: 6.0,
            ),
            const SizedBox(height: 24.0),
            Text(
              '${(controller.uploadProgress * 100).toInt()}%',
              style: FlutterFlowTheme.of(context).headlineMedium.override(
                    fontFamily: 'Outfit',
                    color: FlutterFlowTheme.of(context).primary,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12.0),
            Text(
              'Uploading your content...',
              style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontFamily: 'Readex Pro',
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Please don\'t close this screen',
              style: FlutterFlowTheme.of(context).bodySmall.override(
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
}
