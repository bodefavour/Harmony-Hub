import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/admin_service.dart';

class ArtistUploadController extends ChangeNotifier {
  final AdminService _adminService;

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
  }) : _adminService = adminService;

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

      _uploadProgress = 0.3;
      notifyListeners();

      // Submit for approval (service handles file uploads internally)
      final result = await _adminService.submitUpload(
        uploaderId: '', // TODO: Get from FFAppState().userId or auth
        artistName: _artistName!,
        songTitle: _title!,
        albumTitle: _albumName,
        genre: _genre,
        language: _description, // Using description as language for now
        audioFile: _audioFile!,
        coverImage: _imageFile,
      );

      if (result != null) {
        _uploadProgress = 1.0;
        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        throw Exception('Upload submission failed');
      }
    } catch (e) {
      _error = e.toString();
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
