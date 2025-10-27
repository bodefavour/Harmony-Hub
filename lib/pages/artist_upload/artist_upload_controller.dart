import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/admin_service.dart';
import '../../services/supabase_service.dart';
import '../../models/admin_upload.dart';

class ArtistUploadController extends ChangeNotifier {
  final AdminService _adminService;
  final SupabaseService _supabaseService;

  bool _isUploading = false;
  String? _error;
  double _uploadProgress = 0.0;

  // Form fields
  String _uploadType = 'song'; // song, podcast, album
  String? _title;
  String? _description;
  String? _artistName;
  String? _albumName;
  String? _genre;
  String? _category;
  int? _duration;
  File? _audioFile;
  File? _imageFile;
  String? _audioFileName;
  String? _imageFileName;

  ArtistUploadController({
    required AdminService adminService,
    required SupabaseService supabaseService,
  })  : _adminService = adminService,
        _supabaseService = supabaseService;

  // Getters
  bool get isUploading => _isUploading;
  String? get error => _error;
  double get uploadProgress => _uploadProgress;
  String get uploadType => _uploadType;
  String? get title => _title;
  String? get description => _description;
  String? get artistName => _artistName;
  String? get albumName => _albumName;
  String? get genre => _genre;
  String? get category => _category;
  int? get duration => _duration;
  File? get audioFile => _audioFile;
  File? get imageFile => _imageFile;
  String? get audioFileName => _audioFileName;
  String? get imageFileName => _imageFileName;

  bool get canSubmit =>
      _title != null &&
      _title!.isNotEmpty &&
      _artistName != null &&
      _artistName!.isNotEmpty &&
      _audioFile != null;

  void setUploadType(String type) {
    _uploadType = type;
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setArtistName(String value) {
    _artistName = value;
    notifyListeners();
  }

  void setAlbumName(String value) {
    _albumName = value;
    notifyListeners();
  }

  void setGenre(String value) {
    _genre = value;
    notifyListeners();
  }

  void setCategory(String value) {
    _category = value;
    notifyListeners();
  }

  void setDuration(int value) {
    _duration = value;
    notifyListeners();
  }

  Future<void> pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          _audioFile = File(file.path!);
          _audioFileName = file.name;
          _error = null;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to pick audio file: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          _imageFile = File(file.path!);
          _imageFileName = file.name;
          _error = null;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Failed to pick image file: ${e.toString()}';
      notifyListeners();
    }
  }

  void removeAudioFile() {
    _audioFile = null;
    _audioFileName = null;
    notifyListeners();
  }

  void removeImageFile() {
    _imageFile = null;
    _imageFileName = null;
    notifyListeners();
  }

  Future<bool> submitUpload() async {
    if (!canSubmit) {
      _error = 'Please fill in all required fields';
      notifyListeners();
      return false;
    }

    _isUploading = true;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();

    try {
      // Validate files
      if (_audioFile != null) {
        final isValid = await _adminService.validateAudioFile(_audioFile!);
        if (!isValid) {
          throw Exception('Invalid audio file format or size');
        }
      }

      if (_imageFile != null) {
        final isValid = await _adminService.validateImageFile(_imageFile!);
        if (!isValid) {
          throw Exception('Invalid image file format or size');
        }
      }

      // Upload audio file
      _uploadProgress = 0.1;
      notifyListeners();

      final audioPath = await _supabaseService.uploadAudio(
        _audioFile!,
        _audioFileName!,
      );

      _uploadProgress = 0.5;
      notifyListeners();

      // Upload image file if provided
      String? imagePath;
      if (_imageFile != null && _imageFileName != null) {
        imagePath = await _supabaseService.uploadImage(
          _imageFile!,
          _imageFileName!,
        );
      }

      _uploadProgress = 0.7;
      notifyListeners();

      // Submit for approval
      final upload = AdminUpload(
        id: '', // Will be generated by backend
        artistId: '', // TODO: Get from current user
        uploadType: _uploadType,
        title: _title!,
        artistName: _artistName!,
        audioUrl: audioPath,
        imageUrl: imagePath,
        description: _description,
        albumName: _albumName,
        genre: _genre,
        category: _category,
        duration: _duration ?? 0,
        status: UploadStatus.pending,
        submittedAt: DateTime.now(),
      );

      await _adminService.submitUpload(upload);

      _uploadProgress = 1.0;
      notifyListeners();

      return true;
    } catch (e) {
      _error = 'Upload failed: ${e.toString()}';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _uploadType = 'song';
    _title = null;
    _description = null;
    _artistName = null;
    _albumName = null;
    _genre = null;
    _category = null;
    _duration = null;
    _audioFile = null;
    _imageFile = null;
    _audioFileName = null;
    _imageFileName = null;
    _isUploading = false;
    _uploadProgress = 0.0;
    _error = null;
    notifyListeners();
  }
}
