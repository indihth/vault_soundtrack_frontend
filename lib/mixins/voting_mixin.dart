import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vault_soundtrack_frontend/models/track.dart';
import 'package:vault_soundtrack_frontend/services/voting.services.dart';
import 'package:vault_soundtrack_frontend/state/session_state.dart';
import 'package:vault_soundtrack_frontend/utils/ui_helpers.dart';

mixin VotingMixin<T extends StatefulWidget> on State<T> {
  // T is generic type of the widget
  bool _isVoteInProgress = false; // Debounce variable to prevent multiple votes

  bool isUpVoted = false;
  bool isDownVoted = false;
  bool isUpVoteLoading = false;
  bool isDownVoteLoading = false;

  Future<void> handleVote(
      BuildContext context, Track track, String voteType) async {
    if (_isVoteInProgress)
      return; // If a vote is already in progress, do nothing

    //TODO: Add limit to api calls to prevent spamming server - wait 500ms

    //TODO: Make vote count also optimistically update before API call

    // Set vote in progress flag at beginning of voting process
    _isVoteInProgress = true;

    final originalIsUpVoted = isUpVoted;
    final originalIsDownVoted = isDownVoted;

    // Storing what the new vote states will be
    bool newIsUpVoted = isUpVoted;
    bool newIsDownVoted = isDownVoted;

    // updateVoteUI(voteType); // handle UI updates more concisely in the method

    if (voteType == 'up') {
      // Toggle the upvote
      newIsUpVoted = !isUpVoted;

      // Remove any downvote if it exists
      if (newIsUpVoted) newIsDownVoted = false;
    } else {
      // Toggle the downvote
      newIsDownVoted = !isDownVoted;

      // Remove any upvote if it exists
      if (newIsDownVoted) newIsUpVoted = false;
    }

    // UI can be optimistically updated before API call
    setState(() {
      isUpVoted = newIsUpVoted;
      isDownVoted = newIsDownVoted;

      // Syntax means if voteType is up, isUpVoteLoading is true, else false and vice versa (if else shorthand)
      isUpVoteLoading = voteType == 'up';
      isDownVoteLoading = voteType == 'down';
    });

    try {
      final sessionState = Provider.of<SessionState>(context, listen: false);
      if (sessionState.sessionId.isEmpty) {
        throw Exception('Session ID state is empty');
      }

      await VotingServices.handleVote(
        sessionState.sessionId,
        sessionState.playlistId,
        track.trackId,
        voteType,
      );

      if (mounted) {
        setState(() {
          isUpVoteLoading = false;
          isDownVoteLoading = false;
        });
      }
    } catch (e) {
      // Revert to original states if the API call fails, reflects actual db state
      if (mounted) {
        setState(() {
          // error - setState after dispose?
          isUpVoted = originalIsUpVoted;
          isDownVoted = originalIsDownVoted;
          isUpVoteLoading = false;
          isDownVoteLoading = false;
        });
      }

      UIHelpers.showSnackBar(context, 'Error: ${e.toString()}', isError: true);
      throw Exception('Failed to vote on song: $e');
    } finally {
      // Reset the vote in progress flag after the voting process is complete
      _isVoteInProgress = false;
    }
  }
}
