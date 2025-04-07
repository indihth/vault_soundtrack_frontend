import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';

class PlaylistHeader extends StatelessWidget {
  final VoidCallback handleSavePlaylist;
  final VoidCallback handleEndSession;
  final Playlist item;
  final bool isHost;
  const PlaylistHeader(
      {super.key,
      required this.item,
      required this.isHost,
      required this.handleSavePlaylist,
      required this.handleEndSession});

  // Confirms if the user wants to end the session
  void _confirmEndSession(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('End Session'),
          content: const Text('Are you sure you want to end the session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Close the dialog
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: handleEndSession,
              child: const Text('End Session'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(2.0), // Rounded corners for the image
              child: Container(
                width: 126,
                height: 126,
                color: Colors.grey[300],
                child: const Icon(Icons.music_note, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  softWrap: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24.0,
                  ),
                ),
                Text(
                  item.description,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: handleSavePlaylist,
              icon: Icon(Icons.playlist_play,
                  color: Theme.of(context).colorScheme.tertiary),
              label: Text(
                'Save',
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.tertiary),
              ),
            ),
            if (isHost) ...[
              // Only host can end the session
              const SizedBox(width: 20),
              // Add a button to shuffle the playlist
              ElevatedButton(
                onPressed: () {
                  _confirmEndSession(context);
                },
                // onPressed: handleEndSession,
                child: const Text('End Session'),
              ),
            ]
          ],
        )
      ],
    );
  }
}
