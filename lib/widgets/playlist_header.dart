import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/models/playlist.dart';

class PlaylistHeader extends StatelessWidget {
  final VoidCallback handleSavePlaylist;
  final VoidCallback handleEndSession;
  final Playlist item;
  const PlaylistHeader(
      {super.key,
      required this.item,
      required this.handleSavePlaylist,
      required this.handleEndSession});

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
              // child: Image.network(
              //   item.image,
              //   width: 126,
              //   height: 126,
              //   fit: BoxFit.cover,
              //   // Handle image loading errors gracefully
              //   errorBuilder: (context, error, stackTrace) {
              //     // If image loading fails, show a placeholder
              //     return Container(
              //       width: 126,
              //       height: 126,
              //       color: Colors.grey[300],
              //       child: const Icon(Icons.music_note, color: Colors.grey),
              //     );
              //   },
              // ),
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
                // Text(
                //   item.users.join(', '),
                //   style: const TextStyle(
                //     color: Colors.grey,
                //     fontSize: 14.0,
                //   ),
                // ),
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
            const SizedBox(width: 20),
            // Add a button to shuffle the playlist
            ElevatedButton(
              onPressed: handleEndSession,
              child: const Text('End Session'),
            ),
          ],
        )
      ],
    );
  }
}
