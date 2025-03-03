import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;

  const MyButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Theme.of(context).colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}


  // Widget build(BuildContext context) {
  //   return ElevatedButton(
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: const Color(0xFF1DB954), // Spotify green
  //       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(24),
  //       ),
  //     ),
  //     onPressed: () => SpotifyServices.startAuthFlow(context, onAuthSuccess),
  //     child: const Row(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         Icon(Icons.music_note, color: Colors.white),
  //         SizedBox(width: 8),
  //         Text('Connect to Spotify',
  //             style:
  //                 TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
  //       ],
  //     ),
  //   );
  // }