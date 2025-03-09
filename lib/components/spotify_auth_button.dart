import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../utils/constants.dart';
import '../services/spotify_services.dart';

class SpotifyAuthButton extends StatelessWidget {
  final VoidCallback onAuthSuccess;

  const SpotifyAuthButton({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            Theme.of(context).colorScheme.tertiary, // Spotify green
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: () => SpotifyServices.startAuthFlow(context, onAuthSuccess),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note,
              color: Theme.of(context).colorScheme.inversePrimary),
          SizedBox(width: 8),
          Text(
            'Connect to Spotify',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
