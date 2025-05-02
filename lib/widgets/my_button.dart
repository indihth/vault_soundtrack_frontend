import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, danger }

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final bool fullWidth;
  // final ButtonVariant variant;

  const MyButton({
    super.key,
    this.text = 'Lets Go!',
    required this.onTap,
    this.fullWidth = false,
    // this.variant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.tertiary, // Spotify green
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        minimumSize: fullWidth ? const Size(double.infinity, 0) : null,
      ),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
