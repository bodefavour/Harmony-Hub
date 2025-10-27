import 'package:flutter/material.dart';
import '../../models/admin_upload.dart';
import '../../services/admin_service.dart';

class AdminDashboardController extends ChangeNotifier {
  final AdminService _adminService;

  bool _isLoading = false;
  String? _error;

  List<AdminUpload> _pendingUploads = [];
  List<AdminUpload> _approvedUploads = [];
  List<AdminUpload> _rejectedUploads = [];

  String _selectedTab = 'pending'; // pending, approved, rejected

  AdminDashboardController({
    required AdminService adminService,
  }) : _adminService = adminService;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AdminUpload> get pendingUploads => _pendingUploads;
  List<AdminUpload> get approvedUploads => _approvedUploads;
  List<AdminUpload> get rejectedUploads => _rejectedUploads;
  String get selectedTab => _selectedTab;

  List<AdminUpload> get currentList {
    switch (_selectedTab) {
      case 'approved':
        return _approvedUploads;
      case 'rejected':
        return _rejectedUploads;
      default:
        return _pendingUploads;
    }
  }

  int get pendingCount => _pendingUploads.length;
  int get approvedCount => _approvedUploads.length;
  int get rejectedCount => _rejectedUploads.length;

  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadPendingUploads(),
        _loadApprovedUploads(),
        _loadRejectedUploads(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load uploads: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadPendingUploads() async {
    try {
      _pendingUploads = await _adminService.getPendingUploads();
    } catch (e) {
      print('Error loading pending uploads: $e');
    }
  }

  Future<void> _loadApprovedUploads() async {
    try {
      // Get all uploads and filter approved ones
      final allPending = await _adminService.getPendingUploads();
      _approvedUploads =
          allPending.where((u) => u.status == UploadStatus.approved).toList();
    } catch (e) {
      print('Error loading approved uploads: $e');
    }
  }

  Future<void> _loadRejectedUploads() async {
    try {
      // Get all uploads and filter rejected ones
      final allPending = await _adminService.getPendingUploads();
      _rejectedUploads =
          allPending.where((u) => u.status == UploadStatus.rejected).toList();
    } catch (e) {
      print('Error loading rejected uploads: $e');
    }
  }

  void selectTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
  }

  Future<bool> approveUpload(String uploadId, String adminId) async {
    try {
      final success = await _adminService.approveUpload(uploadId, adminId);

      if (success) {
        // Move from pending to approved
        final upload = _pendingUploads.firstWhere((u) => u.id == uploadId);
        _pendingUploads.removeWhere((u) => u.id == uploadId);
        _approvedUploads.insert(
            0,
            upload.copyWith(
              status: UploadStatus.approved,
              reviewedBy: adminId,
              reviewedAt: DateTime.now(),
            ));
      }

      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to approve upload: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectUpload(String uploadId, String adminId,
      {required String reason}) async {
    try {
      final success =
          await _adminService.rejectUpload(uploadId, adminId, reason);

      if (success) {
        // Move from pending to rejected
        final upload = _pendingUploads.firstWhere((u) => u.id == uploadId);
        _pendingUploads.removeWhere((u) => u.id == uploadId);
        _rejectedUploads.insert(
            0,
            upload.copyWith(
              status: UploadStatus.rejected,
              reviewedBy: adminId,
              reviewedAt: DateTime.now(),
              rejectionReason: reason,
            ));
      }

      notifyListeners();
      return success;
    } catch (e) {
      _error = 'Failed to reject upload: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<void> refresh() async {
    await initialize();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
