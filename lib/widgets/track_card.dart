import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/voting.services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';
import 'package:vault_soundtrack_frontend/widgets/vote_icon.dart';

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

class _TrackCardState extends State<TrackCard> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  late bool isUpVoted;
  late bool isDownVoted;

  bool isUpVoteLoading = false;
  bool isDownVoteLoading = false;

  @override
  void initState() {
    super.initState();

    // State variables for voting
    isUpVoted = widget.item.hasUserUpVoted(userId); // check if user has upvoted
    isDownVoted =
        widget.item.hasUserDownVoted(userId); // check if user has downvoted
  }

  void _addUpVote() {
    setState(() {
      isUpVoted = true;
      // upVotes += 1;
    });
  }

  void _removeUpVote() {
    setState(() {
      isUpVoted = false;
      // upVotes -= 1;
    });
  }

  void _addDownVote() {
    setState(() {
      isDownVoted = true;
      // downVotes += 1;
    });
  }

  void _removeDownVote() {
    setState(() {
      isDownVoted = false;
      // downVotes -= 1;
    });
  }

  // handle optamistic UI update on voting
  void updateVoteUI(String voteType) async {
    // update vote state

    // Handle vote and count logic
    if (voteType == 'up') {
      if (isUpVoted) {
        // If state is already upvoted, remove upvote
        _removeUpVote();
        isUpVoteLoading = true;
      } else if (isDownVoted) {
        // If state is downvoted, remove downvote and add upvote
        _addUpVote();
        _removeDownVote();
        isUpVoteLoading = true;
        isDownVoteLoading = true;
      } else {
        // If state is not upvoted or downvoted, add upvote
        _addUpVote();
        isUpVoteLoading = true;
      }

      // Handle downvote logic
    } else if (voteType == 'down') {
      if (isDownVoted) {
        _removeDownVote();
        isDownVoteLoading = true;
      } else if (isUpVoted) {
        _addDownVote();
        _removeUpVote();
        isUpVoteLoading = true;
        isDownVoteLoading = true;
      } else {
        _addDownVote();
        isDownVoteLoading = true;
      }
    }
  }

// handle upvote with voting services
  void handleVote(context, track, voteType) async {
    // Store original state for potential revert
    final originalIsUpVoted = isUpVoted;
    final originalIsDownVoted = isDownVoted;

    // update UI optimistically - show the vote before it's confirmed by server
    updateVoteUI(voteType);

    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      if (sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      // Display loading indicator for voteCount text until response is received

      await VotingServices.handleVote(sessionState.sessionId,
          sessionState.playlistId, track.trackId, voteType);

      // Set loading state to false on success db update
      setState(() {
        isUpVoteLoading = false;
        isDownVoteLoading = false;
      });
    } catch (e) {
      // Revert UI states if voting fails
      setState(() {
        isUpVoted = originalIsUpVoted;
        isDownVoted = originalIsDownVoted;
        isUpVoteLoading = false;
        isDownVoteLoading = false;
      });

      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Failed to upvote song: $e');
    }
  }

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
