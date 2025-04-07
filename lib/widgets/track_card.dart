import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/widgets/vote_icon.dart';
import 'package:vault_soundtrack_frontend/mixins/voting_mixin.dart';

/// Shows song details including artwork, name, artist, album, and when it was played
class TrackCard extends StatefulWidget {
  // The data model containing all information about this history item
  final Track item;

  TrackCard({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  State<TrackCard> createState() => _TrackCardState();
}

// Voting logic handled in mixin
class _TrackCardState extends State<TrackCard> with VotingMixin {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();

    // Initialize loading states for upvote and downvote
    isUpVoted = widget.item.hasUserUpVoted(userId);
    isDownVoted = widget.item.hasUserDownVoted(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
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
                widget.item.albumArtworkUrl,
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
                    widget.item.songName,
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
                    widget.item.artistName,
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
                    widget.item.albumName,
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
            // dispay icon if song is liked
            // if (item.isLiked)

            SizedBox(width: 8.0), // Spacing between icons

            const SizedBox(width: 8.0),

            // Up vote icon and text - takes loading state and widget item to get live vote data rom db
            VoteIcon(
              isUpVote: true,
              isVoted: isUpVoted,
              isLoading: isUpVoteLoading,
              voteCount: widget.item.upVotes,
              onTap: () => handleVote(context, widget.item, "up"),
            ),

            const SizedBox(width: 8.0),

            // Down vote icon and text
            VoteIcon(
              isUpVote: false,
              isVoted: isDownVoted,
              isLoading: isDownVoteLoading,
              voteCount: widget.item.downVotes,
              onTap: () => handleVote(context, widget.item, "down"),
            ),
          ],
        ),
      ),
    );
  }
}
