import 'package:flutter/material.dart';
import 'modal_visibility_notifier.dart';

/// Helper function to show modal bottom sheets with proper lifecycle management
/// Automatically notifies the mini player to hide when modal is visible
Future<T?> showManagedModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  Color? backgroundColor,
  bool isDismissible = true,
  bool enableDrag = true,
}) async {
  final modalNotifier = ModalVisibilityNotifier();

  // Notify that modal is shown
  modalNotifier.showModal();

  try {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: backgroundColor ?? Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      builder: builder,
    );

    return result;
  } finally {
    // Always hide modal notification when done
    modalNotifier.hideModal();
  }
}
