import 'package:flutter/material.dart';
import '../services/spotify_services.dart';

class SpotifyAuthButton extends StatelessWidget {
  // final VoidCallback onAuthSuccess;
  final Function(bool success)
      onAuthSuccess; // returns a boolean value success/failure

  const SpotifyAuthButton({super.key, required this.onAuthSuccess});

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
      ),
      onPressed: () => SpotifyServices.startAuthFlow(
          context, (success) => onAuthSuccess(success)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lets go!',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
