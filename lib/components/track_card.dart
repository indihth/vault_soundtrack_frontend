import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';

/// Shows song details including artwork, name, artist, album, and when it was played
class TrackCard extends StatelessWidget {
  // The data model containing all information about this history item
  final Track item;

  const TrackCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // is a card widget appropriate here?
      // margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0, // removes shadow
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Album Artwork section
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(2.0), // Rounded corners for the image
              child: Image.network(
                item.albumArtworkUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                // Handle image loading errors gracefully
                errorBuilder: (context, error, stackTrace) {
                  // If image loading fails, show a placeholder
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 16.0), // Spacing between image and text
            // Song details section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Song name with ellipsis if too long
                  Text(
                    item.songName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow
                        .ellipsis, // Truncate with ... if text is too long
                  ),
                  const SizedBox(height: 4.0), // Vertical spacing
                  // Artist name
                  Text(
                    item.artistName,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  // Album name
                  Text(
                    item.albumName,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
