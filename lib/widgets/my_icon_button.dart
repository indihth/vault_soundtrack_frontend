import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData iconType;
  final VoidCallback callback;
  final String text;
  final bool primary;

  const MyIconButton({
    super.key,
    required this.iconType,
    required this.callback,
    required this.text,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    final colour = primary
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary; // Spotify green
    return GestureDetector(
      onTap: callback,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              iconType,
              color: colour,
              size: primary ? 30 : 24,
            ),
            SizedBox(width: 20),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontSize: 16, fontWeight: FontWeight.w500, color: colour),
            ),
          ],
        ),
      ),
    );
  }
}
