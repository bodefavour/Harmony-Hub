import 'package:flutter/foundation.dart';

/// Global notifier to track modal visibility
/// Used to hide the mini player when modals (like NowPlayingModal) are open
class ModalVisibilityNotifier extends ChangeNotifier {
  static final ModalVisibilityNotifier _instance =
      ModalVisibilityNotifier._internal();

  factory ModalVisibilityNotifier() => _instance;

  ModalVisibilityNotifier._internal();

  bool _isModalVisible = false;

  bool get isModalVisible => _isModalVisible;

  void showModal() {
    if (!_isModalVisible) {
      _isModalVisible = true;
      notifyListeners();
      print('DEBUG MODAL: Modal shown, mini player should hide');
    }
  }

  void hideModal() {
    if (_isModalVisible) {
      _isModalVisible = false;
      notifyListeners();
      print('DEBUG MODAL: Modal hidden, mini player can show');
    }
  }
}
