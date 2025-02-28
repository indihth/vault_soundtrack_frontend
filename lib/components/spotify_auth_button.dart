import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../utils/constants.dart';
import '../services/spotify_service.dart';

class SpotifyAuthButton extends StatelessWidget {
  final VoidCallback onAuthSuccess;

  const SpotifyAuthButton({super.key, required this.onAuthSuccess});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1DB954), // Spotify green
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      onPressed: () => SpotifyService.startAuthFlow(context, onAuthSuccess),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.music_note, color: Colors.white),
          SizedBox(width: 8),
          Text('Connect to Spotify',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
