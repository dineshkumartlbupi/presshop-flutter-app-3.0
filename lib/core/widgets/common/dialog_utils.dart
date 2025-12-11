import 'package:flutter/material.dart';

/// Shows a snackbar with customizable appearance
void showCustomSnackBar(
  BuildContext context,
  String message, {
  SnackBarType type = SnackBarType.info,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final color = _getColorForType(type);
  final icon = _getIconForType(type);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: color,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: action,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

/// Shows a success snackbar
void showSuccessSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message, type: SnackBarType.success);
}

/// Shows an error snackbar
void showErrorSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message, type: SnackBarType.error);
}

/// Shows a warning snackbar
void showWarningSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message, type: SnackBarType.warning);
}

/// Shows an info snackbar
void showInfoSnackBar(BuildContext context, String message) {
  showCustomSnackBar(context, message, type: SnackBarType.info);
}

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

Color _getColorForType(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return Colors.green;
    case SnackBarType.error:
      return Colors.red;
    case SnackBarType.warning:
      return Colors.orange;
    case SnackBarType.info:
      return Colors.blue;
  }
}

IconData _getIconForType(SnackBarType type) {
  switch (type) {
    case SnackBarType.success:
      return Icons.check_circle;
    case SnackBarType.error:
      return Icons.error;
    case SnackBarType.warning:
      return Icons.warning;
    case SnackBarType.info:
      return Icons.info;
  }
}

/// Shows a confirmation dialog
Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDangerous = false,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDangerous ? Colors.red : null,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
}

/// Shows a custom dialog
Future<T?> showCustomDialog<T>(
  BuildContext context, {
  required Widget child,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    ),
  );
}

/// Shows a bottom sheet
Future<T?> showCustomBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => child,
  );
}
