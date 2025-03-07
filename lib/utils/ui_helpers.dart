import 'package:flutter/material.dart';
// Tripple-slash /// are documentation comments that apprear on hover in the IDE

/// UI helper functions for common UI operations
class UIHelpers {
  /// Shows a loading indicator dialog
  ///
  /// [context] - The build context
  /// [barrierDismissible] - Whether clicking outside the dialog dismisses it
  static void showLoadingIndicator(
    BuildContext context, {
    bool barrierDismissible = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// Hides any dialog that is currently showing
  ///
  /// [context] - The build context
  static void hideDialog(BuildContext context) {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  /// Shows a snackbar with a message
  ///
  /// [context] - The build context
  /// [message] - The message to display
  /// [isError] - Whether this is an error message
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
